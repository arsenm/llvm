//===-- SIHazardRecognizer.cpp - SI postra hazard recognizer ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "SIHazardRecognizer.h"
#include "SIInstrInfo.h"
#include "SIRegisterInfo.h"
#include "AMDGPUSubtarget.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetRegisterInfo.h"
using namespace llvm;

#define DEBUG_TYPE "post-RA-sched"


SIHazardRecognizer::SIHazardRecognizer(const InstrItineraryData *ItinData,
                                       const ScheduleDAG *DAG) :
  ScoreboardHazardRecognizer(ItinData, DAG, "post-RA-sched"),
  TII(static_cast<const SIInstrInfo *>(DAG->TII)),
  TRI(static_cast<const SIRegisterInfo *>(DAG->TRI)),
  LastMI(nullptr),
  VALUWriteVCC(0) {}

bool SIHazardRecognizer::isVALUWriteVCC(MachineInstr *MI) const {
  return TII->isVALU(MI->getOpcode()) &&
         MI->modifiesRegister(AMDGPU::VCC, TRI);
}

bool SIHazardRecognizer::isFMASAfterVALUWriteVCC(SUnit *SU) const {
  MachineInstr *MI = SU->getInstr();

  if (MI->getOpcode() != AMDGPU::V_DIV_FMAS_F32 &&
      MI->getOpcode() != AMDGPU::V_DIV_FMAS_F64)
    return false;

  if (!TII->isVALU(MI->getOpcode()))
    return false;

  for (const SDep &Pred : SU->Preds) {
    if (Pred.isAssignedRegDep()) {
      SUnit *PredSU = Pred.getSUnit();



      if (SU->TopReadyCycle - PredSU->BotReadyCycle > 4)
        continue;


      unsigned Reg = Pred.getReg();

      if (Reg == AMDGPU::VCC ||
          Reg == AMDGPU::VCC_LO ||
          Reg == AMDGPU::VCC_HI) {
        return true;
      }
    }
  }

  return false;
}

void SIHazardRecognizer::EmitNoop() {
  if (VALUWriteVCC > 0) {
//    llvm_unreachable("Emitting noop with VCC write waits");
    --VALUWriteVCC;
    DEBUG(dbgs() << "emit noop dec: " << VALUWriteVCC << '\n');
  }

  ScoreboardHazardRecognizer::EmitNoop();
}

ScheduleHazardRecognizer::HazardType
SIHazardRecognizer::getHazardType(SUnit *SU, int Stalls) {
  assert(Stalls == 0 && "SI hazards don't support scoreboard lookahead");
  MachineInstr *MI = SU->getInstr();

  if (MI->isDebugValue())
    return ScoreboardHazardRecognizer::getHazardType(SU, Stalls);

#if 0
  if (isVALUWriteVCC(MI)) {
    VALUWriteVCC = 4;
  }
#endif


//  if (VALUWriteVCC >= 0 && VALUWriteVCC < 4) {
#if 0
  if (VALUWriteVCC > 0) {
    if (MI->getOpcode() == AMDGPU::V_DIV_FMAS_F32 ||
        MI->getOpcode() == AMDGPU::V_DIV_FMAS_F64) {
      DEBUG(dbgs() << "Reporting no-op hazard " << VALUWriteVCC << '\n');
      return NoopHazard;
    }
  }
#endif

#if 0
  if (isFMASAfterVALUWriteVCC(SU)) {
    // Try to schedule another instruction for the next 4 cycles.
    if (VALUWriteVCC < 4) {
      return NoopHazard;
    }
  }
#endif


  return ScoreboardHazardRecognizer::getHazardType(SU, Stalls);
}

void SIHazardRecognizer::Reset() {
  LastMI = nullptr;
//  VALUWriteVCC = -1;
  VALUWriteVCC = 0;
  ScoreboardHazardRecognizer::Reset();
}

void SIHazardRecognizer::EmitInstruction(SUnit *SU) {

  MachineInstr *MI = SU->getInstr();

  if (MI->isDebugValue()) {
    llvm_unreachable("emitting debug value?");
    ScoreboardHazardRecognizer::EmitInstruction(SU);
    return;
  }


  LastMI = MI;

  if (isVALUWriteVCC(MI)) {
    DEBUG(dbgs() << "Is write to VCC: " << *MI << '\n');
    // XXX - Table says need to wait "4" but unclear 4 what.
    VALUWriteVCC = 4;
  }

#if 0
  else if (VALUWriteVCC > 0) {
    --VALUWriteVCC;
    DEBUG(dbgs() << "VALUWriteVCC dec to " << VALUWriteVCC << " in EmitInst " << *MI << '\n');
  }
#endif

  ScoreboardHazardRecognizer::EmitInstruction(SU);
}

unsigned SIHazardRecognizer::PreEmitNoops(SUnit *SU) {
  MachineInstr *MI = SU->getInstr();

  if (MI->getOpcode() == AMDGPU::V_DIV_FMAS_F32 ||
      MI->getOpcode() == AMDGPU::V_DIV_FMAS_F64) {
//    assert(VALUWriteVCC >= 0 && VALUWriteVCC <= 4);
//    assert(VALUWriteVCC > 0 && VALUWriteVCC <= 4);
    DEBUG(dbgs() << "PreEmitNoops: " << VALUWriteVCC);
    return VALUWriteVCC;
  }

  return ScoreboardHazardRecognizer::PreEmitNoops(SU);
}

void SIHazardRecognizer::AdvanceCycle() {
  DEBUG(dbgs() << "Advance cycle: " << VALUWriteVCC << '\n');
#if 1
  if (VALUWriteVCC > 0) {
    if (--VALUWriteVCC == 0)
      LastMI = nullptr;

    DEBUG(dbgs() << "Advance cycle: dec to " << VALUWriteVCC << '\n');
  }
#endif

  ScoreboardHazardRecognizer::AdvanceCycle();
}

void SIHazardRecognizer::RecedeCycle() {
  llvm_unreachable("reverse SI hazard checking unsupported");
}

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

  if (VALUWriteVCC > 0) {
    if (MI->getOpcode() == AMDGPU::V_DIV_FMAS_F32 ||
        MI->getOpcode() == AMDGPU::V_DIV_FMAS_F64) {
      DEBUG(dbgs() << "Reporting no-op hazard " << VALUWriteVCC << '\n');
      return NoopHazard;
    }
  }

  return ScoreboardHazardRecognizer::getHazardType(SU, Stalls);
}

void SIHazardRecognizer::Reset() {
  LastMI = nullptr;
  VALUWriteVCC = 0;
  ScoreboardHazardRecognizer::Reset();
}

void SIHazardRecognizer::EmitInstruction(SUnit *SU) {
  MachineInstr *MI = SU->getInstr();

  if (MI->isDebugValue()) {
    ScoreboardHazardRecognizer::EmitInstruction(SU);
    return;
  }

  if (isVALUWriteVCC(MI)) {
    // Set to number of cycles until it is OK to issue v_div_fmas, it will be OK
    // to emit again once it reaches 0.
    DEBUG(dbgs() << "Is write to VCC: " << *MI << '\n');
    // XXX - Table says need to wait "4" but unclear 4 what.
    // We need to wait 1 more than this because we want to count from the end of
    // the write of vcc.
    VALUWriteVCC = 4;

    LastMI = MI;
  }

  ScoreboardHazardRecognizer::EmitInstruction(SU);
}

unsigned SIHazardRecognizer::PreEmitNoops(SUnit *SU) {
  MachineInstr *MI = SU->getInstr();

  if (MI->getOpcode() == AMDGPU::V_DIV_FMAS_F32 ||
      MI->getOpcode() == AMDGPU::V_DIV_FMAS_F64) {
    assert(VALUWriteVCC >= 0 && VALUWriteVCC <= 4);
    DEBUG(dbgs() << "PreEmitNoops: " << VALUWriteVCC << '\n');
    return VALUWriteVCC;
  }

  return ScoreboardHazardRecognizer::PreEmitNoops(SU);
}

void SIHazardRecognizer::AdvanceCycle() {
  if (VALUWriteVCC > 0) {
    if (--VALUWriteVCC == 0)
      LastMI = nullptr;

    DEBUG(dbgs() << "Advance cycle: dec to " << VALUWriteVCC << '\n');
  }

  ScoreboardHazardRecognizer::AdvanceCycle();
}

void SIHazardRecognizer::RecedeCycle() {
  llvm_unreachable("reverse SI hazard checking unsupported");
}

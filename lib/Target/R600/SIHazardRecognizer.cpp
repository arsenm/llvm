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
#include "llvm/Target/TargetRegisterInfo.h"
using namespace llvm;


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

#if 0
void SIHazardRecognizer::EmitNoop() {

}
#endif


ScheduleHazardRecognizer::HazardType
SIHazardRecognizer::getHazardType(SUnit *SU, int Stalls) {
  assert(Stalls == 0 && "SI hazards don't support scoreboard lookahead");
  MachineInstr *MI = SU->getInstr();

  if (MI->isDebugValue())
    return ScoreboardHazardRecognizer::getHazardType(SU, Stalls);

  if (isVALUWriteVCC(MI)) {
    VALUWriteVCC = 4;
  }

  if (VALUWriteVCC < 4) {
    if (MI->getOpcode() == AMDGPU::V_DIV_FMAS_F32 ||
        MI->getOpcode() == AMDGPU::V_DIV_FMAS_F64) {
      return NoopHazard;
    }
  }

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
  VALUWriteVCC = 0;
  ScoreboardHazardRecognizer::Reset();
}

void SIHazardRecognizer::EmitInstruction(SUnit *SU) {
  MachineInstr *MI = SU->getInstr();

  if (!MI->isDebugValue()) {
    LastMI = MI;
//    VALUWriteVCC = 0;
    --VALUWriteVCC;
  }

  ScoreboardHazardRecognizer::EmitInstruction(SU);
}

unsigned SIHazardRecognizer::PreEmitNoops(SUnit *SU) {
  MachineInstr *MI = SU->getInstr();

  if (MI->getOpcode() == AMDGPU::V_DIV_FMAS_F32 ||
      MI->getOpcode() == AMDGPU::V_DIV_FMAS_F64)
    return 1;

  return 0;
}


void SIHazardRecognizer::AdvanceCycle() {
  if (VALUWriteVCC && --VALUWriteVCC == 0) {
    // Stalled for 4 cycles but still can't schedule any other instructions.
    LastMI = nullptr;
  }

  ScoreboardHazardRecognizer::AdvanceCycle();
}

void SIHazardRecognizer::RecedeCycle() {
  llvm_unreachable("reverse SI hazard checking unsupported");
}

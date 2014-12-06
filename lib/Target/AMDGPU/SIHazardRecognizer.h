//===-- SIHazardRecognizer.h - SI Hazard Recognizers ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines hazard recognizers for scheduling SI functions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_SI_SIHAZARDRECOGNIZER_H
#define LLVM_LIB_TARGET_SI_SIHAZARDRECOGNIZER_H

#include "llvm/CodeGen/ScoreboardHazardRecognizer.h"

namespace llvm {

class SIInstrInfo;
struct SIRegisterInfo;
class SISubtarget;
class MachineInstr;

/// SIHazardRecognizer handles special constraints that are not expressed in
/// the scheduling itinerary.
class SIHazardRecognizer : public ScoreboardHazardRecognizer {
private:
  const SIInstrInfo *TII;
  const SIRegisterInfo *TRI;

  MachineInstr *LastMI;
  unsigned VALUWriteVCC;

  bool isVALUWriteVCC(MachineInstr *MI) const;
  bool isFMASAfterVALUWriteVCC(SUnit *SU) const;

public:
  SIHazardRecognizer(const InstrItineraryData *ItinData, const ScheduleDAG *DAG);

  //void EmitNoop() override;
  HazardType getHazardType(SUnit *SU, int Stalls) override;
  void Reset() override;
  void EmitInstruction(SUnit *SU) override;
  unsigned PreEmitNoops(SUnit *SU) override;
  void AdvanceCycle() override;
  void RecedeCycle() override;
};

} // end namespace llvm

#endif

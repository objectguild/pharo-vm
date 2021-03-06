tests
testMoveRAwTrap1
	"Write a register to a constant address that is below-range."
	
	"self new testMoveRAwTrap1"
	| memory |
	memory := self memory.
	self processor reset.

	"LEA sl, #16r1FC"
	memory unsignedLongAt: 5 put: (CogARMCompiler new mov: 10 imm: 0 ror: 0)  bigEndian: false. 
	memory unsignedLongAt: 9 put: (CogARMCompiler new orr: 10 imm: 0 ror: 0) bigEndian: false.
	memory unsignedLongAt: 13 put: (CogARMCompiler new orr: 10 imm: 1 ror: 24) bigEndian: false. 
	memory unsignedLongAt: 17 put: (CogARMCompiler new orr: 10 imm: 16rFC ror: 0) bigEndian: false. 
	"STR R5, [sl]"
	memory unsignedLongAt: 21 put: (CogARMCompiler new str: 5 rn: 10 plusImm: 0) bigEndian: false.

	
	"processor disassembleFrom: 0 to: 60 in: memory on: Transcript cr"
	self processor
			pc: 4;
			sp: (memory size - 4); "Room for return address"
			r5: 99;
			singleStepIn: memory readExecuteOnlyBelow: memory size / 2.
			"We have to step several times, because the first step only changes the pc, but does not fetch anything from the address it points to."
	
	self should: [self processor singleStepIn: memory readExecuteOnlyBelow: memory size / 2.
				self processor singleStepIn: memory readExecuteOnlyBelow: memory size / 2.
				self processor singleStepIn: memory readExecuteOnlyBelow: memory size / 2.
				self processor singleStepIn: memory readExecuteOnlyBelow: memory size / 2.
				self processor singleStepIn: memory readExecuteOnlyBelow: memory size / 2]
		raise: ProcessorSimulationTrap
		withExceptionDo:
			[:pst|
			self assert: self processor pc = 16r14.
			self assert: pst pc = 16r14.
			self assert: pst nextpc = 16r18.
			self assert: pst address = 16r1FC.
			self assert: pst type = #write]
inline primitive generators generated code
genLowcodeFirstIndexableFieldPointer
	<option: #LowcodeVM>
	<inline: true>
	"Generated by the Lowcode instruction generator."
	| object |
	self allocateRegistersForLowcodeOop: [:objectValue |
		object := objectValue.
	].

	self ssTop popToReg: object.
	self ssPop: 1.

	objectRepresentation genLcFirstIndexableFieldPointer: object.

	^ 0


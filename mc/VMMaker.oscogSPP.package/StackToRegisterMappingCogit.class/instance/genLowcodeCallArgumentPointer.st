inline primitive generators generated code
genLowcodeCallArgumentPointer
	<option: #LowcodeVM>	"Lowcode instruction generator"

	self ssNativeTop nativeStackPopToReg: TempReg.
	self ssNativePop: 1.
	self PushR: TempReg.
	currentCallCleanUpSize := currentCallCleanUpSize + BytesPerWord.

	^ 0


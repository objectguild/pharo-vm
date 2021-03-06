primitives
primitiveMPEG3EndOfAudio: fileHandle stream: aNumber
	| file result |

	"int mpeg3_end_of_audio(mpeg3_t *file, int stream)"
	<var: #file type: 'mpeg3_t * '>
	self primitive: 'primitiveMPEG3EndOfAudio'
		parameters: #(Oop SmallInteger).

	file := self mpeg3tValueOf: fileHandle.
	file = nil ifTrue: [^0].
	aNumber < 0 ifTrue: [interpreterProxy success: false. ^nil].
	aNumber >= (self cCode: 'result = mpeg3_total_astreams(file)') ifTrue: [
		interpreterProxy success: false.  ^0 ].

	self cCode: 'result = mpeg3_end_of_audio(file,aNumber)'.
	^result asOop: Boolean

compaction
updatePointersInMobileObjects
	"Sweep the mobile portion of the heap, updating all references to objects to their eventual locations.
	 Remember to update the savedFirstFields of pointer objects, as these have been forwarded.
	 Answer if the end of the heap was reached (savedFirstFieldsSpace has not overflowed).

	 The enumerations in planCompactSavingForwarders, updatePointersInMobileObjects and copyAndUnmarkMobileObjects
	 match.  We could implement them as a single enumeration method taking several block arguments, but arguably that
	 would make understanding an already tricky algorithm more difficult.  Instead we tolerate the duplication and encourage
	 the reader to diff the three methods to see where they diverge (e.g. via Cmd-shift-C)."
	| toFinger top previousPin |
	<var: 'top' type: #usqInt>
	<var: 'toFinger' type: #usqInt>
	self deny: (manager isMarked: firstFreeObject).
	toFinger := manager startOfObject: firstFreeObject.
	top := savedFirstFieldsSpace start.
	manager allOldSpaceEntitiesFrom: firstFreeObject do:
		[:o|
		 self check: o.
		 self assert: (previousPin
						ifNil: [toFinger <= (manager startOfObject: o)]
						ifNotNil: [(manager isMarked: previousPin) and: [toFinger <= (manager startOfObject: previousPin)]]).
		 (manager isMarked: o) ifTrue:
			[(manager isPinned: o)
				ifTrue:
					[previousPin ifNil:
						[previousPin := o].
					 self updatePointersIn: o]
				ifFalse:
					[| availableSpace bytes |
					 bytes := manager bytesInObject: o.
					 [previousPin notNil
					  and: [availableSpace := (manager startOfObject: previousPin) - toFinger.
							bytes ~= availableSpace
							and: [bytes + (2 * manager allocationUnit) > availableSpace]]] whileTrue:
						["The object does not fit in the space between toFinger and previousPin.
						   Move toFinger up to point at the first unmarked or mobile object after
						   previousPin, or, if previousPin is contiguous with o, to the start of this
						   object.  Update previousPin to be the next pinned object above toFInger
						   and below this object, or nil if no such pinned object exists.
						   Any unfillable gaps between adjacent pinned objects will be freed."
					 	 [toFinger := manager addressAfter: previousPin.
						  previousPin := manager objectStartingAt: toFinger.
						  (manager isMarked: previousPin)
						   and: [(manager isPinned: previousPin)
						   and: [previousPin < o]]]
							whileTrue.
						 "Now previousPin is either equal to o or mobile.
						  Move it to the next pinned object below o"
						 [previousPin >= o
						  or: [(manager isMarked: previousPin)
						  and: [manager isPinned: previousPin]]] whileFalse:
							[previousPin := manager objectAfter: previousPin].
						 previousPin >= o ifTrue:
							[previousPin := nil]].
					 self updatePointersIn: o savedFirstFieldPointer: top.
					 toFinger := toFinger + bytes.
					 (top := top + manager bytesPerOop) >= savedFirstFieldsSpace limit ifTrue:
						[self assert: savedFirstFieldsSpace top = (top - manager bytesPerOop).
						 ^self noMobileObjectsAfter: o]]]].
	self assert: savedFirstFieldsSpace top = (top - manager bytesPerOop).
	^true
debug printing
printOopsSuchThat: function
	<api>
	<var: #function declareC: 'sqInt (*function)(sqInt)'>
	<inline: #never>
	| n |
	n := 0.
	self allHeapEntitiesDo:
		[:o|
		(self perform: function with: o) ifTrue:
			[n := n + 1.
			 self printEntity: o]].
	n > 4 ifTrue: "rabbits"
		[self printNum: n; print: ' objects'; cr]
debug support
recordTrace: classOrInteger thing: selector source: source
	traceLog at: traceLogIndex put: classOrInteger.
	traceLog at: traceLogIndex + 1 put: selector.
	traceLog at: traceLogIndex + 2 put: source.
	traceLogIndex := traceLogIndex + 3 \\ TraceBufferSize
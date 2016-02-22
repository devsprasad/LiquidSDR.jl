

immutable IIRFilter
	filterobjPtr::Ptr{Void}
end

function Base.display(filt::IIRFilter)
	ccall((:iirfilt_crcf_print,"libliquid"), Void, (Ptr{Void}, ), filt.filterobjPtr);
end

function createiirfilter(b::Array{Complex64}, a::Array{Complex64})
	ptr = ccall((:iirfilt_crcf_create, "libliquid"), Ptr{Void}, (Ptr{Complex64}, UInt, Ptr{Complex64}, UInt), 
		b,length(b), a, length(a));
	return IIRFilter(ptr);
end


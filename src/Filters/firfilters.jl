module FIRFilters

export FIRFilter, createfirfilter

immutable FIRFilter
	filtobjPtr::Ptr{Void}
end

function Base.display(filt::FIRFilter)
	ccall((:firfilt_crcf_print, "libliquid"), Void, (Ptr{Void}, ), filt.filtobjPtr)
end

function createfirfilter(h::Array{Complex64})
	ms = ccall((:firfilt_crcf_create, "libliquid"), Ptr{Void}, (Ptr{Complex64},Int), h,length(h));
	return FIRFilter(ms);

end

function recreatefirfilter()
end
end
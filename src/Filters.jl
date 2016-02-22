module Filters

export createfirfilt

immutable FirFilter
	filtobjPtr::Ptr{Void}
end

function createfirfilt(h::Array{Complex64})
	ms = ccall((:firfilt_crcf_create, "libliquid"), Ptr{Void}, (Ptr{Complex64},Int), h,length(h));
	return FirFilter(ms);

end

function recreatefirfilter()

end
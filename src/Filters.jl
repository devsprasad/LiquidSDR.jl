module Filters

export createfirfilt

function createfirfilt(h::Array{Complex64})
	ms = ccall((:firfilt_crcf_create, "libliquid"), Ptr{Void}, (Ptr{Complex64},Int), h,length(h));
	return ms;

end

end
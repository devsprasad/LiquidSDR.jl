module Filters

include("Filters/firfilters.jl")
export 	FIRFilter, 
		createfirfilter


include("Filters/iirfilters.jl")
export 	IIRFilter,
		createiirfilter,
		butterworth,
		cheby1,
		cheby2,
		ellip,
		bessel

export 	applyfilter,
		freqz

function applyfilter(filt::IIRFilter, x::Float64)
	y = Cfloat[0];
	ccall((:iirfilt_rrrf_execute, "libliquid"), Void, (Ptr{Void}, Cfloat, Ptr{Cfloat}), filt.filterobjPtr,
		Cfloat(x), y);
	return y[1];
end


function applyfilter(filt::IIRFilter, x::Array{Float64})
	y = Array(Float64, length(x));
	for i in range(1,length(x))
		y[i] = applyfilter(filt, x[i]);
	end
	return y;
end


function freqz(filt::IIRFilter, fc::Float64)
	h_len = ccall((:iirfilt_rrrf_get_length, "libliquid"), Int, (Ptr{Void}, ) , filt.filterobjPtr);
	response = Array(Cfloat, h_len)
	ccall((:iirfilt_rrrf_freqresponse, "libliquid"), Void, (Ptr{Void} , Cfloat, Ptr{Cfloat}), 
		filt.filterobjPtr, Cfloat(fc), response)
	return response;
end


end
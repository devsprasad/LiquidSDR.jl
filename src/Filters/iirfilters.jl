

immutable IIRFilter
	filterobjPtr::Ptr{Void}
end

function Base.display(filt::IIRFilter)
	ccall((:iirfilt_rrrf_print,"libliquid"), Void, (Ptr{Void}, ), filt.filterobjPtr);
end

function createiirfilter(b::Array{Float32}, a::Array{Float32})
	ptr = ccall((:iirfilt_rrrf_create, "libliquid"), Ptr{Void}, (Ptr{Float32}, UInt, Ptr{Float32}, UInt), 
		b,length(b), a, length(a));
	return IIRFilter(ptr);
end

@enum IIRFType BUTTER=0 CHEBY1 CHEBY2 ELLIP BESSEL
@enum IIRBType LPF=0 HPF BPF BSF

function getftype(input::AbstractString)
	if(input in ["lo", "low", "lowpass", "lpf"])
		return LPF
	elseif(input in ["hi","high", "hpf","highpass"])
		return HPF
	elseif(input in ["band", "bandpass", "bpf"])
		return BPF
	elseif(input in ["bandstop", "bsf"])
		return BSF
	else
		error("invalid band-type: " , input)
	end
end

function iir_filt(fc::Float64, f0::Float64, dtype::IIRFType,	band::AbstractString = "lpf", 
	order::Int = 10,   Ap::Float64=1.0, As::Float64=60.0)
    btype = getftype(band);
	N = order;
	if(btype == BPF || btype == BSF)
		N = 2*order;
	end
	# r = N % 2;
	# L = (N-r) / 2;
	B = Array(Cfloat, Int(N+1));
	A = Array(Cfloat, Int(N+1));
	if(fc<=0.0 || fc>=0.5)
		error("cut-off frequency must be normalized and in range (0,0.5)")
	end
	if(f0<=0.0 || f0>=0.5)
		error("center frequency must be normalized and in range (0,0.5)")
	end	
	ccall((:liquid_iirdes, "libliquid"), Void, (UInt, UInt, UInt, UInt, Cfloat,Cfloat,Cfloat,Cfloat,Ptr{Cfloat},Ptr{Cfloat}), 
		dtype, btype, 1, N, Cfloat(fc), Cfloat(f0), Cfloat(Ap), Cfloat(As), B,A);
	return B,A
end


# liquid_iirdes(_ftype, _btype, _format, _n, _fc, _f0, _Ap, _As, *_B, *_A);
function butterworth(fc::Float64, f0::Float64, 	band::AbstractString = "lpf", 
	order::Int = 10,   Ap::Float64=1.0, As::Float64=60.0)
	B,A = iir_filt(fc, f0, BUTTER, band, order, Ap, As )
end



function cheby1(fc::Float64, f0::Float64, 	band::AbstractString = "lpf", 
	order::Int = 10,   Ap::Float64=1.0, As::Float64=60.0)
	B,A = iir_filt(fc, f0, CHEBY1, band, order, Ap, As )
end

function cheby2(fc::Float64, f0::Float64, 	band::AbstractString = "lpf", 
	order::Int = 10,   Ap::Float64=1.0, As::Float64=60.0)
	B,A = iir_filt(fc, f0, CHEBY2, band, order, Ap, As )
end

function ellip(fc::Float64, f0::Float64, 	band::AbstractString = "lpf", 
	order::Int = 10,   Ap::Float64=1.0, As::Float64=60.0)
	B,A = iir_filt(fc, f0, ELLIP, band, order, Ap, As )
end

function bessel(fc::Float64, f0::Float64, 	band::AbstractString = "lpf", 
	order::Int = 10,   Ap::Float64=1.0, As::Float64=60.0)
	B,A = iir_filt(fc, f0, BESSEL, band, order, Ap, As )
end
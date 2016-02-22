module Modems

export Modem, createmodem, modulate, demodulate,display,
       getbps,getM, destroy, count_biterrors, PSK, DPSK, 
       ASK, QAM, phaseerror, evm


const PSK="PSK"
const DPSK="DPSK"
const ASK="ASK"
const QAM="QAM"

immutable Modem
	scheme::AbstractString
	M::Int
	modemObjPtr::Ptr{Void}
end


# function pskmodemPtr(M::Int)
# 	scheme = round(Int,log2(M));
# 	m = ccall((:modem_create,"libliquid"), Ptr{Void}, (Int32, ), scheme);
# end

# function dpskmodemPtr(M::Int)
# 	scheme = round(Int,log2(M)) + 8;
# 	m = ccall((:modem_create,"libliquid"), Ptr{Void}, (Int32, ), scheme);
# end

# function askmodemPtr(M::Int)
# 	scheme = round(Int,log2(M)) + 16;
# 	m = ccall((:modem_create,"libliquid"), Ptr{Void}, (Int32, ), scheme);
# end

# function qammodemPtr(M::Int)
# 	scheme = round(Int, log2(M))
# 	if(scheme <= 1)
# 	  error("QAM2 is not possible")
# 	else
# 		scheme = scheme + 23;
# 		m = ccall((:modem_create,"libliquid"), Ptr{Void}, (Int32, ), scheme);
# 		return m;
# 	end
# end



function createmodem(scheme::AbstractString)
	ms = ccall((:liquid_getopt_str2mod, "libliquid"), Int, (Ptr{UInt8},), scheme);
	if(ms==0)
		error("unknown modulation scheme : ", scheme );
	else
		modem = ccall((:modem_create, "libliquid"), Ptr{Void}, (Int,), ms);
		bps   = ccall((:modem_get_bps, "libliquid"), Int, (Ptr{Void}, ), modem);
		M = 1 << bps;
		return Modem(scheme, M, modem);
	end
end




function Base.display(modem::Modem)
	ccall((:modem_print, "libliquid"), Void, (Ptr{Void}, ), modem.modemObjPtr);
end

function getbps(modem::Modem)
	bps = ccall((:modem_get_bps, "libliquid"), Int, (Ptr{Void}, ), modem.modemObjPtr);
	return bps;
end

function getM(modem::Modem)
	return modem.M;
end

function destroy(modem::Modem)
	ccall((:modem_destroy, "libliquid"), Void, (Ptr{Void}, ), modem.modemObjPtr);
end


function modulate(modem::Modem , symbol::Int)
	y = Complex64[0];
	M = modem.M;
	if(symbol > (M-1))
		error("symbol exceeds constellation size (maximum = " , (M-1), ")");
	end
	ccall((:modem_modulate, "libliquid"), Void, (Ptr{Void}, Int, Ptr{Complex64}), 
		modem.modemObjPtr , symbol, y);
	return y[1];
end

function modulate(modem::Modem, symbols::Array{Int})
	y = Array(Complex64,length(symbols));
	for i in range(1, length(symbols))
		y[i] = modulate(modem, symbols[i]);
	end
	return y;
end

function modulate(modem::Modem, symbols::Range{Int})
	y = Array(Complex64,length(symbols));
	index = 1
	for i in symbols
		y[index] = modulate(modem, i);
		index += 1;
	end
	return y;
end

function demodulate(modem::Modem, mod::Complex64)
	x = Array(Int, 1);
	ccall((:modem_demodulate, "libliquid"), Void, (Ptr{Void}, Complex64, Ptr{Int}), 
		modem.modemObjPtr , mod, x );
	return x[1];
end

function demodulate(modem::Modem, mods::Array{Complex64})
	y = Array(Int,length(mods));
	for i in range(1, length(mods))
		y[i] = demodulate(modem.modemObjPtr, mods[i]);
	end
	return y;
end

function count_biterrors(x::Int, y::Int)
	err = ccall((:count_bit_errors, "libliquid"), Int, (Int, Int), x,y );
	return err;
end

function count_biterrors(x::Array{Int}, y::Array{Int})
	if(length(x) == length(y))
		errors = Array(Int, length(x))
		for i in range(1,length(x))
			errors[i] = count_biterrors(x[i], y[i]);
		end
		return errors;
	else
		error("x and y must be of same length")
	end
end


function phaseerror(modem::Modem)
	ccall((:modem_get_demodulator_phase_error, "libliquid"), Float64, (Ptr{Void},), modem.modemObjPtr);
end

function evm(modem::Modem)
	ccall((:modem_get_demodulator_evm, "libliquid"), Float64, (Ptr{Void}, ), modem.modemObjPtr);
end

end

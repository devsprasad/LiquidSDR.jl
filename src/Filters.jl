module Filters

include("Filters/firfilters.jl")
export 	FIRFilter, 
		createfirfilter


include("Filters/iirfilters.jl")
export 	IIRFilter,
		createiirfilter




end
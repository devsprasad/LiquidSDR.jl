
using LiquidSDR
using PyPlot


fs = 1000; # sampling frequency


# test signal generation
t = 0:1.0/fs:1;
s1 = sin(2*pi*t*10);  # 10Hz sinusoid
s2 = sin(2*pi*t*100); # 100Hz sinusoid
s = s1+s2; # mixed signal


# let's build butterworth filter
fc = 50.0 / fs; # normalized cut-off frequency (50Hz)
f0 = 51.0 / fs; # f0 is not considered for Low-Pass filters( so using a dummy value)
b,a = butterworth(fc, f0);

filt = createiirfilter(b,a);


# let's try to remove 100Hz component!
sig_result = applyfilter(filt, s);
plot(t, sig_result);

using Interpolations
using FourierTools
using PyCall

PyCall.fixqtpath()
plt = pyimport("matplotlib.pyplot")

X0 = range(-10, 10, 1000)

Y0 = exp.(-X0 .^ 2 ./ 5) .+ (rand(1000) .- 0.5) .* 0.1

X1 = range(-10, 10, 100)
X1T = X1[1:99]
LinItp = LinearInterpolation(X0, Y0)
Y1 = LinItp(X1)
Y2 = resample(Y0, 99)


Fig, Axes = plt.subplots(3, 1, sharex = true, figsize = (6, 8))

Axes[2].set_title("example original data")
Axes[1].plot(X0, Y0, label = "noisy gaussian")
Axes[1].legend()

Axes[2].set_title("Interpolations package")
Axes[2].plot(X1, Y1, label = "linear interpolation")
Axes[2].legend()

Axes[3].set_title("FourierTools package")
Axes[3].plot(X1T,Y2,label = "sinc interpolation")
Axes[3].legend()

plt.show()
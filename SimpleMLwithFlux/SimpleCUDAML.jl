using Flux, Images, MLDatasets
using Flux: crossentropy, onecold, onehotbatch, train!, params
using BSON: @save
using LinearAlgebra, Random, Statistics
using CUDA
# using GLMakie

# function DisplayImage(XTrainRaw, YTrainRaw, Index)
#     IMG = XTrainRaw[:, :, Index]
#     Number = YTrainRaw[Index]

#     Fig = Figure()
#     Axe = GLMakie.Axis(Fig[1, 1], yreversed = true, aspect = DataAspect(), title = "The number is $(Number)")
#     image!(Axe, collect(IMG))
#     wait(display(Fig))

#     return 0
# end

XTrainRaw, YTrainRaw = MLDatasets.MNIST.traindata(Float32)
XTestRaw, YTestRaw = MLDatasets.MNIST.testdata(Float32)

# DisplayImage(XTrainRaw, YTrainRaw, 151)
# DisplayImage(XTestRaw, YTestRaw, 151)

XTrain = Array{eltype(XTrainRaw)}(undef, size(XTrainRaw)[1:2]..., 1, size(XTrainRaw)[end])
XTrain[:, :, 1, :] = XTrainRaw
XTest = Array{eltype(XTestRaw)}(undef, size(XTestRaw)[1:2]..., 1, size(XTestRaw)[end])
XTest[:, :, 1, :] = XTestRaw

YTrain = onehotbatch(YTrainRaw, 0:9)
YTest = onehotbatch(YTestRaw, 0:9)

cuXTrain = CuArray(XTrain)
cuYTrain = CuArray(YTrain)

BoxN = 28
PoolN = 2
ConvOCN = 2
cuModel =
    Chain(
        Conv((2, 2), 1 => ConvOCN, relu, pad = SamePad()),
        Conv((2, 2), ConvOCN => ConvOCN, relu, pad = SamePad()),
        MaxPool((PoolN, PoolN), pad = SamePad()),
        Flux.flatten,
        Dense(div(BoxN, PoolN)^2 * ConvOCN, 32, relu),
        Dense(32, 10),
        softmax,
    ) |> gpu
Loss(X, Y) = crossentropy(cuModel(X), Y)
PS = params(cuModel)

LearningRate = 0.01
OPT = ADAM(LearningRate)

LossHistory = Float64[]
Epochs = 500

for Epoch = 1:Epochs
    train!(Loss, PS, [(cuXTrain, cuYTrain)], OPT)
    TrainLoss = Loss(cuXTrain, cuYTrain)
    push!(LossHistory, TrainLoss)
    println("$(Epoch) Epoch, Training Loss = $(TrainLoss)")
end

Model = cpu(cuModel)
@save "$(@__FILE__).bson" Model

YHotPredict = Model(XTest)
YPredict = onecold(YHotPredict) .- 1

CorrectRate = mean(YPredict .== YTestRaw)
@show CorrectRate

using QuantumOptics
# using GLMakie
using CairoMakie
using LinearAlgebra
using IterativeSolvers

# 1  2  3  4  5
# 6  7  8  9  10
#    11 12 13

Oc = 10.0
Op = 0.001

CP = sqrt(2) * Oc * 1.0
CL = 1.0 * Oc * 0.0
CR = 1.0 * Oc * 0.0

PP = sqrt(2) * Op * 0.0
PL = 1.0 * Op * 1.0
PR = 1.0 * Op * 1.0

Dc = 0.0

function SState(Dp)
    HilbertSpace = NLevelBasis(13)

    H = 0.0 * transition(HilbertSpace, 1, 1)

    S1_6 = -1 / sqrt(3) * CP * transition(HilbertSpace, 1, 6)
    S2_7 = -1 / sqrt(12) * CP * transition(HilbertSpace, 2, 7)
    S4_9 = +1 / sqrt(12) * CP * transition(HilbertSpace, 4, 9)
    S5_10 = +1 / sqrt(3) * CP * transition(HilbertSpace, 5, 10)

    H += S1_6 + S2_7 + S4_9 + S5_10

    S2_6 = +1 / sqrt(6) * CL * transition(HilbertSpace, 2, 6)
    S3_7 = +1 / sqrt(4) * CL * transition(HilbertSpace, 3, 7)
    S4_8 = +1 / sqrt(4) * CL * transition(HilbertSpace, 4, 8)
    S5_9 = +1 / sqrt(6) * CL * transition(HilbertSpace, 5, 9)

    H += S2_6 + S3_7 + S4_8 + S5_9

    S1_7 = -1 / sqrt(6) * CR * transition(HilbertSpace, 1, 7)
    S2_8 = -1 / sqrt(4) * CR * transition(HilbertSpace, 2, 8)
    S3_9 = -1 / sqrt(4) * CR * transition(HilbertSpace, 3, 9)
    S4_10 = -1 / sqrt(6) * CR * transition(HilbertSpace, 4, 10)

    H += S1_7 + S2_8 + S3_9 + S4_10

    S2_11 = 1 / sqrt(4) * PP * transition(HilbertSpace, 2, 11)
    S3_12 = 1 / sqrt(3) * PP * transition(HilbertSpace, 3, 12)
    S4_13 = 1 / sqrt(4) * PP * transition(HilbertSpace, 4, 13)

    H += S2_11 + S3_12 + S4_13

    S3_11 = -1 / sqrt(12) * PL * transition(HilbertSpace, 3, 11)
    S4_12 = -1 / sqrt(4) * PL * transition(HilbertSpace, 4, 12)
    S5_13 = -1 / sqrt(2) * PL * transition(HilbertSpace, 5, 13)

    H += S3_11 + S4_12 + S5_13

    S1_11 = -1 / sqrt(2) * PR * transition(HilbertSpace, 1, 11)
    S2_12 = -1 / sqrt(4) * PR * transition(HilbertSpace, 2, 12)
    S3_13 = -1 / sqrt(12) * PR * transition(HilbertSpace, 3, 13)

    H += S1_11 + S2_12 + S3_13

    H += dagger(H)

    for i = 1:5
        H += -Dp * transition(HilbertSpace, i, i)
    end

    for i = 6:10
        H += (Dc - Dp) * transition(HilbertSpace, i, i)
    end

    ###################################################################

    JOperator = Any[]

    push!(JOperator, 1 / sqrt(3) * transition(HilbertSpace, 6, 1))
    JOperator[1] += 1 / sqrt(12) * transition(HilbertSpace, 7, 2)
    JOperator[1] += 1 / sqrt(12) * transition(HilbertSpace, 9, 4)
    JOperator[1] += 1 / sqrt(3) * transition(HilbertSpace, 10, 5)

    JOperator[1] += 1 / sqrt(6) * transition(HilbertSpace, 6, 2)
    JOperator[1] += 1 / sqrt(4) * transition(HilbertSpace, 7, 3)
    JOperator[1] += 1 / sqrt(4) * transition(HilbertSpace, 8, 4)
    JOperator[1] += 1 / sqrt(6) * transition(HilbertSpace, 9, 5)

    JOperator[1] += 1 / sqrt(6) * transition(HilbertSpace, 7, 1)
    JOperator[1] += 1 / sqrt(4) * transition(HilbertSpace, 8, 2)
    JOperator[1] += 1 / sqrt(4) * transition(HilbertSpace, 9, 3)
    JOperator[1] += 1 / sqrt(6) * transition(HilbertSpace, 10, 4)

    push!(JOperator, 1 / sqrt(4) * transition(HilbertSpace, 11, 2))
    JOperator[2] += 1 / sqrt(3) * transition(HilbertSpace, 12, 3)
    JOperator[2] += 1 / sqrt(4) * transition(HilbertSpace, 13, 4)

    JOperator[2] += 1 / sqrt(12) * transition(HilbertSpace, 11, 3)
    JOperator[2] += 1 / sqrt(4) * transition(HilbertSpace, 12, 4)
    JOperator[2] += 1 / sqrt(2) * transition(HilbertSpace, 13, 5)

    JOperator[2] += 1 / sqrt(2) * transition(HilbertSpace, 11, 1)
    JOperator[2] += 1 / sqrt(4) * transition(HilbertSpace, 12, 2)
    JOperator[2] += 1 / sqrt(12) * transition(HilbertSpace, 13, 3)

    # for i in 1:10
    #     push!(JOperator, 0.05 * transition(HilbertSpace, i, i))
    # end

    ###################################################################

    POperator = Any[]

    push!(POperator, 1 / sqrt(4) * transition(HilbertSpace, 2, 11))
    POperator[1] += 1 / sqrt(3) * transition(HilbertSpace, 3, 12)
    POperator[1] += 1 / sqrt(4) * transition(HilbertSpace, 4, 13)

    push!(POperator, -1 / sqrt(12) * transition(HilbertSpace, 3, 11))
    POperator[2] += -1 / sqrt(4) * transition(HilbertSpace, 4, 12)
    POperator[2] += -1 / sqrt(2) * transition(HilbertSpace, 5, 13)

    push!(POperator, -1 / sqrt(2) * transition(HilbertSpace, 1, 11))
    POperator[3] += -1 / sqrt(4) * transition(HilbertSpace, 2, 12)
    POperator[3] += -1 / sqrt(12) * transition(HilbertSpace, 3, 13)

    ###################################################################

    H = DenseOperator(H)
    JOperator = DenseOperator.(JOperator)

    Rho0 = 0.0 * transition(HilbertSpace, 1, 1)
    for i = 11:13
        Rho0 += 1.0 * transition(HilbertSpace, i, i)
    end
    normalize!(Rho0)

    rho_ss = steadystate.iterative!(Rho0, H, JOperator, gmres!)

    Sum = zeros(ComplexF64, 3)
    for i in eachindex(POperator)
        Sum[i] += expect(POperator[i], rho_ss)
    end

    return Sum ./ Op
end

DpAxis = collect(range(-20, 20, 1001))
Response = SState.(DpAxis)
Response = hcat(Response...)

Fig = Figure(resolution = (400, 300))
Axe = Axis(Fig[1, 1], xlabel = "probe detune", ylabel = "absorption rate")
LabelSet = ["P", "L", "R"]
for i = 1:3
    lines!(Axe, DpAxis, imag.(Response[i, :]), label = LabelSet[i])
end
axislegend(Axe)
save(join([splitext(@__FILE__)[end-1], ".svg"]), Fig)
save(join([splitext(@__FILE__)[end-1], ".png"]), Fig)
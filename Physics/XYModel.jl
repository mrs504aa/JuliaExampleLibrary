using CairoMakie

function neighbor_particles(i, j, n)
    [(mod1(i + 1, n), j), (mod1(i - 1, n), j), (i, mod1(j + 1, n)), (i, mod1(j - 1, n))]
end

function xy_model(N, Temperature, Steps)
    J = 1.0
    Grid = rand(N, N) * 2pi
    Energy = 0.0
    for i = 1:N, j = 1:N
        for (ni, nj) in neighbor_particles(i, j, N)
            Energy += -J * cos(Grid[i, j] - Grid[ni, nj])
        end
    end

    for step = 1:Steps
        for i = 1:N, j = 1:N
            old_theta = Grid[i, j]
            new_theta = old_theta + randn() * sqrt(Temperature)
            dE =
                -J *
                sum([cos(new_theta - Grid[ni, nj]) - cos(old_theta - Grid[ni, nj]) for (ni, nj) in neighbor_particles(i, j, N)])
            if dE < 0 || rand() < exp(-dE / Temperature)
                Grid[i, j] = new_theta
                Energy += dE
            end
        end
    end

    return (Grid, Energy)
end

N = 25
T = 0.0002
steps = 1000

Grid, Energy = xy_model(N, T, steps)

Grid = mod2pi.(Grid)

Fig = Figure(resolution = (800, 800))
Axe = Axis(Fig[1, 1], backgroundcolor = :black)

X = zeros(N^2)
Y = zeros(N^2)
U = zeros(N^2)
V = zeros(N^2)
C = zeros(N^2)
for i = 1:N
    for j = 1:N
        Index = (i - 1) * N + j
        X[Index] = i
        Y[Index] = j
        U[Index] = cos(Grid[i, j])
        V[Index] = sin(Grid[i, j])
        C[Index] = Grid[i, j] / 2pi
    end
end

arrows!(X, Y, U, V, arrowsize = 10, lengthscale = 0.3, colormap = :viridis, arrowcolor = C, linecolor = C)

save("XYModel.pdf", Fig)
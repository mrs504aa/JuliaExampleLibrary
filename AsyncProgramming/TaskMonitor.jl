"""
From https://discourse.julialang.org/t/printing-in-a-background-process/81453
"""

mutable struct Status
    on::Bool
end

function Printer(S::Status)
    println("Printer turning on")
    while S.on
        println("PRINTING")
        sleep(0.5)
    end
    println("Printer turning off")
end

function Doer()  
    S = Status(true)

    @sync begin
        Base.Threads.@spawn Printer(S)
    
        for k in 1:50000
            x = rand(100, 100)
            y = x.^2 .- rand(100, 100)
            yield()
        end
        S.on = false
    end
    
    return nothing
end

Doer()
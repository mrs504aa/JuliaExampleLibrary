"""
From https://discourse.juliacn.com/t/topic/6289/10?u=mrs504aa
"""
function ReadData(Chan::Channel)
    while isopen(Chan)
        S = readline()
        if S == "exit"
            close(Chan)
        end
        put!(Chan, S)
        yield()
    end
    return 0
end

function Process(Chan::Channel)
    while isopen(Chan)
        S = take!(Chan)
        println(S)
        yield()
    end
end

Chan = Channel{Any}(Inf)

Threads.@spawn ReadData(Chan)
Threads.@spawn Process(Chan)

while isopen(Chan)
    sleep(1.0)
end
Base.@kwdef mutable struct Student
    Name::String = "Alice"
    Age::Int64 = 18
    PrintInfo::Function = function()
        println("Student Name: $Name\nAge: $Age")
    end
end

NewStudent = Student()
NewStudent.PrintInfo()
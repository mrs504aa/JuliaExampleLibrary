mutable struct Student
    Name::String
    Age::Int64
    PrintInfo::Function
    function Student(Name::String, Age::Int64)
        Object = new()
        Object.Name = Name
        Object.Age = Age
        Object.PrintInfo = function()
            println("Student Name: $Name\nAge: $Age")
        end
        return Object
    end
    Student() = Student("Alice", 18)
end

NewStudent = Student()
NewStudent.PrintInfo()
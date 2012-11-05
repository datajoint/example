%{
example.Sessions (manual) # list of experimental sessions

-> example.Subjects
session_date                : date                  # session date
---
experimenter                : enum('Alice', 'Bob')  # name of person running exp
session_path = "C:\data"    : varchar(255)          # path to the data
%}

classdef Sessions < dj.Relvar
    properties(Constant)
        table = dj.Table('example.Sessions');
    end
end

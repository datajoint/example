%{
example.GratingTrials (manual) # List of trials for grating stimulus

-> example.Gratings
trial_num           : int       # trial number
---
stimulus_onset      : double    # time of stimulus onset (ms)
direction           : double    # direction of motion (degrees, orthogonal to orientation)
%}

classdef GratingTrials < dj.Relvar
    properties(Constant)
        table = dj.Table('example.GratingTrials');
    end
end

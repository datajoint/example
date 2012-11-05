%{
example.Gratings (manual) # List of grating stimuli that were shown

-> example.Ephys
---
stimulus_duration   : int       # length of stimulus duration (ms)
speed               : double    # drift speed (cycles/sec)
spatial_freq        : double    # spatial frequency (cycles/degree)
%}

classdef Gratings < dj.Relvar
    properties(Constant)
        table = dj.Table('example.Gratings');
    end
    
    methods 
        function self = Gratings(varargin)
            self.restrict(varargin{:})
        end
    end
end

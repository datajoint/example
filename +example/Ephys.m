%{
example.Ephys (manual)      # electrophysiology recordings

-> example.Sessions
ephys_start     : time      # time when recording was started
---
sampling_rate   : double    # sampling rate of recording
gain            : double    # multiplier to convert to muV
%}

classdef Ephys < dj.Relvar
    properties(Constant)
        table = dj.Table('example.Ephys');
    end
    
    methods 
        function self = Ephys(varargin)
            self.restrict(varargin{:})
        end
    end
end

%{
example.Ephys (manual)       # electrophysiology recordings

-> example.Sessions
ephys_num       : tinyint unsigned  # ephys recording number within session
---
ephys_path      : varchar(255)      # path to the ephys data
sampling_rate   : double            # sampling rate of recording
preamp_gain     : double            # preamplifier gain
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

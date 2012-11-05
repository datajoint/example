% Spike times for each single unit. This table is populated based on the
% manually inserted single units.
%
% AE 2012-11-04

%{
example.SpikeTimes (computed) # Spike times for single units

-> example.SingleUnits
---
spike_times     : longblob  # spike times for a single unit
%}

classdef SpikeTimes < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('example.SpikeTimes');
        popRel = example.SingleUnits;
    end
    
    methods
        function self = SpikeTimes(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access = protected)
        function makeTuples(self, key)
            t = fetch1(example.SpikeDetection(key), 'spike_times');
            assignments = fetch1(example.SpikeSorting(key), 'cluster_assignments');
            clusters = fetchn(example.SingleUnitClusters(key), 'cluster_num');
            tuple = key;
            tuple.spike_times = t(ismember(assignments, clusters));
            self.insert(tuple);
        end
    end
end

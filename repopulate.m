function repopulate(varargin)
% (Re-) populate all analysis tables.
%   repopulate(restriction) will populate all tables, but only compute
%   those tuples that match the given restriction. The restriction can be
%   either a struct or a string.
%
%   If you want to repopulate only tetrode 17 on 2012-02-17, then use:
%
%   key.subject_id = 1;
%   key.session_date = '2012-02-17';
%   key.ephys_start = '14:33:27';
%   key.tetrode_num = 17;
%   repopulate(key);
%
% AE 2012-11-04

assert(nargin < 1 || isstruct(varargin{1}) || ischar(varargin{1}), ...
    'restriction must be either a string or a struct!')

populate(example.SpikeDetection, varargin{:});
populate(example.FeatureExtraction, varargin{:});
populate(example.SpikeSorting, varargin{:});

% Single units must be inserted manually into example.SingleUnits. See
% util/analyzeSingleUnits and util/insertSingleUnits.

populate(example.SpikeTimes, varargin{:});
populate(example.TuningCurves, varargin{:});

function backup(fileName, partial)
% Make database backup
%   backup('filename') makes a full backup of the entire example.* schema.
%
% AE 2012-11-04

if ~nargin
    fileName = fullfile(pwd, 'example');
end
tables = {'Subjects', 'Sessions', 'Ephys', 'Gratings', 'GratingTrials', ...
          'SpikeDetection', 'FeatureExtraction', 'SpikeSorting', ...
          'SingleUnits', 'SingleUnitClusters', 'SpikeTimes', 'TuningCurves'};
full = [1 1 1 1 1 0 0 1 1 1 1 1];
for i = 1 : numel(tables)
    if full(i) || ~(nargin > 1 && partial)
        eval(sprintf('%s = fetch(example.%s, ''*'');', tables{i}, tables{i}));
    else
        % If the partial option is passed and set to false, just backup the
        % keys for a few large tables and leave out the data. This is a
        % violation of referential integrity and is purely done to make the
        % database dump file smaller while keeping enough tuples in the
        % tables down the hierarchy to keep them interesting.
        eval(sprintf('%s = fetch(example.%s);', tables{i}, tables{i}));
    end
end
save(fileName, tables{:})

function tuples = insertSingleUnits(key, clusterList)
% Insert single units into database.
%   tuples = insertSingleUnits(key, clusterList) inserts cluster -> single
%   unit mappings into the database. The first input key is a structure
%   containing the primary key of the spike sorting results
%   (example.SpikeSorting). The second input clusterList is a cell array. Each
%   cell contains a list of clusters that are assigned to a single unit
%   (one or more clusters can be assigned to a single unit).
%
%   The following example inserts four single units, one of them (#3)
%   consisting of two clusters:
%       key = struct('date', '2012-02-17', 'tetrode', 17, 'group_num', 0);
%       clusterList = {4, 7, [3 8], 2};
%       tuples = insertSingleUnits(key, clusterList)
%
% AE 2012-05-11

if isempty(clusterList), return, end

% ensure key is unique
assert(count(example.Ephys(key)) == 1, 'Key must identify single recording!')
key = fetch(example.SpikeSorting(key));

% ensure clusterList is specified correctly
assert(iscell(clusterList), 'Input must be cell array!')
K = fetch1(example.SpikeSorting(key), 'num_components');
N = numel([clusterList{:}]);
assert(all(cellfun(@(x) isnumeric(x) && all(x > 0) && all(x <= K), clusterList)), ...
    'Cluster list must be cell array of vectors containing cluster indices 1..K!')
assert(numel(unique([clusterList{:}])) == N, ...
    'Clusters cannot be part of multiple single units!')

% if there are already tuples for this key ask if they should be deleted
if count(example.SingleUnits(key))
    fprintf('Table contains single units for this dataset.\n')
    answer = input('Delete them first? [y/n] > ', 's');
    if answer(1) == 'y'
        del(example.SingleUnits(key), false)
    else
        fprintf('Aborted!\n')
        tuples = [];
        return
    end
end

% put together list of tuples to insert into database
tuples = repmat(key, 1, N);
k = 1;
for i = 1 : numel(clusterList)
    for clusterNum = clusterList{i}
        tuples(k).cluster_num = clusterNum;
        tuples(k).unit_num = i;
        k = k + 1;
    end
end
inserti(example.SingleUnits, rmfield(tuples, 'cluster_num'))
insert(example.SingleUnitClusters, tuples);
fprintf('\n\nInserted %d single units (%d clusters).\n', numel(clusterList), N)

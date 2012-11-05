% Mapping from clusters in the mixture model to single units.
% A single unit can consist of multiple clusters, in which case there will
% be multiple rows for that single unit in this table.

%{
example.SingleUnitClusters (manual) # Clusters that belong to single unit

-> example.SingleUnits
cluster_num         : tinyint       # cluster number in mixture model (1..K)
---
%}

classdef SingleUnitClusters < dj.Relvar
    properties(Constant)
        table = dj.Table('example.SingleUnitClusters');
    end
end

% List of single units in the dataset.
%
% A single unit can consist of multiple clusters, in which case there will
% be multiple rows for that single unit in the mapping table
% example.SingleUnitClusters.
%
% AE 2012-11-04

%{
example.SingleUnits (manual) # List of single units

-> example.SpikeSorting
unit_num            : tinyint       # unit number (1..n)
---
%}

classdef SingleUnits < dj.Relvar
    properties(Constant)
        table = dj.Table('example.SingleUnits');
    end
end

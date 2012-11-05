function [ccg, bins] = calcCCG(t, assignment, binsize, maxlag)
% Calculate cross-correlograms.
%   ccg = calcCCG(t, assignment, binsize, maxlag) calculates the cross- and
%   autocorrelograms for all pairs of clusters.

t = sort(t);    % we need the spike times to be sorted
K = max(assignment);
nbins = round(maxlag / binsize);
ccg = zeros(2 * nbins + 1, K, K);
N = numel(t);
j = 1;
for i = 1:N
    while j > 1 && t(j) > t(i) - maxlag
        j = j - 1;
    end
    while j < N && t(j + 1) < t(i) + maxlag
        j = j + 1;
        if i ~= j
            bin = round((t(i) - t(j)) / binsize) + nbins + 1;
            ccg(bin, assignment(i), assignment(j)) = ccg(bin, assignment(i), assignment(j)) + 1;
        end
    end
end
bins = (-nbins : nbins) * binsize;

function plotClusters(b, assignment, varargin)

% parse optional inputs
p = inputParser;
p.addOptional('clusters', ':', @(x) isnumeric(x) || ischar(x) && isequal(x, ':'));
p.addOptional('features', 1:3:10, @(x) isnumeric(x));
p.addOptional('points', 10000, @(x) isnumeric(x) && isscalar(x));
p.addOptional('figure', 1, @(x) isnumeric(x) && isscalar(x));
p.parse(varargin{:});
par = p.Results;

N0 = size(b, 1);
par.points = min(par.points, N0);
colors = hsv(max(assignment));

% keep only selected clusters
if ~ischar(par.clusters)
    keep = ismember(assignment, par.clusters);
    b(~keep, :) = [];
    assignment(~keep) = [];
end
par.clusters = unique(assignment);
K = numel(par.clusters);
colors = colors(par.clusters, :);
N = size(b, 1);

% random selection of points (we use only subset of data for scatterplots)
randsel = randperm(N);
par.points = fix(par.points / N0 * N); % keep original point density

F = numel(par.features);
figure(par.figure), clf
bg = 0.3 * ones(1, 3);
set(gcf, 'color', bg)
for i = 1 : F
    % scatterplots on off-diagonals
    for j = [1 : i - 1, i + 1 : F]
        axes('Position', [j - 1, F - i, 1 1] / F, 'color', bg) %#ok
        hold on
        for k = 1 : K
            index = find(assignment(randsel(1 : par.points)) == par.clusters(k));
            plot(b(randsel(index), par.features(j)), b(randsel(index), par.features(i)), ...
                '.', 'markersize', 1, 'color', colors(k, :))
        end
        axis tight off
    end
    
    % histograms on diagonals
    axes('Position', [i - 1, F - i, 1 1] / F) %#ok
    range = prctile(b(:, par.features(i)), [1 99]);
    bins = linspace(range(1) - diff(range) / 5, range(2) + diff(range) / 5, 80);
    h = zeros(numel(bins), K);
    for k = 1 : K
        index = assignment == par.clusters(k);
        h(:, k) = hist(b(index, par.features(i)), bins);
    end
    hdl = bar(bins(2 : end - 1), h(2 : end - 1, :), 1, 'stacked', 'linestyle', 'none');
    for k = 1 : K
        set(hdl(k), 'facecolor', colors(k, :))
    end
    axis tight off
end

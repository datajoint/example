function plotSeparation(b, model, varargin)
% Plot cluster separation by projecting on LDA axes
%   plotSeparation(b, model) visualizes the cluster separation by
%   projecting the data on the LDA axis for each pair of clusters. Each
%   column is normalized such that the left cluster has zero mean and unit
%   variances. The LDA axis is estimated from the model. 
%
%   plotSeparation(b, model, 'empirical', true) estimates the LDA axes from
%   the data.

% parse optional inputs
p = inputParser;
p.addOptional('clusters', ':', @(x) isnumeric(x) || ischar(x) && isequal(x, ':'));
p.addOptional('figure', 3, @(x) isnumeric(x) && isscalar(x));
p.addOptional('nbins', 50, @(x) isnumeric(x) && isscalar(x));
p.addOptional('empirical', false, @(x) isscalar(x) && (x == 0 || x == 1))
p.parse(varargin{:});
par = p.Results;

% keep only selected clusters
assignment = model.cluster(b);
colors = hsv(model.K);
if ~ischar(par.clusters)
    keep = ismember(assignment, par.clusters);
    b(~keep, :) = [];
    assignment(~keep) = [];
end
[par.clusters, ~, assignment] = unique(assignment);
K = numel(par.clusters);
colors = colors(par.clusters, :);

figure(par.figure), clf
bg = 0.5 * ones(1, 3);
set(gcf, 'color', bg)
for i = 1 : K
    for j = [1 : i - 1, i + 1 : K]
        xi = b(assignment == i, :);
        xj = b(assignment == j, :);
        
        if par.empirical
            % empirical estimate
            mi = mean(xi, 1);
            mj = mean(xj, 1);
            Ci = cov(xi);
            Cj = cov(xj);
            S = (size(xj, 1) - 1) * Cj + (size(xi, 1) - 1) * Ci;
        else
            % model-based estimate
            ii = par.clusters(i);
            jj = par.clusters(j);
            mi = model.mu(ii, :);
            mj = model.mu(jj, :);
            Ci = model.Sigma(:, :, ii);
            Cj = model.Sigma(:, :, jj);
            S = (model.pi(ii) * Ci + model.pi(jj) * Cj) / (model.pi(ii) + model.pi(jj));
        end
        
        % project on optimal axis
        w = S \ (mj - mi)';
        qi = xi * w - mj * w;
        qj = xj * w - mj * w;
        sd = std(qj);
        qi = qi / sd;
        qj = qj / sd;
        if mj * w > mi * w
            qi = -qi;
            qj = -qj;
        end
        
        % plot histograms on optimal axis
        axes('Position', [j - 1, K - i, 1, 1] / K) %#ok
        bins = linspace(-3, 10, par.nbins);
        h = [hist(qj, bins); hist(qi, bins)];
        hdl = bar(bins(2:end-1), h(:,2:end-1)', 1, 'stacked', 'linestyle', 'none');
        set(hdl(1), 'facecolor', colors(j, :))
        set(hdl(2), 'facecolor', colors(i, :))
        axis tight off
        ylim([0, 1.2 * max(h(1, :))])
    end
end

% plot grid on top
axes('position', [0 0 1 1])
hold on
plot([0 1], (1./ [K; K]) * (1 : K), 'k')
plot((1./ [K; K]) * (1 : K), [0 1], 'k')
axis([0 1 0 1])
axis off

% write error rates on diagonal
[fp, fn] = estimateErrorRates(model, b);
for k = 1 : K
    axes('Position', [k - 1, K - k, 1, 1] / K) %#ok
    axis([0 1 0 1])
    text(0.2, 0.4, sprintf('FP: %.1f%%', fp(k) * 100))
    text(0.2, 0.6, sprintf('FN: %.1f%%', fn(k) * 100))
    axis off
end

% Tuning curves for each single unit.
%
% AE 2012-11-04

%{
example.TuningCurves (computed) # Tuning curves for single units

-> example.SpikeTimes
-> example.Gratings
---
stim_directions : blob      # stimlulus directions
spike_counts    : blob      # matrix of spike counts: trials x directions
tuning_params   : blob      # 1-by-k vector of tuning parameters
pref_dir        : double    # preferred direction (degrees)
tuning_width    : double    # half-width (degrees) at half-maximum of tuning curve
dir_sel_p       : double    # p-value for direction selectivity
%}

classdef TuningCurves < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('example.TuningCurves');
        popRel = example.SpikeTimes * example.Gratings;
    end
    
    methods
        function plot(self)
            % Plot tuning curve(s)
            %   plot(relvar) plots the tuning curve for all tuples in
            %   relvar.
            %
            %   Examples
            %
            %   % Plot all tuning curves for tetrode 17
            %   tuning = example.TuningCurves & 'tetrode_num = 17';
            %   plot(tuning)
            %
            %   % Plot tuning curve for cell 1 on tetrode 17
            %   plot(tuning & 'unit_num = 1')
            
            theta = linspace(-10, 350, 100);
            for t = fetch(self, '*')'
                T = fetch1(example.Gratings & t, 'stimulus_duration');
                n = size(t.spike_counts, 1);
                y = tuningCurve(t.tuning_params, theta) / T * 1000;
                rates = t.spike_counts / T * 1000;
                figure
                hold on
                for iDir = 1 : numel(t.stim_directions)
                    plot(t.stim_directions(iDir) + 2 * randn(n, 1), rates(:, iDir), '.', 'markersize', 7, 'color', 0.5 * ones(1, 3))
                end
                errorbar(t.stim_directions, mean(rates), sqrt(var(rates) / n), '.k', 'markersize', 20)
                plot(theta, y, 'k', 'linewidth', 2)
                xlabel('Direction of motion (degrees)')
                ylabel('Firing rate (spikes / sec)')
                xlim(theta([1 end]))
                title(sprintf('%s | tt %d | cell %d', t.session_date, t.tetrode_num, t.unit_num));
                set(gca, 'xtick', t.stim_directions(1 : 2 : end), 'box', 'off')
            end
        end
    end
    
    methods (Access = protected)
        function makeTuples(self, key)
            
            % calculate the matrix of spike counts for each trial and
            % direction of motion
            [directions, counts] = getSpikeCounts(key);
            
            % fit parametric tuning curve
            params = fitTuningCurve(directions, counts);
            
            % extract preferred orientation and tuning width
            [prefDir, width, dirselp] = extractTuningProperties(directions, counts, params);
            
            % insert into database
            tuple = key;
            tuple.stim_directions = directions;
            tuple.spike_counts = counts;
            tuple.tuning_params = params;
            tuple.pref_dir = prefDir;
            tuple.tuning_width = width;
            tuple.dir_sel_p = dirselp;
            self.insert(tuple);
        end
    end
end


function [directions, counts] = getSpikeCounts(key)
% Get firing rate matrix for stimulus presentations.
%   [directions, rates] = getSpikeCounts(key)
%
%   Outputs: 
%   directions  1-by-k vector of directions of motions that were presented.
%               Directions are in degrees (0..360)
%   counts      matrix of spike counts during stimulus presentation. The
%               matrix has dimensions #trials x #directions

% Get firing rate matrix for stimulus presentations.
t = fetch1(example.SpikeTimes & key, 'spike_times');
stimDuration = fetch1(example.Gratings & key, 'stimulus_duration');
[stimOnsets, dirs] = fetchn(example.GratingTrials & key, 'stimulus_onset', 'direction');
nTrials = numel(stimOnsets);
directions = unique(dirs)';
nDir = numel(directions);
iTrialPerDir = zeros(1, nDir);
counts = zeros(nTrials / nDir, nDir);
for iTrial = 1 : nTrials
    iDir = find(dirs(iTrial) == directions);
    iTrialPerDir(iDir) = iTrialPerDir(iDir) + 1;
    nSpikes = sum(t > stimOnsets(iTrial) & t < stimOnsets(iTrial) + stimDuration);
    counts(iTrialPerDir(iDir), iDir) = nSpikes;
end
end


function params = fitTuningCurve(directions, counts)
% Fit parametric tuning curve.
%   params = fitTuningCurve(directions, counts) fits a parametric tuning
%   curve model specified by <group>.tuningCurve and returns the fitted
%   parameters. directions and counts are as returned by getSpikeCounts.

% initial guesses for parameters
meanRate = mean(counts, 1);
[maxRate, maxDir] = max(meanRate);
initPar = [log(maxRate), 0, 2, directions(maxDir) / 180 * pi];

% fit parameters using maximum likelihood
theta = repmat(directions, size(counts, 1), 1);
opt = optimset('MaxFunEvals', 1e4, 'MaxIter', 1e3, 'Display', 'off', 'GradObj', 'on');
fun = @(par) poissonNegLogLike(par, counts(:), theta(:));
params = fminunc(fun, initPar, opt);

% enforce params(2) to be positive so params(4) is actually the preferred
% direction
if params(2) < 0
    params(1) = params(1) - 2 * params(2);
    params(2) = -params(2);
    params(4) = params(4) - pi;
end
params(4) = mod(params(4), 2 * pi);
end


function [prefDir, width, dirselp] = extractTuningProperties(directions, counts, params)
% Extract tuning properties.
%   [prefDir, width, dirselp] = extractTuningProperties(params) returns
%   preferred direction (in degrees: 0..360), tuning width (half-width at
%   half-maximum of the tuning curve, in degrees: 0..360), and a p-value
%   indicating whether the cell is direction selective. 
%
%   If the tuning curve does not drop below half-maximum for any direction
%   of motion, width is -1. 
%
%   Inputs:
%   - directions and counts: as returned by getSpikeCounts
%   - params: 1-by-K vector of tuning curve parameters required by
%             <group>.tuningCurve.

% preferred direction in degrees
prefDir = params(4) / pi * 180;

% evaluate function numerically on [0 90] and find crossing of half-max
params(4) = 0;
dt = 0.1;
theta = 0 : dt : 90;
y = tuningCurve(params, theta);
width = theta(find(y < y(1) / 2, 1, 'first'));
if isempty(width)
    width = -1;
end

% test direction selectivity using directions within 20 deg of preferred
% against the opposite ones
if width > 0
    pref = abs(angle(exp(1i * (directions - prefDir) / 180 * pi))) < 20 / 180 * pi;
    nonpref = circshift(pref, [0, numel(directions) / 2]);
    vec = @(x) x(:);
    dirselp = ranksum(vec(counts(:, pref)), vec(counts(:, nonpref)));
else
    dirselp = 1;
end
end


function y = tuningCurve(p, theta)
% Evaluate tuning curve.
%   y = tuningCurve(params, theta) evaluates the parametric tuning curve at
%   directions theta (in degrees, 0..360). The parameters are specified by
%   a 1-by-k vector params.

theta = theta / 180 * pi; % convert to radians
y = exp(p(1) + p(2) * (cos(theta - p(4)) - 1) + p(3) * (cos(2 * (theta - p(4))) - 1));
end


function [logLike, gradient] = poissonNegLogLike(p, counts, theta)
% Negative log likelihood for Poisson spike count model

lambda = tuningCurve(p, theta);
theta = theta / 180 * pi;

% log likelihood of Poisson model
logLike = -sum(counts .* log(lambda) - lambda);

% gradient of log likelihood w.r.t. parameters p
c1 = cos(theta - p(4)) - 1;
c2 = cos(2 * (theta - p(4))) - 1;
s1 = sin(theta - p(4));
s2 = sin(2 * (theta - p(4)));
gradient(1) = -sum(counts - lambda);
gradient(2) = -sum(c1 .* (counts - lambda));
gradient(3) = -sum(c2 .* (counts - lambda));
gradient(4) = -sum(counts .* (p(2) * s1 + 2 * p(3) * s2) - lambda .* (p(2) * s1 + 2 * p(3) * s2));
end

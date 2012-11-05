% Spike detection based on simple thresholding of the bandpass-filtered
% signal.
%
% AE 2012-11-04

%{
example.SpikeDetection (imported) # Spike detection

-> example.Ephys
tettrode_num   : tinyint unsigned   # tetrode number
---
spike_times     : longblob          # vector of spike times (see detectSpikes)
spike_waveforms : longblob          # matrix of waveforms (see extractSpikes)
%}

classdef SpikeDetection < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('example.SpikeDetection');
        popRel = example.Ephys;
    end
    
    methods 
        function self = SpikeDetection(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access = protected)
        function makeTuples(self, key)
            
            % Load raw data (we converted the data to individual Matlab
            % files for each tetrode to simplify the example)
            [ephysPath, Fs, gain] = fetch1(example.Ephys(key), 'ephys_path', 'sampling_rate', 'preamp_gain');
            for file = dir(fullfile(ephysPath, 'tetrode*.mat'))'
                data = load(file.name);
                x = gain * double(data.x);
            
                % Filter raw signal
                y = filterSignal(x, Fs);
                
                % Detect threshold crossings
                [s, t] = detectSpikes(y, Fs);
                
                % Extract waveforms
                w = extractWaveforms(y, s);
                
                % Done. Insert into table
                tuple = key;
                tuple.tetrode_num = str2double(sscanf(file.name, 'tetrode%d.mat'));
                tuple.spike_times = t;
                tuple.spike_waveforms = w;
                self.insert(tuple);
            end
        end
    end
end


function y = filterSignal(x, Fs)
% Filter raw signal
%   y = filterSignal(x, Fs) filters the signal x. Each column in x is one
%   recording channel. Fs is the sampling frequency. The filter delay is
%   compensated in the output y.

rp = 1;                 % Passband ripple
rs = 40;                % Stopband ripple
fl = [400 600];         % lowpass cutoff + don't care band
fh = [5800 6000];       % highpass cutoff + don't care band
devp = (1 - db2mag(-rp)) / (1 + db2mag(-rp));
devs = db2mag(-rs);
[n, fo, ao, w] = firpmord([fl fh], [0 1 0], [devs devp devs], Fs);
b = firpm(n, fo, ao, w);
y = filter(b, 1, double(x));
y = y((n+1)/2:end, :);  % compensate for filter delay
end


function [s, t] = detectSpikes(x, Fs)
% Detect spikes.
%   [s, t] = detectSpikes(x, Fs) detects spikes in x, where Fs the sampling
%   rate (in Hz). The outputs s and t are column vectors of spike times in
%   samples and ms, respectively. By convention the time of the zeroth
%   sample is 0 ms.

% detect local minima where at least one channel is above threshold
threshold = -5;
noiseSD = median(abs(x)) / 0.6745;      % robust estimate of noise SD
z = bsxfun(@rdivide, x, noiseSD);
mz = min(z, [], 2);
r = sqrt(sum(x .^ 2, 2));               % take norm for finding extrema
dr = diff(r);
s = find(mz(2 : end - 1) < threshold & dr(1 : end - 1) > 0 & dr(2 : end) < 0) + 1;
s = s(s > 10 & s < size(x, 1) - 25);    % remove spikes close to boundaries

% if multiple spikes occur within 1 ms we keep only the largest
refractory = 1 / 1000 * Fs;
N = numel(s);
keep = true(N, 1);
last = 1;
for i = 2 : N
    if s(i) - s(last) < refractory
        if r(s(i)) > r(s(last))
            keep(last) = false;
            last = i;
        else
            keep(i) = false;
        end
    else
        last = i;
    end
end
s = s(keep);
t = s / Fs * 1000;                      % convert to real times in ms
end


function w = extractWaveforms(x, s)
% Extract spike waveforms.
%   w = extractWaveforms(x, s) extracts the waveforms at times s (given in
%   samples) from the filtered signal x using a fixed window around the
%   times of the spikes. The return value w is a 3d array of size
%   length(window) x #spikes x #channels.

win = -7:24;        % window to extract around peak
k = size(x, 2);     % number of channels
n = size(s, 1);     % number of spikes
m = length(win);    % length of extracted window
index = bsxfun(@plus, s, win)';
w = reshape(x(index, :), [m n k]);
end

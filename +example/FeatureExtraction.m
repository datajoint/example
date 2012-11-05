% PCA-based feature extraction on detected spikes. This implementation does
% PCA on the waveforms of each channel separately and uses the first three
% principal components from each. Thus, we get a total of 12 features.
%
% AE 2012-11-04

%{
example.FeatureExtraction (imported) # Feature extraction

-> example.SpikeDetection
---
spike_features : longblob  # feature matrix (#spikes x #features)
%}

classdef FeatureExtraction < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('example.FeatureExtraction');
        popRel = example.SpikeDetection;
    end
    
    methods 
        function self = FeatureExtraction(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access = protected)
        function makeTuples(self, key)

            % get extracted spike waveforms from SpikeDetection table
            w = fetch1(nda.SpikeDetection(key), 'spike_waveforms');

            [~, n, k] = size(w);
            q = 3;                              % number of components per channel
            w = bsxfun(@minus, w, mean(w, 2));  % center data
            b = zeros(n, k * q);
            for i = 1:k
                C = w(:, :, i) * w(:, :, i)';   % covariance matrix
                [V, ~] = eigs(C, q);            % first q eigenvectors
                b(:, (1:q) + q * (i - 1)) = w(:, :, i)' * V;
            end
            
            tuple = key;
            tuple.spike_features = b;
            self.insert(tuple);
        end
    end
end

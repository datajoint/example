% Spike sorting using a mixture of t distributions. We use EM with split &
% merge to fit the model. The degrees of freedom parameter is not optimized
% but fixed to a small value (df=2) to regularize.
%
% AE 2012-11-04


%{
example.SpikeSorting (imported) # Spike sorting using mixture model

-> example.FeatureExtraction
---
num_components      : int           # K: number of mixture components
num_dimensions      : int           # D: dimensionality of the model
cluster_means       : mediumblob    # cluster means (K-by-D)
cluster_cov         : mediumblob    # cluster covariances (D-by-D-by-K)
cluster_priors      : mediumblob    # cluster priors (1-by-K)
cluster_assignments : longblob      # cluster index for each spike (N-by-1)
model_df            : double        # degrees of freedom of t distribution
%}

classdef SpikeSorting < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('example.SpikeSorting');
        popRel = example.SpikeDetection;
    end
    
    methods 
        function self = SpikeSorting(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access = protected)
        function makeTuples(self, key)
            
            % run mixture of t distributions model to sort spikes
            df = 2;
            b = fetch1(nda.FeatureExtraction(key), 'spike_features');
            model = MixtureModel.fit(b, df);

            tuple = key;
            tuple.num_components = size(model.mu, 1);
            tuple.num_dimensions = size(model.mu, 2);
            tuple.cluster_means = model.mu;
            tuple.cluster_cov = model.Sigma;
            tuple.cluster_priors = model.pi;
            tuple.cluster_assignments = model.cluster(b);
            tuple.model_df = df;
            self.insert(tuple);
        end
    end
end

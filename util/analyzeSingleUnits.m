function analyzeSingleUnits(key)
% Diagnostic plots to identify single units in spike sorting result.
% AE 2012-11-04

% get the data
relvar = example.SpikeDetection * example.FeatureExtraction * example.SpikeSorting;
[t, w, b, mu, Sigma, pi, df, assignments] = fetch1(relvar & key, ...
    'spike_times', 'spike_waveforms', 'spike_features', ...
    'cluster_means', 'cluster_cov', 'cluster_priors', 'model_df', ...
    'cluster_assignments');

% show plots
plotWaveforms(w, assignments);
plotCCG(t, assignments);
plotClusters(b, assignments);
plotSeparation(b, MixtureModel(mu, Sigma, pi, df));

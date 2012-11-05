function setup()
% Setup DataJoint example schema.
%   Before you can run setup() you'll need to complete the following steps:
%
%   1. Install MySQL and create a user account with sufficient privileges
%      to create schemata and tables.
%   2. Create a settings.m file in the base folder (where this file
%      resides). You can copy, rename, and edit settings_template.m.
%   3. Run startup.m
%
%   If there is an existing schema called 'example' you will be asked
%   whether you want to drop it. This will delete all tables and data in
%   this schema!
%
% AE 2012-11-04

% Drop existing schema first if it exists
res = query(dj.conn, 'SELECT COUNT(*) as n FROM information_schema.schemata WHERE schema_name = "example"');
if res.n > 0
    disp 'About to drop databse schema `example`. This will delete all its contents!'
    answer = input('Continue? [y/n] >> ', 's');
    if lower(answer(1)) == 'y'
        query(dj.conn, 'DROP SCHEMA `example`')
    else
        disp 'Aborted.'
        return
    end
end

% Create database schema
query(dj.conn, 'CREATE SCHEMA `example`')

% Create DataJoint tables
reload(example.getSchema)
example.Subjects
example.Sessions
example.Ephys
example.Gratings
example.GratingTrials
example.SpikeDetection
example.FeatureExtraction
example.SpikeSorting
example.SingleUnits
example.SingleUnitClusters
example.SpikeTimes
example.TuningCurves

disp ' '
disp '------------------------------------------------'
disp 'Database set up successfully. You''re good to go!'
disp ' '
disp 'To restore a dump file, use restore('filename').'
disp '------------------------------------------------'
disp ' '

function startup()

base = fileparts(mfilename('fullpath'));    % path to this file
addpath(base)
addpath(fullfile(base, 'util'))
addpath(fullfile(base, 'backup'))
addpath(fullfile(base, 'visualization'))

% System specific settings. Create a file called settings.m
[dataJointDir, mymDir, mysqlHost, mysqlUser] = settings();

% add mym to path
if isequal(computer, 'PCWIN64')
    mymDir = fullfile(mymDir, 'win64');
end
addpath(mymDir)
addpath(dataJointDir)

% test if mym works
try
    mym
catch err
    if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
        error('MySQL connector tool (mym) not found!\nProbably incorrect DataJoint path: %s', dataJointDir)
    end
    disp 'ERROR: MySQL connector tool is not working!'
    disp 'You may have to recompile mym at:'
    fprintf('  -> %s\n\n\n', mymDir)
    rethrow(err)
end

setenv('DJ_HOST', mysqlHost)
setenv('DJ_USER', mysqlUser)
fprintf('\nDatajoint connection\n')
fprintf('--------------------\n')
fprintf('host: %s\n', mysqlHost)
fprintf('user: %s\n\n', mysqlUser)

fprintf('Testing DataJoint connection...\n')
dj.conn;

function [dataJointDir, rawDataDir, mysqlHost, mysqlUser] = settings()
% User-specific settings such as directories and user names.
%   Copy this file to settings.m and edit it to reflect your configuration.
%
% AE 2012-04-13

dataJointDir = '/path/to/datajoint';    % path to DataJoint library
rawDataDir = '/path/to/raw/data';       % path to raw data
mysqlHost = 'localhost';                % hostname for MySQL database
mysqlUser = 'myuser';                   % MySQL username

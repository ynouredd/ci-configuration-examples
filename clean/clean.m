function clean(~)
%Clear the workspace
clear;

% Clear the command window
clc;

% Clear all breakpoints
dbclear all;

% Restore default path
restoredefaultpath;

% Rehash toolbox cache
rehash toolboxcache;
end
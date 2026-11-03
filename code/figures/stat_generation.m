
clear; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load superbar function
addpath(genpath([REPO,'/code/analysis/Dependences/scottclowe-superbar-ce333a9']));

% load database
load([REPO,'/data/kinematics/DataBase.mat']);

max_rolls = nan(36,1);
times = nan(36,1);
for trial_i = 1:36

    max_roll_temp = nanmax(DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3));
    max_rolls(trial_i) = max_roll_temp*180/pi;

    time_temp = (DataBase.Trial(trial_i).Info.LeaveFrame - DataBase.Trial(trial_i).Info.EnterFrame)/100;
    times(trial_i) = time_temp;
end

load([REPO,'/data/previous_study/'])

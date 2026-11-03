close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% video settings
is_video = 0;

% set project name and folder
project = struct();
project.name = 'barrier_33';

% folders
video_folder = [[REPO,'/output/'],project.name,'\video\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
addpath([REPO,'/code/model_construction/Dependences_stl']);

% loop trials
trial_i = 38;

for leg_spr = 0:10:180
    file = [project.folder,'basin_trial_',num2str(trial_i),'_LS_',num2str(leg_spr),'.mat'];
    load(file);
%     wrong_frames = [51];
    wrong_frames = [find(BFS_result.roll_PM ~=0),find(BFS_result.roll_RM < BFS_result.roll_S)];
    
    for i_frame = wrong_frames
        BFS_result.roll_PM(i_frame) = 0.5*(BFS_result.roll_PM(i_frame-1)+BFS_result.roll_PM(i_frame+1));
        BFS_result.pitch_PM(i_frame) = 0.5*(BFS_result.pitch_PM(i_frame-1)+BFS_result.pitch_PM(i_frame+1));
        BFS_result.energy_PM(i_frame) = 0.5*(BFS_result.energy_PM(i_frame-1)+BFS_result.energy_PM(i_frame+1));
        BFS_result.roll_RM(i_frame) = 0.5*(BFS_result.roll_RM(i_frame-1)+BFS_result.roll_RM(i_frame+1));
        BFS_result.pitch_RM(i_frame) = 0.5*(BFS_result.pitch_RM(i_frame-1)+BFS_result.pitch_RM(i_frame+1));
        BFS_result.energy_RM(i_frame) = 0.5*(BFS_result.energy_RM(i_frame-1)+BFS_result.energy_RM(i_frame+1));
        BFS_result.roll_S(i_frame) = 0.5*(BFS_result.roll_S(i_frame-1)+BFS_result.roll_S(i_frame+1));
        BFS_result.pitch_S(i_frame) = 0.5*(BFS_result.pitch_S(i_frame-1)+BFS_result.pitch_S(i_frame+1));
        BFS_result.energy_S(i_frame) = 0.5*(BFS_result.energy_S(i_frame-1)+BFS_result.energy_S(i_frame+1));
        BFS_result.energy_barrier(i_frame) = 0.5*(BFS_result.energy_barrier(i_frame-1)+BFS_result.energy_barrier(i_frame+1));
    end
    
    save([project.folder,'basin_trial_',num2str(trial_i),'_LS_',num2str(leg_spr),'.mat'],'BFS_result')
end
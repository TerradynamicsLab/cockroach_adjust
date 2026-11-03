




close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

is_re = 0;
beam_cal_re = 0;
is_fix = 0;

% video settings
is_video = 0;

% set project name and folder
project = struct();
project.name = 'barrier_3';
% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
video_folder = [[REPO,'/output/'],project.name,'\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

for trial_i = 37
    basin_landscape = struct();
    load([project.folder,'data_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
    for frame_i = 1:size(data.landscape_value,1)
        disp(frame_i);
        landscape = data.landscape_value(frame_i,:,:);
        landscape = reshape(landscape,[size(landscape,2),size(landscape,3)]);
        [basin_l,basin_s] = seperate_basin(landscape,1,1);
        basin_landscape(frame_i).data = basin_l;
        basin_landscape(frame_i).size = basin_s;
    end
    save([project.folder,'basin_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat'],'basin_landscape');
end
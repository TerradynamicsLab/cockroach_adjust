close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

is_re = 0;
beam_cal_re = 0;
is_fix = 0;

% video settings
is_video = 1;

% set project name and folder
project = struct();
project.name = 'barrier_3';

% folders
video_folder = [[REPO,'/output/'],project.name,'\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end


% plot
figure(1);
hold on;
X = -24.2:0.2:33;
for is_fix = [1,0]
    trial_i = 37;
    load ([project.folder,'BFS_result_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
    plot(X,BFS_result.energy_barrier);
end
legend("head angle = 15°","head angle = 45°")
xlabel('body x (mm)')
ylabel('Potential energy barrier (mJ)')
grid on;
box on;
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));
% addpath(genpath('D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\c1_maltab_code\BFS_dependences'));

% video settings
is_video = 1;

% set project name and folder
project = struct();
project.name = 'movie_bear_2';

% folders
video_folder = [[REPO,'/output/'],project.name,'\video\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/data/landscape_examples/'],project.name,'\'];
% project.folder = ['D:\Dropbox (Terradynamics Lab)\Cockroach Adjust\added_movie\',project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

trial_i = 38;

X = -26:0.2:33;

figure(1);
hold on;

% plot standard
head_flexion = 15;
data = load([project.folder,'barrier_trial_',num2str(trial_i),'.mat']);
PEB1 = data.left_barrier;
PEB2 = data.right_barrier;

frame_num =  length(PEB1);
l1 = plot(X, PEB1,'LineWidth',3,'Color','r');
l2 = plot(X, PEB2,'LineWidth',3,'Color','b');


set(gca,'FontSize',20)
xlim([-26,33])
set(gcf, 'Position',[480 169 500 500]);
box on;
ax = gca;
ylim(ax.YLim);


for frame_i = 1:frame_num
    l1.XData = X(1:frame_i);
    l1.YData = PEB1(1:frame_i);
    l2.XData = X(1:frame_i);
    l2.YData = PEB2(1:frame_i);
    if is_video
        % get frame and write in video
        saveas(gcf, [video_folder,'profile_',num2str(frame_i, '%03d'),'.jpg'])
    else
        pause(0.2);
    end

end

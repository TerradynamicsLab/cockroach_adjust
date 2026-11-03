close all; clear; clc;
REPO = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% video settings
is_video = 1;

% set project name and folder
project = struct();
project.name = 'movie_bear';

% folders
video_folder = [[REPO,'/output/'],project.name,'\video\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/data/landscape_examples/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

trial_i = 38;

X = -26:0.2:31.2;

figure(1);

% plot standard
head_flexion = 15;
data = load([project.folder,'basin_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat']);
PEB = data.BFS_result.energy_barrier;

frame_num =  length(PEB);
l = plot(X, PEB,'LineWidth',3,'Color','k');
set(gca,'FontSize',20)
xlim([-26,31.2])
set(gcf, 'Position',[480 169 500 500]);
box on;
ax = gca;
ylim(ax.YLim);

for frame_i = 1:frame_num
    l.XData = X(1:frame_i);
    l.YData = PEB(1:frame_i);
    if is_video
        % get frame and write in video
        saveas(gcf, [video_folder,'profile_',num2str(frame_i, '%03d'),'.jpg'])
    else
        pause(0.2);
    end

end

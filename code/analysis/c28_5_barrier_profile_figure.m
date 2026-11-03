close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% set project name and folder
project = struct();
project.name = 'barrier_leg_2';

% folders
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% trial
trial_i = 37;
disp(['Trial: ',num2str(trial_i)]);

% figure
figure(1);
hold on;
X = -24.2:0.2:33; 
colors = fire(40);

record = [];

for leg_spr = 0:5:180
    disp(['leg_spr: ',num2str(leg_spr)]);
    file_name = [project.folder,'basin_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat'];
    if isfile(file_name)
        load([project.folder,'basin_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat']);
        color_temp = colors(round((leg_spr)/180*20)+10,:);
%         plot(X,BFS_result.energy_barrier,'Color',color_temp,'LineWidth',1);
        plot(X,BFS_result.roll_S,'Color',color_temp,'LineWidth',1);
    end
    
end


box on;

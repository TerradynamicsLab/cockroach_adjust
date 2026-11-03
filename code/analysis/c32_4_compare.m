close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

project = struct();
% video settings
is_video = 1;

% set project name and folder
project.name = 'barrier_32';
% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
% load('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p4_kinematics_36\DataBase.mat');
video_folder = [[REPO,'/output/'],project.name,'\video\'];

if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
% project.folder = ['D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p5_PEL_model\f3_landscape\',project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end
addpath([REPO,'/code/model_construction/Dependences_stl']);


% focus on the ideal trial
trial_i = 38;
disp(['Trial: ',num2str(trial_i)]);

body_X = -26:0.2:31.2;

load([project.folder,'basin_trial_',num2str(trial_i),'.mat']);

barrier_left = energy_Saddle_left- energy_stay;
barrier_right = energy_Saddle_right- energy_stay;

figure(1);
hold on;
figure(2);
hold on;
% figure(3);
% hold on;
colors = colormap('autumn');

head_flexions = -25:5:65;
for i_head_flexion = 1:19
    head_flexion = head_flexions(i_head_flexion);
    
    color_temp = colors(round(256/20*i_head_flexion),:);
    
    figure(1);
    plot(body_X, barrier_left(i_head_flexion,:),'LineWidth',5,'Color',color_temp);
    figure(2);
%     plot(body_X, barrier_right(i_head_flexion,:),'LineWidth',5,'Color',color_temp);
    y = barrier_right(i_head_flexion,:);
    for i= 2:length(y)
        if y(i)==0
            y(i)=y(i-1);
        end
    end
    plot(body_X, y,'LineWidth',5,'Color',color_temp);
end


head_flexion = 15;
figure(1);
plot(body_X, barrier_left(9,:),'LineWidth',3,'Color','k');
figure(2);
% plot(body_X, barrier_right(9,:),'LineWidth',3,'Color','k');
y = barrier_right(9,:);
for i= 2:length(y)
        if y(i)==0
            y(i)=y(i-1);
        end
end
plot(body_X, y,'LineWidth',3,'Color','k');

figure(1);
set(gcf, 'Position',[261 365 1440/2 500])
box on;
set(gca,'FontSize',20)
xlim([-26,31.2])
colormap(autumn)
colorbar
figure(2);
set(gcf, 'Position',[261 365 1440/2 500])
box on;
set(gca,'FontSize',20)
xlim([-26,31.2])
colormap(autumn)
cbh=colorbar();
set(cbh,'XTick',([-25,15,65]+25)/90)

% xlim([-15.6,-11.6])
% ylim([-0.03,0.15])

% xlim([-22,-11.6])
% ylim([-0.03,0.2])
% xlim([-15.6,-11.6])
xlim([-14.6,-12.6])
ylim([-0.03,0.2])
line([-13.6,-13.6],[-0.03,0.5],'LineStyle',':','Color','k','LineWidth',3)
line([-20,-20],[-0.03,0.5],'LineStyle',':','Color','k','LineWidth',3)
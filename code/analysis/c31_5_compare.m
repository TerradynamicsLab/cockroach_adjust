close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% set project name and folder
project = struct();
project.name = 'barrier_31';

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
% project.folder = ['D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p5_PEL_model\f3_landscape\',project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

trial_i = 38;

X = -26:0.2:31.2;

figure(1);
hold on;
% figure(2);
% hold on;
% figure(3);
% hold on;
colors = colormap('autumn');

head_flexions = -25:5:65;
for i_head_flexion = 1:19
    head_flexion = head_flexions(i_head_flexion);
    
    color_temp = colors(round(256/20*i_head_flexion),:);
    
    data = load([project.folder,'basin_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat']);
    PEB = data.BFS_result.energy_barrier;
    PER = data.BFS_result.energy_RM;
    PEP = data.BFS_result.energy_PM;
    figure(1);
    plot(X, PEB,'LineWidth',5,'Color',color_temp);
%     plot(X,PEB,'LineWidth',5);
%     figure(2);
%     plot(X,PER,'LineWidth',5);
%     figure(3);
%     plot(X,PEP,'LineWidth',5);
end

% plot standard
head_flexion = 15;
data = load([project.folder,'basin_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat']);
PEB = data.BFS_result.energy_barrier;
figure(1);
plot(X, PEB,'LineWidth',3,'Color','k');

figure(1);
set(gcf, 'Position',[261 365 1440/2 500])
box on;
set(gca,'FontSize',20)
xlim([-26,31.2])
colormap(autumn)
colorbar
% figure(2);
% set(gcf, 'Position',[261 365 1000 600])
% box on;
% set(gca,'FontSize',20)
% figure(3);
% set(gcf, 'Position',[261 365 1000 600])
% box on;
% set(gca,'FontSize',20)

% xlim([-22,-11.6])
% ylim([-0.03,0.2])
% xlim([-15.6,-11.6])
% ylim([-0.003,0.02])
% line([-13.6,-13.6],[-0.03,0.5],'LineStyle',':','Color','k','LineWidth',3)
% line([-20,-20],[-0.03,0.5],'LineStyle',':','Color','k','LineWidth',3)
% xlim([-14.6,-12.6])
% ylim([-0.001,0.008])
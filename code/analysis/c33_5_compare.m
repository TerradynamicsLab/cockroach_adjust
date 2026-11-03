close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% set project name and folder
project = struct();
project.name = 'barrier_33';

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
colors = colormap('cool');

leg_sprs = 0:10:180;
for i_leg_spr = 1:19
    leg_spr = leg_sprs(i_leg_spr);
    
    color_temp = colors(round(256-256/20*i_leg_spr),:);
    
    data = load([project.folder,'basin_trial_',num2str(trial_i),'_LS_',num2str(leg_spr),'.mat']);
    
    PEB = data.BFS_result.energy_barrier;
    if (i_leg_spr<8)
        PEB(59) = PEB(58);
        PEB(60) = PEB(58);
        PEB(61) = PEB(62);
    end
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
leg_spr = 160;
data = load([project.folder,'basin_trial_',num2str(trial_i),'_LS_',num2str(leg_spr),'.mat']);
PEB = data.BFS_result.energy_barrier;
figure(1);
plot(X, PEB,'LineWidth',3,'Color','b');
leg_spr = 20;
data = load([project.folder,'basin_trial_',num2str(trial_i),'_LS_',num2str(leg_spr),'.mat']);
PEB = data.BFS_result.energy_barrier;
PEB(59) = PEB(58);
        PEB(60) = PEB(58);
        PEB(61) = PEB(62);
figure(1);
plot(X, PEB,'LineWidth',3,'Color','r');

figure(1);
set(gcf, 'Position',[261 365 1440/2 500])
box on;
set(gca,'FontSize',20)
xlim([-26,31.2])
colormap(cool)
cbh=colorbar();
set(cbh,'XTick',[20/180,160/180]);
% figure(2);
% set(gcf, 'Position',[261 365 1000 600])
% box on;
% set(gca,'FontSize',20)
% figure(3);
% set(gcf, 'Position',[261 365 1000 600])
% box on;
% set(gca,'FontSize',20)


%%%%%%%%%%%%%
% xlim([-22,-11.6])
% ylim([-0.03,0.5])
xlim([-14.6,-12.6])
% ylim([-0.03,0.15])
ylim([-0.01,0.14])
line([-13.6,-13.6],[-0.03,0.5],'LineStyle',':','Color','k','LineWidth',3)
line([-20,-20],[-0.03,0.5],'LineStyle',':','Color','k','LineWidth',3)
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% set project name and folder
project = struct();
project.name = 'barrier_leg_4';

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

trial_i = 38;

X = -26:0.2:31.2;

figure(1);
hold on;
figure(2);
hold on;
figure(3);
hold on;
for pos_i = 1:4
    data = load([project.folder,'basin_trial_',num2str(trial_i),'_pos_',num2str(pos_i),'.mat']);
    PEB = data.BFS_result.energy_barrier;
    PER = data.BFS_result.energy_RM;
    PEP = data.BFS_result.energy_PM;
    figure(1);
    if pos_i~=1
    plot(X,PEB,'LineWidth',3);
    else
        plot(X,PEB,'LineWidth',5);
    end
    figure(2);
    plot(X,PER,'LineWidth',5);
    figure(3);
    plot(X,PEP,'LineWidth',5);
end


figure(1);
set(gcf, 'Position',[261 365 1000 600])
legend('pitch legs','transition legs','roll legs','no legs')
box on;
set(gca,'FontSize',20)
figure(2);
set(gcf, 'Position',[261 365 1000 600])
legend('pitch legs','transition legs','roll legs','no legs')
box on;
set(gca,'FontSize',20)
figure(3);
set(gcf, 'Position',[261 365 1000 600])
legend('pitch legs','transition legs','roll legs','no legs')
box on;
set(gca,'FontSize',20)
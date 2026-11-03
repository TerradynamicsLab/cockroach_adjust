close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

% set project name and folder
project = struct();
project.name = 'barrier_1';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
load([REPO,'/data/kinematics/DataBase.mat']);
video_folder = [REPO,'/output/barrier_1/'];

is_plot = 1;

barrier_mean_p1_r = nan(36,1); % touch to start rolling (20°)
barrier_std_p1_r = nan(36,1);
barrier_mean_p2_r = nan(36,1);% start rolling (20°) to roll mode (60°)
barrier_std_p2_r = nan(36,1);
barrier_mean_p1_f = nan(36,1); % touch to start rolling (20°)
barrier_std_p1_f = nan(36,1);
barrier_mean_p2_f = nan(36,1);% start rolling (20°) to roll mode (60°)
barrier_std_p2_f = nan(36,1);

for trial_i = 1:36
    % display the trial_i
    disp(['trial_i: ',num2str(trial_i)]);
    
    % load data and barrier_BFS
    load([project.folder,'data_trial_',num2str(trial_i),'_groundtruth.mat']);
    load([project.folder,'barrier_BFS_',num2str(trial_i),'_groundtruth.mat']);
    data_r = data;
    barrier_BFS_r = barrier_BFS;
    
    load([project.folder,'data_trial_',num2str(trial_i),'_HBfix.mat']);
    load([project.folder,'barrier_BFS_',num2str(trial_i),'_HBfix.mat']);
    data_f = data;
    barrier_BFS_f = barrier_BFS;
    
    
    % frames
    Frame_num = length(barrier_BFS_r.route);
    time = (1:Frame_num)/100;
    barrier_r = barrier_BFS_r.saddle.energy - barrier_BFS_r.pitch_minimum.energy;
    barrier_f = barrier_BFS_f.saddle.energy - barrier_BFS_f.pitch_minimum.energy;
    
    barrier_mean_p1_r(trial_i) = mean(barrier_r(1:DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_std_p1_r(trial_i) = std(barrier_r(1:DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_mean_p2_r(trial_i) = mean(barrier_r(DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.Roll60inFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_std_p2_r(trial_i) = std(barrier_r(DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.Roll60inFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_mean_p1_f(trial_i) = mean(barrier_f(1:DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_std_p1_f(trial_i) = std(barrier_f(1:DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_mean_p2_f(trial_i) = mean(barrier_f(DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.Roll60inFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    barrier_std_p2_f(trial_i) = std(barrier_f(DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.Roll60inFrame - DataBase.Trial(trial_i).Info.TouchFrame));
    
    if is_plot
        % plot
        f2 = figure(2);
        set(f2,'Position',[2268,267,650, 510]);
        clf;
        hold on;
        lr = plot(time,barrier_r,...
            'Color','b','LineWidth',3);
        lf = plot(time,barrier_f,...
            'Color','r','LineWidth',3);
        
        y_lim = [0,0.2];
        
        x1 = DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame;
        x2 = DataBase.Trial(trial_i).Info.Roll60inFrame - DataBase.Trial(trial_i).Info.TouchFrame;
        x3 = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.TouchFrame;
        l1 = line([x1,x1]/100,y_lim,'LineStyle','--','LineWidth',2,'Color','b');
        l2 = line([x2,x2]/100,y_lim,'LineStyle','--','LineWidth',2,'Color','k');
        l3 = line([x3,x3]/100,y_lim,'LineStyle','--','LineWidth',2,'Color','r');
        
        box on;
        grid on;
        xlim([0,time(end)]);
        ylim(y_lim);
        set(gca,'FontSize', 20);
        
        % save
        saveas(f2,[video_folder,'Trial_',num2str(trial_i),'_barrier.jpg']);
    end
end

figure(3);
C = [];
C(1,1,:) = [0,0,1];
C(1,2,:) = [1,0,0];
superbar([barrier_mean_p1_r,barrier_mean_p1_f], 'E', [barrier_std_p1_r,barrier_std_p1_f], 'BarFaceColor', C);
set(gca,'FontSize', 20);
box on;
grid on;
saveas(gcf,[video_folder,'barrier_compare_1.jpg']);

figure(4);
C = [];
C(1,1,:) = [0,0,1];
C(1,2,:) = [1,0,0];
superbar([barrier_mean_p2_r,barrier_mean_p2_f], 'E', [barrier_std_p2_r,barrier_std_p2_f], 'BarFaceColor', C);
set(gca,'FontSize', 20);
box on;
grid on;
saveas(gcf,[video_folder,'barrier_compare_2.jpg']);

barrier_statistics_prepare = [barrier_mean_p1_r;barrier_mean_p2_r;barrier_mean_p1_f;barrier_mean_p2_f];
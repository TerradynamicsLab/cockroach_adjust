%%% Yaqing created this function to create bar plot
% 4/24/2021
% hey, it has been two years
% be strong and couraged

clear; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load superbar function
addpath(genpath([REPO,'/code/analysis/Dependences/scottclowe-superbar-ce333a9']));
% addpath(genpath('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\c1_maltab_code\Dependences\scottclowe-superbar-ce333a9'));

% load database
load([REPO,'/data/kinematics/DataBase.mat']);
% load('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p4_kinematics_36\DataBase.mat');

TrialNum = 36;

% calculate leg sprawl
for trial_i = 1:TrialNum
    for frame_i = 1:DataBase.Trial(trial_i).Info.FrameNum
        a = [DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,1:2),0];
        b = [DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,1:2),0];
        LegSprawl(trial_i).data(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
    end
end

% plot
LineWidthEach = 1;
LineWidthMean = 2;
LineWidthStd = 1;

xlims=[-100,80];

xlims=[-25,35];
ylims=[
    -50 110;
    -30 50;
    -7  64;
    -12 50;
    20 170;
    -22 7.5;
    ];

app_color_light = [0    1.0000    0];
approach_color_dark = [0.1490    0.6588    0.0196];
exp_color_light = [0.6, 0.6, 1];
roll_color_light = [1, 0.6, 0.6];
land_color_light = [1, 0.8, 0.6];
dep_color_light = [0.49,0.18,0.56]+0.3;

for v = 1:6
    figure1 = figure(v);
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    set(axes1,'FontSize',22);
    box on;
    hold on;
    xlim(xlims);
    ylim(ylims(v,:));
end

% datas
for trial_i = 1:TrialNum
    % data
    data_X = DataBase.Trial(trial_i).modified.Cockroach.Body.com(:,1);
    data_BR = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3)*180/pi;
    data_BP = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,2)*180/pi;
    data_HF = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,2)*180/pi;
    data_AF = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,2)*180/pi;
    data_LS = LegSprawl(trial_i).data*180/pi;
    data_LHL = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,3);
    data_LHR = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,3);
    
    app_time = DataBase.Trial(trial_i).Info.EnterFrame : DataBase.Trial(trial_i).Info.TouchFrame;
    exp_time = DataBase.Trial(trial_i).Info.TouchFrame : DataBase.Trial(trial_i).Info.RollStartFrame;
    roll_time = DataBase.Trial(trial_i).Info.RollStartFrame : DataBase.Trial(trial_i).Info.RollMaxFrame;
    land_time = DataBase.Trial(trial_i).Info.RollMaxFrame : DataBase.Trial(trial_i).Info.LandFrame;
    dep_time = DataBase.Trial(trial_i).Info.LandFrame : DataBase.Trial(trial_i).Info.LeaveFrame;

    for data_i = 1:5
        if data_i == 1
            data = data_BR;
        elseif data_i == 2
            data = data_BP;
        elseif data_i == 3
            data = data_HF;
        elseif data_i == 4
            data = data_AF;
        else
            data = data_LS;
        end

        % plot
        figure(data_i);
        hold on;

        for phase_i = 1:5
            if phase_i == 1
                time = app_time;
                color = app_color_light;
            elseif phase_i == 2
                time = exp_time;
                color = exp_color_light;
            elseif phase_i == 3
                time = roll_time;
                color = roll_color_light;
            elseif phase_i == 4
                time = land_time;
                color = land_color_light;
            else
                time = dep_time;
                color = dep_color_light;
            end

            plot(data_X(time),data(time),'LineWidth',LineWidthEach,'Color',color);

        end
    end

    % plot
    figure(6);
    hold on;
    plot(data_X,data_LHL,'LineWidth',LineWidthEach,'Color',[1, 0.8, 0.8]);
    plot(data_X,data_LHR,'LineWidth',LineWidthEach,'Color',[0.8, 0.8, 1]);
end





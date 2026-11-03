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

super_trial_i = 1;15;7;
LineWidthSuper = 4;

% calculate leg sprawl
for trial_i = 1:TrialNum
    for frame_i = 1:DataBase.Trial(trial_i).Info.FrameNum
        a = [DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,1:2),0];
        b = [DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,1:2),0];
        LegSprawl(trial_i).data(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
    end
end

for v = 1:7
    DV(v).Value = NaN(TrialNum,2000);
end

% datas
for trial_i = 1:TrialNum
    % frames
    frame_rolS = DataBase.Trial(trial_i).Info.RollStartFrame;

    % data
    data_BR = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3)*180/pi;
    data_BP = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,2)*180/pi;
    data_HF = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,2)*180/pi;
    data_AF = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,2)*180/pi;
    data_LS = LegSprawl(trial_i).data*180/pi;
    data_LHL = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,3);
    data_LHR = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,3);
    
    DV(1).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_BR';
    DV(2).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_BP';
    DV(3).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_HF';
    DV(4).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_AF';
    DV(5).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LS';
    DV(7).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LHL';
    DV(6).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LHR';
end

%% Mean and std
for v = 1:7
    DV(v).Mean = NaN(1,2000);
    DV(v).Std = NaN(1,2000);
    
    for frame_i = 1:2000
        DV(v).Mean(frame_i) = nanmean(DV(v).Value(:,frame_i));
        DV(v).Std(frame_i) = nanstd(DV(v).Value(:,frame_i));
    end
end

% plot
LineWidthEach = 1;
LineWidthMean = 2;
LineWidthStd = 1;

% xlims=[-1.7 1.5];
xlims=[-2 2];
xlims=[-3,3];
ylims=[
    -50 110;
    -30 50;
    -7  64;
    -12 50;
    20 170;
    -22 7.5;
    ];

for v = 1:6
    figure1 = figure(v);
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    set(axes1,'FontSize',22);
    box on;
    hold on;
end

Approach_color_light = [0    1.0000    0];
Approach_color_dark = [0.1490    0.6588    0.0196];



for v = 1:5
    figure(v);
    % Each Trial
    for trial_i = 1:TrialNum
        tempframe = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe2 = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe3 = DataBase.Trial(trial_i).Info.LandFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        plot((-999:tempframe)/100,DV(v).Value(trial_i,1:tempframe+1000),'LineWidth',LineWidthEach,'Color',Approach_color_light);
        plot((tempframe:0)/100,DV(v).Value(trial_i,tempframe+1000:1000),'LineWidth',LineWidthEach,'Color',[0.6, 0.6, 1]);
        plot((0:tempframe2)/100,DV(v).Value(trial_i,1000:tempframe2 + 1000),'LineWidth',LineWidthEach,'Color',[1, 0.6, 0.6]);
        plot((tempframe2:tempframe3)/100,DV(v).Value(trial_i,tempframe2 + 1000:tempframe3 + 1000),'LineWidth',LineWidthEach,'Color',[1, 0.8, 0.6]);
        plot((tempframe3:1000)/100,DV(v).Value(trial_i,tempframe3+1000:2000),'LineWidth',LineWidthEach,'Color',[0.49,0.18,0.56]+0.3);
    end
    plot((-999:1000)/100,DV(v).Mean,'LineWidth',LineWidthMean,'Color',[0 0 0]);
    plot((-999:1000)/100,DV(v).Mean-DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 0.2]);
    plot((-999:1000)/100,DV(v).Mean+DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 0.2]);
    line([0 0],[-1000 1000],'LineStyle',':','Color','k','LineWidth',2);
    
%     trial_i = super_trial_i;
%     tempframe = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
%     tempframe2 = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
%     tempframe3 = DataBase.Trial(trial_i).Info.LandFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
%     plot((-999:tempframe)/100,DV(v).Value(trial_i,1:tempframe+1000),'LineWidth',LineWidthSuper,'Color',Approach_color_dark);
%     plot((tempframe:0)/100,DV(v).Value(trial_i,tempframe+1000:1000),'LineWidth',LineWidthSuper,'Color',[0, 0, 1]);
%     plot((0:tempframe2)/100,DV(v).Value(trial_i,1000:tempframe2 + 1000),'LineWidth',LineWidthSuper,'Color',[1, 0, 0]);
%     plot((tempframe2:tempframe3)/100,DV(v).Value(trial_i,tempframe2 + 1000:tempframe3 + 1000),'LineWidth',LineWidthSuper,'Color',[0.9294,0.6941,0.1255]);
%     plot((tempframe3:1000)/100,DV(v).Value(trial_i,tempframe3+1000:2000),'LineWidth',LineWidthSuper,'Color',[0.49,0.18,0.56]);
%     
%     
    xlim(xlims);
    ylim(ylims(v,:));
end
  
% LH only
figure1 = figure(6);
for trial_i = 1:TrialNum
    tempframe = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
    plot((-999:1000)/100,DV(6).Value(trial_i,1:2000),'LineWidth',LineWidthEach,'Color',[1, 0.8, 0.8]);
    plot((-999:1000)/100,DV(7).Value(trial_i,1:2000),'LineWidth',LineWidthEach,'Color',[0.8, 0.8, 1]);
end
plot((-999:1000)/100,DV(6).Mean,'LineWidth',LineWidthMean,'Color',[1 0 0]);
plot((-999:1000)/100,DV(6).Mean-DV(6).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
plot((-999:1000)/100,DV(6).Mean+DV(6).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
plot((-999:1000)/100,DV(7).Mean,'LineWidth',LineWidthMean,'Color',[0 0 1]);
plot((-999:1000)/100,DV(7).Mean-DV(7).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);
plot((-999:1000)/100,DV(7).Mean+DV(7).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);
line([0 0],[-1000 1000],'LineStyle',':','Color','k','LineWidth',2);

xlim(xlims);
ylim(ylims(6,:));
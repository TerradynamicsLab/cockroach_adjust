%%% Yaqing created this function to create bar plot
% 4/24/2021
% hey, it has been two years
% be strong and couraged

% use normalized phase length, so that phases are "aligned"

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

% calculate average time span
app_times = nan(1,TrialNum);
exp_times = nan(1,TrialNum);
roll_times = nan(1,TrialNum);
land_times = nan(1,TrialNum);
dep_times = nan(1,TrialNum);

for trial_i = 1:TrialNum
    app_times(trial_i) = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.EnterFrame;
    exp_times(trial_i) = DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame;
    roll_times(trial_i) = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
    land_times(trial_i) = DataBase.Trial(trial_i).Info.LandFrame - DataBase.Trial(trial_i).Info.RollMaxFrame;
    dep_times(trial_i) = DataBase.Trial(trial_i).Info.LeaveFrame - DataBase.Trial(trial_i).Info.LandFrame;
end

app_time = mean(app_times)/100; %s
exp_time = mean(exp_times)/100;
roll_time = mean(roll_times)/100;
land_time = mean(land_times)/100;
dep_time = mean(dep_times)/100;

disp(mean(app_times))
disp(std(app_times))

disp(mean(exp_times))
disp(std(exp_times))

disp(mean(roll_times))
disp(std(roll_times))

disp(mean(land_times))
disp(std(land_times))

disp(mean(dep_times))
disp(std(dep_times))

end_time = app_time + exp_time + roll_time + land_time + dep_time;
disp(end_time)

app_start_time = 0;
exp_start_time = app_time;
roll_start_time = app_time + exp_time;
land_start_time = app_time + exp_time + roll_time;
dep_start_time = app_time + exp_time + roll_time + land_time;
end_time = app_time + exp_time + roll_time + land_time + dep_time;

% calculate leg sprawl
for trial_i = 1:TrialNum
    for frame_i = 1:DataBase.Trial(trial_i).Info.FrameNum
        a = [DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,1:2),0];
        b = [DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,1:2),0];
        c = [-1,0,0];
        % LegSprawl(trial_i).data(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
        LegSprawl_left(trial_i).data(frame_i) = atan2(norm(cross(a,c)), dot(a,c));
        if a(2)<0
            LegSprawl_left(trial_i).data(frame_i) = -LegSprawl_left(trial_i).data(frame_i);
        end
        LegSprawl_right(trial_i).data(frame_i) = atan2(norm(cross(b,c)), dot(b,c));
        if b(2)>0
            LegSprawl_right(trial_i).data(frame_i) = -LegSprawl_right(trial_i).data(frame_i);
        end


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
%     data_LS = LegSprawl(trial_i).data*180/pi;
    data_LHL = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,3);
    data_LHR = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,3);
    data_LSL = LegSprawl_left(trial_i).data*180/pi;
    data_LSR = LegSprawl_right(trial_i).data*180/pi;

    DV(1).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_BR';
    DV(2).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_BP';
    DV(3).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_HF';
    DV(4).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_AF';
    DV(5).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LSL';
    DV(7).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LHL';
    DV(6).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LHR';
    DV(8).Value(trial_i,1001-frame_rolS:1000+length(data_BR)-frame_rolS) = data_LSR';
end

%% Mean and std
normalized_length = round(end_time*100);
normalized_time = split_YW(0,end_time,normalized_length);

for v = 1:8
    DV(v).record = NaN(TrialNum,normalized_length);
    DV(v).Mean = NaN(1,normalized_length);
    DV(v).Std = NaN(1,normalized_length);

    for trial_i = 1:TrialNum
        tempframe0 = DataBase.Trial(trial_i).Info.EnterFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe1 = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe2 = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe3 = DataBase.Trial(trial_i).Info.LandFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe4 = DataBase.Trial(trial_i).Info.LeaveFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        for phase_i = 1:5
            if phase_i == 1
                % approach
                temp_times = split_YW(app_start_time,exp_start_time,tempframe1-tempframe0+1);
                temp_vals = DV(v).Value(trial_i,(tempframe0:tempframe1)+1000);
            elseif phase_i == 2
                % exp
                temp_times = split_YW(exp_start_time,roll_start_time,0-tempframe1+1);
                temp_vals = DV(v).Value(trial_i,(tempframe1:0)+1000);
            elseif phase_i == 3
                % roll
                temp_times = split_YW(roll_start_time,land_start_time,tempframe2-0+1);
                temp_vals = DV(v).Value(trial_i,(0:tempframe2) + 1000);
            elseif phase_i == 4
                % land
                temp_times = split_YW(land_start_time,dep_start_time,tempframe3-tempframe2+1);
                temp_vals = DV(v).Value(trial_i,(tempframe2:tempframe3) + 1000);
            else
                % dep
                temp_times = split_YW(dep_start_time,end_time,tempframe4-tempframe3+1);
                temp_vals = DV(v).Value(trial_i,(tempframe3:tempframe4)+1000);
            end
            for time_i = 1:length(temp_times)-1
                time_left = temp_times(time_i);
                time_right = temp_times(time_i+1);
                for insert_time_i = 1:normalized_length
                    insert_time = normalized_time(insert_time_i);
                    if insert_time >= time_left && insert_time <= time_right
                        DV(v).record(trial_i,insert_time_i) = (temp_vals(time_i)+temp_vals(time_i+1))/2;
                    end
                end
            end
        end
    end
    for frame_i = 1:normalized_length
        DV(v).Mean(frame_i) = nanmean(DV(v).record(:,frame_i));
        DV(v).Std(frame_i) = nanstd(DV(v).record(:,frame_i));
    end
end



% plot
LineWidthEach = 1;
LineWidthMean = 2;
LineWidthStd = 1;

% xlims=[-1.7 1.5];
xlims=[app_start_time end_time];
ylims=[
    -50 110;
    -30 50;
    -7  64;
    -12 50;
    -50 100;
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

for v = 1:4
    figure(v);
    % Each Trial
    for trial_i = 1:TrialNum
        tempframe0 = DataBase.Trial(trial_i).Info.EnterFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe1 = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe2 = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe3 = DataBase.Trial(trial_i).Info.LandFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        tempframe4 = DataBase.Trial(trial_i).Info.LeaveFrame - DataBase.Trial(trial_i).Info.RollStartFrame;

        plot(split_YW(app_start_time,exp_start_time,tempframe1-tempframe0+1),DV(v).Value(trial_i,(tempframe0:tempframe1)+1000),'LineWidth',LineWidthEach,'Color',Approach_color_light);
        plot(split_YW(exp_start_time,roll_start_time,0-tempframe1+1),DV(v).Value(trial_i,(tempframe1:0)+1000),'LineWidth',LineWidthEach,'Color',[0.6, 0.6, 1]);
        plot(split_YW(roll_start_time,land_start_time,tempframe2-0+1),DV(v).Value(trial_i,(0:tempframe2) + 1000),'LineWidth',LineWidthEach,'Color',[1, 0.6, 0.6]);
        plot(split_YW(land_start_time,dep_start_time,tempframe3-tempframe2+1),DV(v).Value(trial_i,(tempframe2:tempframe3) + 1000),'LineWidth',LineWidthEach,'Color',[1, 0.8, 0.6]);
        plot(split_YW(dep_start_time,end_time,tempframe4-tempframe3+1),DV(v).Value(trial_i,(tempframe3:tempframe4)+1000),'LineWidth',LineWidthEach,'Color',[0.49,0.18,0.56]+0.3);
    end

    plot(normalized_time,DV(v).Mean,'LineWidth',LineWidthMean,'Color',[0 0 0]);
    plot(normalized_time,DV(v).Mean-DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 0.2]);
    plot(normalized_time,DV(v).Mean+DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 0.2]);

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

% Each Trial
for trial_i = 1:TrialNum
    tempframe0 = DataBase.Trial(trial_i).Info.EnterFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
    tempframe4 = DataBase.Trial(trial_i).Info.LeaveFrame - DataBase.Trial(trial_i).Info.RollStartFrame;

    plot(split_YW(app_start_time,end_time,tempframe4-tempframe0+1),DV(6).Value(trial_i,(tempframe0:tempframe4)+1000),'LineWidth',LineWidthEach,'Color',[1, 0.8, 0.8]);
    plot(split_YW(app_start_time,end_time,tempframe4-tempframe0+1),DV(7).Value(trial_i,(tempframe0:tempframe4)+1000),'LineWidth',LineWidthEach,'Color',[0.8, 0.8, 1]);

end

v = 6;
plot(normalized_time,DV(v).Mean,'LineWidth',LineWidthMean,'Color',[1 0 0]);
plot(normalized_time,DV(v).Mean-DV(v).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
plot(normalized_time,DV(v).Mean+DV(v).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
v = 7;
plot(normalized_time,DV(v).Mean,'LineWidth',LineWidthMean,'Color',[0 0 1]);
plot(normalized_time,DV(v).Mean-DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);
plot(normalized_time,DV(v).Mean+DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);

xlim(xlims);
ylim(ylims(6,:));

% LS only
figure1 = figure(5);

% Each Trial
for trial_i = 1:TrialNum
    tempframe0 = DataBase.Trial(trial_i).Info.EnterFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
    tempframe4 = DataBase.Trial(trial_i).Info.LeaveFrame - DataBase.Trial(trial_i).Info.RollStartFrame;

    plot(split_YW(app_start_time,end_time,tempframe4-tempframe0+1),DV(8).Value(trial_i,(tempframe0:tempframe4)+1000),'LineWidth',LineWidthEach,'Color',[1, 0.8, 0.8]);
    plot(split_YW(app_start_time,end_time,tempframe4-tempframe0+1),DV(5).Value(trial_i,(tempframe0:tempframe4)+1000),'LineWidth',LineWidthEach,'Color',[0.8, 0.8, 1]);

end

v = 8;
plot(normalized_time,DV(v).Mean,'LineWidth',LineWidthMean,'Color',[1 0 0]);
plot(normalized_time,DV(v).Mean-DV(v).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
plot(normalized_time,DV(v).Mean+DV(v).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
v = 5;
plot(normalized_time,DV(v).Mean,'LineWidth',LineWidthMean,'Color',[0 0 1]);
plot(normalized_time,DV(v).Mean-DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);
plot(normalized_time,DV(v).Mean+DV(v).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);

xlim(xlims);
ylim(ylims(5,:));
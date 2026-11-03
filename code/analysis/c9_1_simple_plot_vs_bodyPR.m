% Yaqing created this on 06/28/2020 to create the simple line plots vs body
% pitch and body roll in the paper

close all;clear;clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
%%
save_folder = [REPO,'/data/kinematics/simple_plot/'];
%%  Load DataBase
DataBase_file = [REPO,'/data/kinematics/DataBase'];
load(DataBase_file);


% settings
All_trial = 1:DataBase.TrialNum;
PitchRoll_trial = [1:6,13:18,25:30];
PureRoll_trial = [7:12,19:24,31:36];

trial_series = All_trial;

phase_num = 6;
for trial_i = trial_series
    frame_span(trial_i,1:phase_num,1:2) = [
        DataBase.Trial(trial_i).Info.EnterFrame,DataBase.Trial(trial_i).Info.TouchFrame;
        DataBase.Trial(trial_i).Info.TouchFrame,DataBase.Trial(trial_i).Info.RollStartFrame;
        DataBase.Trial(trial_i).Info.RollStartFrame,DataBase.Trial(trial_i).Info.Roll60inFrame;
        DataBase.Trial(trial_i).Info.Roll60inFrame,DataBase.Trial(trial_i).Info.Roll60outFrame;
        DataBase.Trial(trial_i).Info.Roll60outFrame,DataBase.Trial(trial_i).Info.LandFrame;
        DataBase.Trial(trial_i).Info.LandFrame,DataBase.Trial(trial_i).Info.LeaveFrame;
        ];
end
phase_color = [
    0,1,0;
    0,0,1;
    0.93,0.69,0.13;
    1,0,0;
    0.49,0.18,0.56;
    0.47,0.67,0.19;
    ];

% plot settings
LineWidthEach = 1;
LineWidthMean = 6;
LineWidthStd = 3;

figure(1);
hold on;
figure(2);
hold on;
figure(3);
hold on;
figure(4);
hold on;

% plot
for trial_i = 1:DataBase.TrialNum
    body_pitch = - DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,2)*180/pi;
    body_roll = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3)*180/pi;
    head_flex = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,2)*180/pi;
    abdomen_flex = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,2)*180/pi;
    LegSprawl = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
    LegHeightDiff = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
    for frame_i = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
        right_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
        left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
        LegSprawl(frame_i) = abs(acos(dot(right_position_b, left_position_b) / (norm(right_position_b) * norm(left_position_b))));
        LegHeightDiff(frame_i) = right_position_b(3)-left_position_b(3);
    end
    figure(1);
    for phase_i = 1:phase_num
        phase_span_temp = frame_span(trial_i,phase_i,1):frame_span(trial_i,phase_i,2);
        plot3(body_pitch(phase_span_temp), body_roll(phase_span_temp), head_flex(phase_span_temp),'LineWidth',LineWidthEach,'Color',phase_color(phase_i,1:3));
    end
    
    figure(2);
    for phase_i = 1:phase_num
        phase_span_temp = frame_span(trial_i,phase_i,1):frame_span(trial_i,phase_i,2);
        plot3(body_pitch(phase_span_temp), body_roll(phase_span_temp), abdomen_flex(phase_span_temp),'LineWidth',LineWidthEach,'Color',phase_color(phase_i,1:3));
    end
    
    figure(3);
    for phase_i = 1:phase_num
        phase_span_temp = frame_span(trial_i,phase_i,1):frame_span(trial_i,phase_i,2);
        plot3(body_pitch(phase_span_temp), body_roll(phase_span_temp), LegHeightDiff(phase_span_temp),'LineWidth',LineWidthEach,'Color',phase_color(phase_i,1:3));
    end
    
    figure(4);
    for phase_i = 1:phase_num
        phase_span_temp = frame_span(trial_i,phase_i,1):frame_span(trial_i,phase_i,2);
        plot3(body_pitch(phase_span_temp), body_roll(phase_span_temp), LegSprawl(phase_span_temp),'LineWidth',LineWidthEach,'Color',phase_color(phase_i,1:3));
    end
end

figure(1);
grid on;
box on;
xlabel("body pitch (°)");
ylabel("body roll (°)");
zlabel("Head flexion (°)");
view(120,16);
saveas(gcf,[save_folder,'3D-head_flextion.jpg']);
view(90,0);
saveas(gcf,[save_folder,'3D-head_flextion_roll.jpg']);
view(90,-90);
saveas(gcf,[save_folder,'3D-top.jpg']);

figure(2);
grid on;
box on;
xlabel("body pitch (°)");
ylabel("body roll (°)");
zlabel("Abdomen flexion (°)");
view(120,16);
saveas(gcf,[save_folder,'3D-abdomen_flextion.jpg']);
view(90,0);
saveas(gcf,[save_folder,'3D-abdomen_flextion_roll.jpg']);

figure(3);
grid on;
box on;
xlabel("body pitch (°)");
ylabel("body roll (°)");
zlabel("Leg height difference (mm)");
view(120,16);
saveas(gcf,[save_folder,'3D-leg_hight.jpg']);
view(90,0);
saveas(gcf,[save_folder,'3D-leg_hight_roll.jpg']);

figure(4);
grid on;
box on;
xlabel("body pitch (°)");
ylabel("body roll (°)");
zlabel("Leg sprawl (°)");
view(120,16);
saveas(gcf,[save_folder,'3D-leg_sprawl.jpg']);
view(90,0);
saveas(gcf,[save_folder,'3D-leg_sprawl_roll.jpg']);

close all;

clear; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load database
load([REPO,'/data/kinematics/DataBase.mat']);


TrialNum = 36;

dt = 1/100;

mean_energy_roll_phase = nan(1,36);
mean_leg_velo_roll_phase = nan(1,36);
mean_z_roll_phase = nan(1,36);

% calculate leg sprawl
for trial_i = 1:TrialNum
    leg_velocity_left = nan(1,DataBase.Trial(trial_i).Info.FrameNum);
    leg_velocity_right = nan(1,DataBase.Trial(trial_i).Info.FrameNum);
    for frame_i = 2:DataBase.Trial(trial_i).Info.FrameNum
        leg_velocity_left(frame_i) = norm(DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:) - ...
            DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i-1,:))/dt/1000; %m/s
        leg_velocity_right(frame_i) = norm(DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:) - ...
            DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i-1,:))/dt/1000; %m/s
    end
    ExpPit_phase = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;
    Roll_phase = DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.RollMaxFrame;

Roll_phase = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame;

    a = leg_velocity_left(Roll_phase);
    b = leg_velocity_right(Roll_phase);
    mean_leg_velo_roll_phase(trial_i) = nanmean([a,b]);
    mean_energy_roll_phase(trial_i) = nanmean(a.*a+b.*b);
    mean_z_roll_phase(trial_i) = nanmean([DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(Roll_phase,3);...
        DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(Roll_phase,3)]);
end

% to energy
mean_energy_roll_phase = mean_energy_roll_phase*0.5*92/1000; % mJ

mean(mean_energy_roll_phase)
std(mean_energy_roll_phase)

mean(mean_z_roll_phase)
std(mean_z_roll_phase)

mean(mean_leg_velo_roll_phase)
std(mean_leg_velo_roll_phase)

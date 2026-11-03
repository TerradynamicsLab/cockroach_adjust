% Created on 2/25/2021
% Yaqing
%
% further study the function of head flexion
% hypothesis: in explore phase, head flexed to make the force pass through neck.


% basics
clear; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));
load([REPO,'/data/kinematics/DataBase.mat']);

% plot settings
f1 = figure();
hold on;
f2 = figure();
hold on;
f3 = figure();
hold on;

% statistics holder
%%% variables: trial_num, frame_num, left_torque_angle_h, right_torque_angle_h,
%%% left_torque_angle_b, right_torque_angle_b, head_flex_angle, body_pitch_angle
statistics_holder = [];

% for each trial
for trial_i = 1:36
    frames = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;
    %%% holder
    left_torque_angle_h = nan(1,length(frames));
    right_torque_angle_h = nan(1,length(frames));
    left_torque_angle_b = nan(1,length(frames));
    right_torque_angle_b = nan(1,length(frames));
    head_flex_angle = nan(1,length(frames));
    body_pitch_angle = nan(1,length(frames));
        
    %%% for each frame
    for index = 1:length(frames)
        frame_i = frames(index);
        
        %%%% calculate neck frame
        Rw2n = eul2rotm(DataBase.Trial(trial_i).modified.Cockroach.Head.eul(frame_i,:));
        in = Rw2n(:,1);
        % jn = Rw2n(:,2);
        % kn = Rw2n(:,3);
        
        %%%% calculate body frame
        Rw2b = eul2rotm(DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_i,:));
        ib = Rw2b(:,1);
        
        %%%% calculate force vector(s) in world frame
        left_beam_angle = DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch(frame_i);
        nF_left = [cos(left_beam_angle), 0, sin(left_beam_angle)];
        right_beam_angle = DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch(frame_i);
        nF_right = [cos(right_beam_angle), 0, sin(right_beam_angle)];
        
        %%%% calculate torque angle in neck frame
        theta_T_left_n = asin(norm(cross(in, nF_left)));
        theta_T_right_n = asin(norm(cross(in, nF_right)));
        
        %%%% calculate torque angle in body frame (no head flexion)
        theta_T_left_b = asin(norm(cross(ib, nF_left)));
        theta_T_right_b = asin(norm(cross(ib, nF_right)));
        
        %%%% record
        left_torque_angle_h(index) = theta_T_left_n *180/pi;
        right_torque_angle_h(index) = theta_T_right_n *180/pi;
        left_torque_angle_b(index) = theta_T_left_b *180/pi;
        right_torque_angle_b(index) = theta_T_right_b *180/pi;
        head_flex_angle(index) = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,2)*180/pi;
        body_pitch_angle(index) = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_i,2)*180/pi;
        
        
    end
    
    % plot
    figure(f1);
    plot(head_flex_angle,left_torque_angle_h,'Color','b');
    plot(head_flex_angle,right_torque_angle_h,'Color','r');
    figure(f2);
    plot(body_pitch_angle,left_torque_angle_b,'Color','b');
    plot(body_pitch_angle,right_torque_angle_b,'Color','r');
    
    figure(f3);
    plot(body_pitch_angle,left_torque_angle_h,'Color','b');
    plot(body_pitch_angle,right_torque_angle_h,'Color','b');
    plot(body_pitch_angle,left_torque_angle_b,'Color','r');
    plot(body_pitch_angle,right_torque_angle_b,'Color','r');
end


% adjust figure
figure(f1);   
box on;
grid on;

figure(f2);
set(gca, 'XDir','reverse');  
axis equal
box on;
grid on;

figure(f3);
set(gca, 'XDir','reverse');    
box on;
grid on;





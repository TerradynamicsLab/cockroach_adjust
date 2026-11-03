% Created on 7/25/2021 discussing about the the relationship between head
% flexion and roll, at the transition, including sign, amplitude (slope), and who
% comes first
%
% look into a CERTAIN number of frames before and after rollstart frame: 20
%
% count the up and downs of head flexion

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
load([REPO,'/data/kinematics/DataBase.mat']);

certain_number_of_frames = 20;

% holder
before_roll_slope = zeros(1,36);
before_head_up = zeros(1,36);
before_head_down = zeros(1,36);

after_roll_slope = zeros(1,36);
after_head_up = zeros(1,36);
after_head_down = zeros(1,36);

% loop trials
for trial_i = 1:36
    % settle frames
    roll_frame = DataBase.Trial(trial_i).Info.RollStartFrame;
    before_roll_frames = (- certain_number_of_frames + roll_frame + 1):roll_frame;
    after_roll_frames = roll_frame : (+ certain_number_of_frames + roll_frame - 1);
    
    % collect raw data
    before_BR = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(before_roll_frames,3)*180/pi;
    before_HP = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(before_roll_frames,2)*180/pi;
    after_BR = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(after_roll_frames,3)*180/pi;
    after_HP = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(after_roll_frames,2)*180/pi;
    
    % roll_slope
    roll_min = before_BR(end);
    before_roll_slope(trial_i) = (roll_min*certain_number_of_frames - sum(before_BR));
    after_roll_slope(trial_i) = (- roll_min*certain_number_of_frames + sum(after_BR));
    
    % head up and down
    for frame_i = 2:certain_number_of_frames
        
        %%% before
        HP_diff = before_HP(frame_i) - before_HP(frame_i - 1);
        if HP_diff < 0
            before_head_up(trial_i) = before_head_up(trial_i) - HP_diff;
        else
            before_head_down(trial_i) = before_head_down(trial_i) + HP_diff;
        end
        
        %%% after
        HP_diff = after_HP(frame_i) - after_HP(frame_i - 1);
        if HP_diff < 0
            after_head_up(trial_i) = after_head_up(trial_i) - HP_diff;
        else
            after_head_down(trial_i) = after_head_down(trial_i) + HP_diff;
        end
    end

    
end

% unify
total_weight = sum(0:certain_number_of_frames-1);
before_roll_slope = before_roll_slope / total_weight * 100;
after_roll_slope = after_roll_slope / total_weight * 100;

before_head_up = before_head_up / certain_number_of_frames * 100;
before_head_down = before_head_down / certain_number_of_frames * 100;
after_head_up = after_head_up / certain_number_of_frames * 100;
after_head_down = after_head_down / certain_number_of_frames * 100;

% plot
Y = [before_head_up', before_head_down', after_head_up', after_head_down'];

% Y = [-before_head_up'+before_head_down', -after_head_up'+after_head_down'];
% Y = [+before_head_up'+before_head_down', +after_head_up'+after_head_down'];


bar(Y)
% hold on;
% plot(after_roll_slope)

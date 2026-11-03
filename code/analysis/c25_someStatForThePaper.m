% Yaqing created this on 1/21/2021 to address those "XX" in the paper
% paper version: v4

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load data base
load([REPO,'/data/kinematics/DataBase.mat'])

% which one you want
n = input('Enter a number: ');

switch n
    case 1
        % arround line 224
        % head flexion range
        minimum = 4;
        maximum = 0;
        for trial_i = 1:36
            for frame_i = DataBase.Trial(trial_i).Info.EnterFrame: DataBase.Trial(trial_i).Info.LeaveFrame
                if ~isnan(DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,2))
                    if DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,2) < minimum
                        minimum = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,2);
                    elseif DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,2) > maximum
                        maximum = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,2);
                    end
                end
            end
        end
        disp('case:1 head flexion range')
        disp([minimum, maximum]*180/pi)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 2
        % arround line 225
        % average abdomen angle when the animal run before colliding with the obstacles
        abdomen_angles = [];
        for trial_i = 1:36
            frames = DataBase.Trial(trial_i).Info.EnterFrame: DataBase.Trial(trial_i).Info.TouchFrame;
            abdomen_angles = [abdomen_angles; DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frames,2)];
        end
        angle_mean = nanmean(abdomen_angles);
        angle_std = nanstd(abdomen_angles);
        disp('case:2 average abdomen angle (MEAN AND S.D) when the animal run before colliding with the obstacles')
        disp([angle_mean, angle_std]*180/pi)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 3
        % arround line 231
        % average head angle when the animal run before colliding with the obstacles
        head_angles = [];
        for trial_i = 1:36
            frames = DataBase.Trial(trial_i).Info.EnterFrame: DataBase.Trial(trial_i).Info.TouchFrame;
            head_angles = [head_angles; DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frames,2)];
        end
        angle_mean = nanmean(head_angles);
        angle_std = nanstd(head_angles);
        disp('case:3 average head angle (MEAN AND S.D) when the animal run before colliding with the obstacles')
        disp([angle_mean, angle_std]*180/pi)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 4
        % arround line 348
        % where the animals transitioned from pitch to roll mode
        x = [];
        for trial_i = 1:36
            frames = DataBase.Trial(trial_i).Info.Roll60inFrame;
            x = [x; DataBase.Trial(trial_i).modified.Cockroach.Body.com(frames,1)];
        end
        x_mean = nanmean(x);
        x_std = nanstd(x);
        disp('case:4 where the animals transitioned from pitch to roll mode')
        disp([x_mean, x_std])
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
        disp('Nothing')
end
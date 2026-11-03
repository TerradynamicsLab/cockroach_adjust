

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load database
load([REPO,'/data/kinematics/DataBase.mat']);

% create holder
head_pitch = nan(1,36);

% loop trial
for trial_i = 1:36
    frame_select = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame;
    head_pitch(trial_i) = nanmean(DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_select,2));
end

disp(mean(head_pitch)*180/pi);
disp(std(head_pitch)*180/pi);


% create holder
abdomen_pitch = nan(1,36);

% loop trial
for trial_i = 1:36
    frame_select = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame;
    abdomen_pitch(trial_i) = nanmean(DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_select,2));
end

disp(mean(abdomen_pitch)*180/pi);
disp(std(abdomen_pitch)*180/pi);
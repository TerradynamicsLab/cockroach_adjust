REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
% find average traverse time and max roll

% load
load([REPO,'/data/previous_study/timeData_V3.mat'])

% only think about beam stiffness 4, should be high tan
trial_num = 67;
beam_i = 4;

traverse_times = nan(1,trial_num);
max_rolls = nan(1,trial_num);

for trial_i = 1:trial_num
    x = timeData{trial_i, beam_i}.XYZ(1,:);
    frame_start = 1;
    while(isnan(x(frame_start)))
        frame_start = frame_start+1;
    end
    frame_end = length(x);
    while(isnan(x(frame_end)))
        frame_end = frame_end-1;
    end
    traverse_times(trial_i) = (frame_end-frame_start)/100;

    roll = timeData{trial_i, beam_i}.RPY(1,:)*180/pi;
    max_roll_1 = nanmax(roll);
    max_roll_2 = nanmax(-roll);
    max_rolls(trial_i) = max(max_roll_1,max_roll_2);
end

% traverse_times(20) = nan;
% traverse_times(47) = nan;

nanmean(traverse_times)
nanstd(traverse_times)


% max_rolls(11) = nan;
% max_rolls(47) = nan;

nanmean(max_rolls)
nanstd(max_rolls)

figure(1)
scatter(1:trial_num,traverse_times);
figure(2)
scatter(1:trial_num,max_rolls);


load([REPO,'/data/kinematics/DataBase.mat']);
trial_num = 36;
traverse_times = nan(1,trial_num);
max_rolls = nan(1,trial_num);

for trial_i = 1:trial_num
    traverse_times(trial_i) = (DataBase.Trial(trial_i).Info.LeaveFrame-DataBase.Trial(trial_i).Info.EnterFrame)/100;
    max_rolls(trial_i) = nanmax(DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3))*180/pi;
end

mean(traverse_times)
std(traverse_times)

max_rolls(11)
mean(max_rolls)
std(max_rolls)


load([REPO,'/data/kinematics/DataBase_organized_64.mat']);
trial_num = 64;
traverse_times = nan(1,trial_num);
max_rolls = nan(1,trial_num);

for trial_i = 1:trial_num
    traverse_times(trial_i) = (DataBase_organized.trial(trial_i).info.end_frame_in_video-DataBase_organized.trial(trial_i).info.start_frame_in_video)/100;
    
    max_rolls(trial_i) = max(nanmax(-DataBase_organized.trial(trial_i).cockroach.body.eul(:,3)),nanmax(DataBase_organized.trial(trial_i).cockroach.body.eul(:,3)))*180/pi;
end

mean(traverse_times)
std(traverse_times)

% max_rolls(11)
mean(max_rolls)
std(max_rolls)
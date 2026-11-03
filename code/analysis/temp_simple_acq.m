close all;
clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
load([REPO,'/data/kinematics/DataBase.mat']);

% trial_i = 9;

% figure(2);
% hold on;
for trial_i = 1:36
    for frame_i = 1:DataBase.Trial(trial_i).Info.FrameNum
        a = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
        b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
        LegSprawl(trial_i).data(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
    end
end
% frames = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;

% plot(DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3)*180/pi);
% plot(DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,2)*180/pi);
% plot(-DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,2)*180/pi);


% certain_number_of_frames = 20;
% figure(3);
% hold on;
% figure(4);
% hold on;
for trial_i = 1:36
   frames = DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.RollMaxFrame;
%    frames = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;
   temp_pitch = LegSprawl(trial_i).data(frames) * 180/pi;
   
   pitches(trial_i) = min(temp_pitch);
%  plot(DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frames,3)*180/pi,DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frames,2)*180/pi);
%     plot(DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3)*180/pi);
    
    
end

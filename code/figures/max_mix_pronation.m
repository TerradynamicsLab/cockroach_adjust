
clear; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load superbar function
addpath(genpath([REPO,'/code/analysis/Dependences/scottclowe-superbar-ce333a9']));

% load database
load([REPO,'/data/kinematics/DataBase.mat']);


TrialNum = 36;

max_pron = nan(1,36);
min_pron = nan(1,36);
av_leftLS_app = nan(1,36);
av_rightLS_app = nan(1,36);
av_leftLS_roll = nan(1,36);
av_leftLS_exp = nan(1,36);
av_rightLS_roll = nan(1,36);
av_rightLS_exp = nan(1,36);

av_leftLH_exp = nan(1,36);
av_leftLH_roll = nan(1,36);
av_rightLH_exp= nan(1,36);
av_rightLH_roll = nan(1,36);

% calculate leg sprawl
for trial_i = 1:TrialNum
    for frame_i = 1:DataBase.Trial(trial_i).Info.FrameNum
        a = [DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,1:2),0];
        b = [DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,1:2),0];
        c = [-1,0,0];
        LegSprawl(trial_i).data(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
        LegSprawl_left(trial_i).data(frame_i) = atan2(norm(cross(a,c)), dot(a,c));
        if a(2)<0
            LegSprawl_left(trial_i).data(frame_i) = -LegSprawl_left(trial_i).data(frame_i);
        end
        LegSprawl_right(trial_i).data(frame_i) = atan2(norm(cross(b,c)), dot(b,c));
        if b(2)>0
            LegSprawl_right(trial_i).data(frame_i) = -LegSprawl_right(trial_i).data(frame_i);
        end
    end
    LLH(trial_i).data = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,3);
    RLH(trial_i).data = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,3);

    ExpPit_phase = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;
    Roll_phase = DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.RollMaxFrame;
    App_phase = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame;


    max_pron(trial_i) = nanmax(LegSprawl(trial_i).data(ExpPit_phase));
    min_pron(trial_i) = nanmin(LegSprawl(trial_i).data(Roll_phase));

    av_leftLS_app(trial_i) = nanmean(LegSprawl_left(trial_i).data(App_phase));
    av_leftLS_roll(trial_i) = nanmean(LegSprawl_left(trial_i).data(Roll_phase));
    av_leftLS_exp(trial_i) = nanmean(LegSprawl_left(trial_i).data(ExpPit_phase));
    av_rightLS_app(trial_i) = nanmean(LegSprawl_right(trial_i).data(App_phase));
    av_rightLS_roll(trial_i) = nanmean(LegSprawl_right(trial_i).data(Roll_phase));
    av_rightLS_exp(trial_i) = nanmean(LegSprawl_right(trial_i).data(ExpPit_phase));3

    av_leftLH_roll(trial_i) = nanmean(LLH(trial_i).data(Roll_phase));
    av_leftLH_exp(trial_i) = nanmean(LLH(trial_i).data(ExpPit_phase));
    av_rightLH_roll(trial_i) = nanmean(RLH(trial_i).data(Roll_phase));
    av_rightLH_exp(trial_i) = nanmean(RLH(trial_i).data(ExpPit_phase));
end

% mean(max_pron)*180/pi
% std(max_pron)*180/pi
% 
% mean(min_pron)*180/pi
% std(min_pron)*180/pi


mean(av_leftLS_roll)*180/pi
std(av_leftLS_roll)*180/pi

mean(av_leftLS_exp)*180/pi
std(av_leftLS_exp)*180/pi

mean(av_rightLS_roll)*180/pi
std(av_rightLS_roll)*180/pi

mean(av_rightLS_exp)*180/pi
std(av_rightLS_exp)*180/pi

disp("c")

mean(av_leftLS_app)*180/pi
std(av_leftLS_app)*180/pi

mean(av_rightLS_app)*180/pi
std(av_rightLS_app)*180/pi

disp("d")

mean(av_leftLH_roll)
std(av_leftLH_roll)

mean(av_leftLH_exp)
std(av_leftLH_exp)

disp("e")

mean(av_rightLH_roll)
std(av_rightLH_roll)

mean(av_rightLH_exp)
std(av_rightLH_exp)

% figure(1)
% hold on;
% for trial_i = 1:36
%     plot(LegSprawl_left(trial_i).data*180/pi,'Color','r')
% %     plot(LegSprawl_right(trial_i).data*180/pi,'Color','b')
% %     plot(LegSprawl(trial_i).data*180/pi,'Color','k')
% %     plot((LegSprawl(trial_i).data - LegSprawl_left(trial_i).data - LegSprawl_right(trial_i).data)*180/pi,'Color','k')
% end
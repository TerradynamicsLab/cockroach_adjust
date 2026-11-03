%% Yaqing created this function on 5/31/2020 to create labeled videos
clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

%% Loading Data
%  tracking data folder
csv_folder = [REPO,'/tracking/p2_DLC_for_leg_abdomen/tracking_result_flipped_video_csv/'];
%  how many points do you have?
PointNum = 8;
%  Which trial are you looking for?
Trials = 5;
%  Which cameras have you tracked manually? must sorted
Cams = 1:8;
Cams = sort(Cams);
Cam_num = length(Cams);
%  Where to save it?
save_folder = [REPO,'/output/labeled_videos/f3_manual_tracking/'];

%  calibration folder
cal_folder = [REPO,'/data/calibration/'];

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file);
info_frame_num = info_num(:,4);
info_cal_series = info_txt(2:end,8);

% loop trials
for trial_i = Trials
    disp(trial_i);
    frame_num = info_frame_num(trial_i);
    
    % load calibration
    cal_file = [cal_folder,'cal_',char(info_cal_series(trial_i)),'DLTcoefs.csv'];
    CalFile = load(cal_file);
    Cal = CalFile(:,Cams);
    
    % define file name and load data
    save_file = [save_folder,'Trial_',num2str(trial_i),'xypts.csv'];
    source_file = [save_folder,'Trial_',num2str(trial_i),'xyzpts.csv'];
    
    save_data = csvread(save_file,1,0);
    source_data = csvread(source_file,1,0);
    
    % loop frame and point
    for frame_i = 1:frame_num
        for point_i = 1:8
            if ~isnan(source_data(frame_i,3*(point_i-1)+1))
                xyz = source_data(frame_i,3*(point_i-1)+(1:3));
                for cam_i = Cams
                    Cal_ = Cal(:,cam_i);
                    UV = fDLT3D22D(Cal_,xyz);
                    save_data(frame_i,2*Cam_num*(point_i-1)+2*(cam_i-1)+1) = UV(1);
                    save_data(frame_i,2*Cam_num*(point_i-1)+2*(cam_i-1)+2) = UV(2);
                end
            end
        end
    end
    
    % save it
    csvwrite(save_file,save_data,1,0)
end
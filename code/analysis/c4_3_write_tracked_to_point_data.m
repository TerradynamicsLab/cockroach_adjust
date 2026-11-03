% Yaqing created this on 5/31/2020 do reconstruction on tracking of DLC

% proved to be more satisfying than v2, v3, and v4
clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
%  Which trial are you looking for?
Trials = [59];

%% Loading Data
%  tracking data folder
csv_folder = [REPO,'/data/reconstruction/f3_manual_tracking/'];
%  how many points do you have?
PointNum = 8;
%  Which cameras have you tracked manually? must sorted
Cams = 1:8;
Cams = sort(Cams);
cam_num = length(Cams);
%  Where to save it?
save_file = [REPO,'/data/reconstruction/point_data.mat'];
%  calibration folder
cal_folder = [REPO,'/data/calibration/'];

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file);
info_frame_num = info_num(:,4);
info_cal_series = info_txt(2:end,8);
infor_roll_dir = info_num(:,13);

%% Calculation
%  result struct holder
if exist(save_file,'file')
    load (save_file);
else
    PointData = struct();
end

% loop trials
for trial_i = Trials
    disp(trial_i);
    
    % load calibration
    cal_file = [cal_folder,'cal_',char(info_cal_series(trial_i)),'DLTcoefs.csv'];
    CalFile = load(cal_file);
    Cal = CalFile(:,Cams);
    
    % load csv
    track_file = [csv_folder,'Trial_',num2str(trial_i),'xypts.csv'];
    td = csvread(track_file,1,0);

    % loop frame
    frame_num = info_frame_num(trial_i);
    for frame_i = 1:frame_num
        for point_i = 1:8
            % load data
            Us = td(frame_i,(2*(point_i-1)*cam_num+1):2:2*point_i*cam_num);
            Vs = td(frame_i,(2*(point_i-1)*cam_num+2):2:2*point_i*cam_num);
            % calculation
            [a,b,c,res] = fReconstruction(Cal,Us,Vs);
            PointData(trial_i,point_i).xyz(frame_i,1:3) = [a,b,c];
            PointData(trial_i,point_i).res(frame_i) = res;
        end 
    end
    
end

%% save file
save(save_file,'PointData');
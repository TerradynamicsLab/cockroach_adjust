%% Yaqing created this function on 5/31/2020 to create labeled videos
% v1: using original csv files
% v2: using point_data.mat 

clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

%% Loading Data
%  tracking data folder
point_data = load([REPO,'/data/reconstruction/point_data.mat']);
point_data = point_data.PointData;

% how many points do you have?
PointNum = 8;
%  Which trial are you looking for?
Trials = 9;
%  Which cameras have you tracked manually? must sorted
Cams = 1:8;
Cams = sort(Cams);
Cam_num = length(Cams);
%  Where to save it?
save_folder = [REPO,'/output/f3_manual_tracking/'];
%  calibration folder
cal_folder = [REPO,'/data/calibration/'];

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file);
info_frame_num = info_num(:,4);
info_cal_series = info_txt(2:end,8);
infor_roll_dir = info_num(:,13);

% loop trials
for trial_i = Trials
    disp(trial_i);
    frame_num = info_frame_num(trial_i);
    
    % define file name
    save_file = [save_folder,'Trial_',num2str(trial_i),'xypts.csv'];
    template_file = [save_folder,'preparation\template.csv'];
    copyfile(template_file,save_file)
    save_file_2 = [save_folder,'Trial_',num2str(trial_i),'xyzpts.csv'];
    if ~exist(save_file_2,'file')
        template_file_2 = [save_folder,'preparation\template_2.csv'];
        copyfile(template_file_2,save_file_2)
    end
    save_file_3 = [save_folder,'Trial_',num2str(trial_i),'offsets.csv'];
    if ~exist(save_file_3,'file')
        template_file_3 = [save_folder,'preparation\template_3.csv'];
        copyfile(template_file_3,save_file_3)
    end
    save_file_4 = [save_folder,'Trial_',num2str(trial_i),'xyzres.csv'];
    if ~exist(save_file_4,'file')
        template_file_4 = [save_folder,'preparation\template_4.csv'];
        copyfile(template_file_4,save_file_4)
    end
    save_data = csvread(save_file,1,0);
    
    % load calibration
    cal_file = [cal_folder,'cal_',char(info_cal_series(trial_i)),'DLTcoefs.csv'];
    CalFile = load(cal_file);
    Cal = CalFile(:,Cams);
    
   
    % loop frame
    for frame_i = 1:frame_num
        for point_i = 1:8
            % load xyz
            XYZ = point_data(trial_i, point_i).xyz(frame_i,:);
            
            % loop cams
            for cam_i = Cams
                % calculation
                UV = fDLT3D22D(Cal(:,cam_i),XYZ);
                save_data(frame_i,2*Cam_num*(point_i-1)+2*(cam_i-1)+1) = UV(1);
                save_data(frame_i,2*Cam_num*(point_i-1)+2*(cam_i-1)+2) = UV(2);
            end
        end
    end
    
    % save it
    csvwrite(save_file,save_data,1,0)
end

% Yaqing created this on 5/31/2020 do reconstruction on tracking of DLC
% v1: use all labeled points
% v2: use only two labeled points and keep least residue

clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

%% Loading Data
%  tracking data folder
csv_folder = [REPO,'/tracking/p2_DLC_for_leg_abdomen/tracking_result_flipped_video_csv/'];
%  how many points do you have?
PointNum = 8;
%  Which trial are you looking for?
Trials = 1:133;
%  Which cameras have you tracked manually? must sorted
Cams = 1:8;
Cams = sort(Cams);
%  Where to save it?
save_file = [REPO,'/data/reconstruction/point_data_v2.mat'];
%  calibration folder
cal_folder = [REPO,'/data/calibration/'];
%  threshold for DLC annotation
DLC_thresh = 0.8;

% forbidden camera view combinations (i<j)
forbidden_i = [3,4,5];
forbidden_j = [6,8,7];
forbidden_num = length(forbidden_i);

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
    
    % load tracking data
    track_data = struct();
    for cam_i = Cams
        % rolling CW
        if infor_roll_dir(trial_i) == 1
            % load csv
            track_file = [csv_folder,'Trial_',num2str(trial_i),'_Cam_',num2str(cam_i),'_DLC.csv'];
            td = csvread(track_file,3,1);
            % due to resize, the transformation
            for point_i = 1:8
                td(:,3*point_i-2) = td(:,3*point_i-2)*4;
                td(:,3*point_i-1) = (512-td(:,3*point_i-1))*4;
            end
            track_data(cam_i).data = td;
        % rolling CCW  
        else
            % find the right camera
            cam_flip = [1,2,6,5,4,3,8,7];
            cam_i_ = cam_flip(cam_i);
            % load csv
            track_file = [csv_folder,'Trial_',num2str(trial_i),'_Cam_',num2str(cam_i_),'_DLC.csv'];
            td = csvread(track_file,3,1);
            % due to flip
            if cam_i == 1
                % flip vertical, y change
                for point_i = 1:8
                    td(:,3*point_i-1) = 512-td(:,3*point_i-1);
                end
            else
                % flip horizontally, x change
                for point_i = 1:8
                    td(:,3*point_i-2) = 648-td(:,3*point_i-2);
                end
            end
            % due to resize, the transformation
            for point_i = 1:8
                td(:,3*point_i-2) = td(:,3*point_i-2)*4;
                td(:,3*point_i-1) = (512-td(:,3*point_i-1))*4;
            end
            track_data(cam_i).data = td;
        end
    end

    % loop frame
    frame_num = info_frame_num(trial_i);
    for frame_i = 1:frame_num
        for point_i = 1:8
            % initial guess should be nan
            a = NaN;
            b = NaN;
            c = NaN;
            res = 10^6;
            % find a suitable cam combination
            for cam_i = Cams
                % cut off the case that DLC under thresh
                if track_data(cam_i).data(frame_i,3*point_i) < DLC_thresh
                    continue;
                end
                
                for cam_j = Cams
                    % sort in series
                    if cam_i >= cam_j
                        continue;
                    end
                    % forbidden combination
                    is_forbid = 0;
                    for forbid_id = 1:forbidden_num
                        if cam_i == forbidden_i(forbid_id) && cam_j == forbidden_j(forbid_id)
                            is_forbid = 1;
                            break;
                        end
                    end
                    if is_forbid == 1
                        continue;
                    end
                    % cut off the case that DLC under thresh
                    if track_data(cam_j).data(frame_i,3*point_i) < DLC_thresh
                        continue;
                    end
                    % calculation
                    Us = [track_data(cam_i).data(frame_i,3*point_i-2),track_data(cam_j).data(frame_i,3*point_i-2)];
                    Vs = [track_data(cam_i).data(frame_i,3*point_i-1),track_data(cam_j).data(frame_i,3*point_i-1)];
                    Cal = CalFile(:,[cam_i,cam_j]);
                    [a_,b_,c_,res_] = fReconstruction(Cal,Us,Vs);
                    if res_ < res
                        a = a_;
                        b = b_;
                        c = c_;
                        res = res_;
                    end
                end
            end
            PointData(trial_i,point_i).xyz(frame_i,1:3) = [a,b,c];
            PointData(trial_i,point_i).res(frame_i) = res;
        end 
    end
end

%% save file
save(save_file,'PointData','res');
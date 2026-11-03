% Yaqing created this on 5/31/2020 do reconstruction on tracking of DLC
% v1: use all labeled points
% v2: use only two labeled points and keep least residue
% v3: use two or more and keep least residue
% v4: set a residue limit and keep more camera

clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

%% Loading Data
%  tracking data folder
csv_folder = [REPO,'/tracking/p2_DLC_for_leg_abdomen/tracking_result_flipped_video_csv/'];
%  how many points do you have?
PointNum = 8;
%  Which trial are you looking for?
Trials = 1;%:133;
%  Which cameras have you tracked manually? must sorted
Cams = 1:8;
Cams = sort(Cams);
Cam_ref_max = 2^length(Cams)-1;
%  Where to save it?
save_file = [REPO,'/data/reconstruction/point_data_v4.mat'];
%  calibration folder
cal_folder = [REPO,'/data/calibration/'];
%  threshold for DLC annotation
DLC_thresh = 0.85;
residue_thresh = 3;

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
    disp(['Trial:',num2str(trial_i)]);
    
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
        disp(['Frame:',num2str(frame_i)]);
        for point_i = 1:8
            % initial guess should be nan
            xyz = [NaN,NaN,NaN];
            res_ratio = 10^6;
            cam_num_max = 0;
            
            % sweep camera combinations
            for Cam_ref = Cam_ref_max:-1:1
                Cam_ref_now = Cam_ref;
                cams_now = [];
                cam_num = 0;
                while(Cam_ref_now~=0)
                    cam_num = cam_num+1;
                    if mod(Cam_ref_now,2)==1
                        cams_now = [cams_now,cam_num];
                    end
                    Cam_ref_now = floor(Cam_ref_now/2);
                end
                % cut off the case that DLC under thresh
                cams_now_ = [];
                for cam_i = cams_now
                    if track_data(cam_i).data(frame_i,3*point_i) > DLC_thresh
                        cams_now_ = [cams_now_,cam_i];
                    end
                end
                cams_now = cams_now_;
                
                if length(cams_now) < cam_num_max
                    continue;
                end
                
%                 disp(cams_now);
                
                % if only one camera
                if length(cams_now) <2
                    continue;
                end
                % forbidden combination when 2 cameras
                if length(cams_now) == 2
                    is_forbid = 0;
                    for forbid_id = 1:forbidden_num
                        if cams_now(1) == forbidden_i(forbid_id) && cams_now(2) == forbidden_j(forbid_id)
                            is_forbid = 1;
                            break;
                        end
                    end
                    if is_forbid == 1
                        continue;
                    end
                end
                
                % calculation
                camPts = NaN(1,2*length(cams_now));
                id = 0;
                for cam_i = cams_now
                    id = id+1;
                    camPts(2*id-1) = track_data(cam_i).data(frame_i,3*point_i-2);
                    camPts(2*id) = track_data(cam_i).data(frame_i,3*point_i-1);
                end
                Cal = CalFile(:,cams_now);
                [xyz_,rmse_] = fdlt_reconstruct(Cal,camPts);
                if rmse_ < residue_thresh && length(cams_now) > cam_num_max
                    xyz = xyz_;
                    res_ratio = rmse_;
                    cam_num_max = length(cams_now);
                elseif rmse_ < residue_thresh && length(cams_now) == cam_num_max && rmse_ < res_ratio
                    xyz = xyz_;
                    res_ratio = rmse_;
                    cam_num_max = length(cams_now);
                end
%                 
%                 disp(rmse_);
                
            end
            PointData(trial_i,point_i).xyz(frame_i,1:3) = xyz;
            PointData(trial_i,point_i).rmse(frame_i) = res_ratio;
        end
    end
end

%% save file
save(save_file,'PointData');
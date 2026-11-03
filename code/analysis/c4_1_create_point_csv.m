%% Yaqing created this function on 5/31/2020 to create labeled videos
clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

%% Loading Data
%  tracking data folder
csv_folder = [REPO,'/tracking/p2_DLC_for_leg_abdomen/tracking_result_flipped_video_csv/'];

%  Which trial are you looking for?
Trials = [59];

%  how many points do you have?
PointNum = 8;
%  Which cameras have you tracked manually? must sorted
Cams = 1:8;
Cams = sort(Cams);
Cam_num = length(Cams);
%  Where to save it?
save_folder = [REPO,'/output/f3_manual_tracking/'];
%  threshold for DLC annotation
DLC_thresh = 0.8;

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file);
info_frame_num = info_num(:,4);
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
    % loop cams
    for cam_i_ = Cams
        if infor_roll_dir(trial_i) == 1
            cam_i = cam_i_;
            % load csv
            track_file = [csv_folder,'Trial_',num2str(trial_i),'_Cam_',num2str(cam_i),'_DLC.csv'];
            td = csvread(track_file,3,1);
            % due to resize, the transformation
            for point_i = 1:8
                td(:,3*point_i-2) = td(:,3*point_i-2)*4;
                td(:,3*point_i-1) = (512-td(:,3*point_i-1))*4;
            end
            track_data(cam_i).data = td;
            
            
        else
            cam_flip = [1,2,6,5,4,3,8,7];
            cam_i = cam_flip(cam_i_);
            % load csv
            track_file = [csv_folder,'Trial_',num2str(trial_i),'_Cam_',num2str(cam_i),'_DLC.csv'];
            td = csvread(track_file,3,1);
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
            track_data(cam_i_).data = td;
        end
        % loop frame
        for frame_i = 1:frame_num
            for point_i = 1:8
                if infor_roll_dir(trial_i) == 1
                    if track_data(cam_i_).data(frame_i,3*point_i) > DLC_thresh
                        save_data(frame_i,2*Cam_num*(point_i-1)+2*(cam_i_-1)+1) = track_data(cam_i_).data(frame_i,3*point_i-2);
                        save_data(frame_i,2*Cam_num*(point_i-1)+2*(cam_i_-1)+2) = track_data(cam_i_).data(frame_i,3*point_i-1);
                    end
                else
                    point_flip = [4,3,2,1,5,8,7,6];
                    point_i_ = point_flip(point_i);
                    if track_data(cam_i_).data(frame_i,3*point_i) > DLC_thresh
                        save_data(frame_i,2*Cam_num*(point_i_-1)+2*(cam_i_-1)+1) = track_data(cam_i_).data(frame_i,3*point_i-2);
                        save_data(frame_i,2*Cam_num*(point_i_-1)+2*(cam_i_-1)+2) = track_data(cam_i_).data(frame_i,3*point_i-1);
                    end
                end
            end
        end
    end
    
    % save it
    csvwrite(save_file,save_data,1,0)
end

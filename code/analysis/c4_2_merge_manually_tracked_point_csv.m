% this code is used to collect all the manually tracked points result
clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% which trial are you doing
Trial = 59;
start_frame = 37;
end_frame = 608;
frame_num = 686;

% other information
cam_num = 8;
point_num = 8;
% what is the tracking folder
folder = [REPO,'/output/f3_manual_tracking/'];

% load old data
old_file = [folder,'Trial_',num2str(Trial),'xypts.csv'];
if ~exist(old_file,'file')
    error("No old file.");
end
old_data = csvread(old_file,1,0);

% create insert data holder
insert_data = NaN(frame_num,2*point_num*cam_num);


% load manually tracked points 
for point_i = 1:8
    for cam_i = 1:8
        % see if file exist
        data_file = [folder,'Trial_',num2str(Trial),'_p',num2str(point_i),'c',num2str(cam_i),'xypts.csv'];
        if ~exist(data_file,'file')
            continue;
        end
        disp(['Found:Trial_',num2str(Trial),'_p',num2str(point_i),'c',num2str(cam_i)]);
        % load
        data_temp = csvread(data_file,1,0);
        insert_data(:,2*(point_i-1)*cam_num + 2*(cam_i-1)+(1:2)) = data_temp;
    end
end

% see if for any frame, any point, 2 camera view is inserted, then add to old_data
for frame_i = 1:frame_num
    for point_i = 1:8
        data_temp = insert_data(frame_i,(2*(point_i-1)*cam_num+1):2*point_i*cam_num);
        if sum(~isnan(data_temp))>2
            is_stop = 1;
            old_data(frame_i,(2*(point_i-1)*cam_num+1):2*point_i*cam_num) = data_temp;
        end
    end
end

% cut off start and end

old_data(1:start_frame-1,:) = nan;
old_data(end_frame+1:end,:) = nan;

% write back
csvwrite(old_file,old_data,1,0);

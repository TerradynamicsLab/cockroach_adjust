%%% this code is to gather all the videos we need and rename them.
clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
InfoFile = '..\d1_info\Info.xlsx';
[num,txt,raw] = xlsread(InfoFile,'selected_36');

% old_video_folder = '..\..\f1_300_Raw_videos\high_speed_videos\';
% new_video_folder = '..\f1_raw_videos\';
old_video_folder = [REPO,'/raw_videos/f1_raw_videos/'];
media = [REPO,'/output/f3_manual_tracking/'];
new_video_folder = [REPO,'/raw_videos/f2_raw_videos_36/'];

if exist(new_video_folder, 'dir')
    disp('New folder already exist');
else
    mkdir(new_video_folder)
end

%% Loop
for i = 1:length(num(:,1))
    disp(i);
    VideoName = char(txt(i+1,2));
    TrialNum = num(i,1);
    
    TrialNum_old = num(i,22);
    
    for Cam = 1:8
%         FileName = [old_video_folder 'CAM' num2str(Cam) '__' VideoName '.avi'];
%         newname = [new_video_folder 'Trial_' num2str(TrialNum) '_Cam_' num2str(Cam) '.avi'];
        FileName = [old_video_folder 'Trial_' num2str(TrialNum_old) '_Cam_' num2str(Cam) '.avi'];
        newname = [new_video_folder 'Trial_' num2str(TrialNum) '_Cam_' num2str(Cam) '.avi'];
        Info = dir(FileName);
        if isempty(Info)
            continue;
        end
        Info = dir(newname);
        if ~isempty(Info)
            continue;
        end
        Info = dir(FileName);
        if isempty(Info)
            disp(FileName);
            error("No such file.")
        end
        %% copy
        copyfile(FileName, media);
        oldname = [media 'Trial_' num2str(TrialNum_old) '_Cam_' num2str(Cam) '.avi'];
        newname = [media 'Trial_' num2str(TrialNum) '_Cam_' num2str(Cam) '.avi'];
        if (strcmp(oldname,newname)~=1)
            movefile(oldname, newname);
        end
        copyfile(newname, new_video_folder);
        is_stop = 1;
    end
end
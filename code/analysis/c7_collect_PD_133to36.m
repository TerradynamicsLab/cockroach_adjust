% Yaqing created this on 6/23/2020 to collect the point data in 133 to 36
clear;clc;close all;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% so where are they
point_data_file_133 = [REPO,'/data/reconstruction/point_data.mat'];
tag_data_folder_133 = [REPO,'/data/reconstruction/f2_tags/'];
data_file_36 = [REPO,'/data/kinematics/point_tag_data.mat'];
InfoFile = '..\d1_info\Info.xlsx';
[Info_num,Info_txt,Info_raw] = xlsread(InfoFile,'selected_36');

% load old point_data
old_PointData = load(point_data_file_133);
old_PointData = old_PointData.PointData;

% new struct
PT_data = struct();

% load data
for trial_id = Info_num(:,1)'
    old_trial_id = Info_num(trial_id,21);
    
    % load in point data
    for point_id = [1,4:8]
        PT_data.point.trial(trial_id).point(point_id).xyz = old_PointData(old_trial_id,point_id).xyz;
    end
    
    % load in tag data
    %%% tag number:
    %%% 1. body, line 2
    %%% 2. head, line 1
    %%% 3. left beam top, line (11-gap)
    %%% 4. right beam top, line (12-gap)
    old_tag_data_file = [tag_data_folder_133,'Trial_',num2str(old_trial_id),'.mat'];
    old_tag_data = load(old_tag_data_file);
    old_tag_data = old_tag_data.tag;
    
    gap = Info_num(trial_id,14);
    PT_data.tag.trial(trial_id).tag(1) = old_tag_data(2);
    PT_data.tag.trial(trial_id).tag(2) = old_tag_data(1);
    PT_data.tag.trial(trial_id).tag(3) = old_tag_data(11-gap);
    PT_data.tag.trial(trial_id).tag(4) = old_tag_data(12-gap);
    PT_data.tag.trial(trial_id).tag(1).ID = 1;
    PT_data.tag.trial(trial_id).tag(2).ID = 2;
    PT_data.tag.trial(trial_id).tag(3).ID = 3;
    PT_data.tag.trial(trial_id).tag(4).ID = 4;
end

% save data
save(data_file_36,'PT_data');



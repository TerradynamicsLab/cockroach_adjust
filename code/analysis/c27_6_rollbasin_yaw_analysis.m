close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% set project name and folder
project = struct();
project.name = 'barrier_5';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% video settings
is_video = 1;
video_folder = [[REPO,'/output/Yaqing_landscape_video/']];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
trial_i = 37;

% self_change variables
Xs = -24.2:0.2:33;
frame_num = length(Xs);
head_angles = -25:10:65;
y_displacements = 0;
yaws = -90:10:90;

%% create holders
RM_roll = nan(length(head_angles),length(yaws),frame_num);
RM_pitch = nan(length(head_angles),length(yaws),frame_num);
RM_E = nan(length(head_angles),length(yaws),frame_num);

% loop
for i_head_angle = 1:length(head_angles)
    for i_yaw = 1:length(yaws)
        
        % head_angle, y_displacement, yaw
        head_angle = head_angles(i_head_angle);
        y_displacement = y_displacements;
        yaw = yaws(i_yaw);
        
        % load landscape
        landscape_file = [project.folder,'compress_trial_',num2str(trial_i),'_head_angle_',num2str(head_angle),'_y_',num2str(y_displacement),'_yaw_',num2str(yaw),'.mat'];
        landscape_record = load(landscape_file);
        body_roll = landscape_record.data.body_roll;
        body_pitch = landscape_record.data.body_pitch;
        landscape = landscape_record.data.landscape_value;
        
        % load basin
        basin_select_file = [project.folder,'basin_select_coarse_trial_',num2str(trial_i),'_head_angle_',num2str(head_angle),'_y_',num2str(y_displacement),'_yaw_',num2str(yaw),'.mat'];
        temp_record = load(basin_select_file);
        
        % each frame
        for i_frame = 1:frame_num
            i_RM_roll = temp_record.record(5,i_frame);
            i_RM_pitch = temp_record.record(6,i_frame);
            RM_roll(i_head_angle,i_yaw,i_frame) = body_roll(i_frame,i_RM_roll,i_RM_pitch);
            RM_pitch(i_head_angle,i_yaw,i_frame) = body_pitch(i_frame,i_RM_roll,i_RM_pitch);
            RM_E(i_head_angle,i_yaw,i_frame) = landscape(i_frame,i_RM_roll,i_RM_pitch);
        end
        
    end
end

save([project.folder,'rollbasin2yaw_y_',num2str(y_displacements)],'RM_roll','RM_pitch','RM_E');

%%
load([project.folder,'rollbasin2yaw_y_',num2str(y_displacements)]);

%% video
if is_video
    video_name = [video_folder,'rollbasin2yaw_y_',num2str(y_displacements),'.avi'];
    v = VideoWriter(video_name);
    close(v);
    open(v);
end

[axis_head_angles,axis_yaw] = meshgrid(yaws,head_angles);
for f = 1:frame_num
    disp(f);
    if f == 1
        % figure
        figure(1);
        clf;
        % set(gcf,'Position',[2443 423 1124 490]);
        ti = title(['body X = ',num2str(Xs(f),'%.1f')]);
        hold on;
        
        s1 = surf(axis_head_angles,axis_yaw,RM_E(:,:,1)); %,'EdgeAlpha',0);
%         colormap(fire)
        xlabel('Body yaw (°)');
        ylabel('Head flexion (°)');
        xlim([-90,90]);
        ylim([-25,65]);
        view(-27,74);
    else
        ti = title(['body X = ',num2str(Xs(f),'%.1f')]);
        s1.ZData = RM_E(:,:,f);
    end
    
    if is_video
        % get frame and write in video
        frame = getframe(gcf);
        writeVideo(v,frame);
    else
        pause(0.2);
    end
    
end

% close video
if is_video
    close(v);
end

%% Energy to escape
for i_head_angle = 1:length(head_angles)
    head_angle = head_angles(i_head_angle);
    
    for i_frame = 1:frame_num
    
        
        
        
        
    end
end



    for i_yaw = 1:length(yaws)
        
        % head_angle, y_displacement, yaw
        
        y_displacement = y_displacements;
        yaw = yaws(i_yaw);
        









% Yaqing adopted this from D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroa
% ch_adjust_experiment\p2_64_selected\p3_head_analysis_barrier\barrier_stl
% _animal_data_1\pandora_space_analysis_compress_plot_stl_animal_data.m

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

project = struct();
% video settings
is_video = 0;

% set project name and folder
project.name = 'barrier_leg_2';
% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
video_folder = [[REPO,'/output/Yaqing_landscape/video/']];

if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end
addpath([REPO,'/code/model_construction/Dependences_stl']);


% focus on the ideal trial
trial_i = 37;
disp(['Trial: ',num2str(trial_i)]);

for leg_spr = 0:5:180
    
    disp(['leg_spr: ',num2str(leg_spr)]);
    load([[REPO,'/output/Yaqing_landscape_leg_2/'],'landscape_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat']);
    
    if is_video
        % load video writer
        video_file = [video_folder,'compress_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.avi'];
        v = VideoWriter(video_file);
        close(v);
        open(v);
    end
    
    % variables you fond.
    data = struct();
    data.body_x = nan(size(landscape.potential_energy,1),1);
    data.R_body_pitch = nan(size(landscape.potential_energy,1),1);
    data.R_body_roll = nan(size(landscape.potential_energy,1),1);
    data.body_roll = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.body_pitch = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.landscape_value = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.landscape_body_Z = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    
    % for each frame
    for f = 1:landscape.frame_num
        data.body_x(f) = landscape.var(f,1).data;
        data.R_body_pitch(f) = landscape.var(f,5).data;
        data.R_body_roll(f) = landscape.var(f,6).data;
        % loading your landscape at this head_pitch_b, this frame
        for i = 1:length(landscape.var(f,5).coordinate)
            for  j = 1:length(landscape.var(f,6).coordinate)
                % load a pixel
                data.body_pitch(f,j,i) = landscape.var(f,5).coordinate(i);
                data.body_roll(f,j,i) = landscape.var(f,6).coordinate(j);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                PEs = landscape.potential_energy(f,1,1,:,1,i,j,1,1,1,1,1,1);
                PEs = reshape(PEs,[length(PEs),1]);
                [data.landscape_value(f,j,i),i_body_Z] = min(PEs);
                data.landscape_body_Z(f,j,i) = landscape.var(f,3).coordinate(i_body_Z);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        
        % plot
        if is_video
            if f == 1
                colormap(fire)
                X = reshape(data.body_roll(f,:,:),[size(landscape.potential_energy,7),size(landscape.potential_energy,6)]);
                Y = reshape(data.body_pitch(f,:,:),[size(landscape.potential_energy,7),size(landscape.potential_energy,6)]);
                Z = reshape(data.landscape_value(f,:,:),[size(landscape.potential_energy,7),size(landscape.potential_energy,6)]);
                s = surf(X*180/pi,Y*180/pi,Z,'EdgeAlpha',0);
                xlabel('Body roll (°)');
                ylabel('Body pitch (°)');
                xlim([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi);
                ylim([landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi);
                % zlim([0,6]);
                view([-135,70])
            else
                Z = reshape(data.landscape_value(f,:,:),[size(landscape.potential_energy,7),size(landscape.potential_energy,6)]);
                s.ZData = Z;
            end
            
            % get frame and write in video
            frame = getframe(gcf);
            writeVideo(v,frame);
        end
        A_stop_sign = 1;
        disp(['Frame:',num2str(f)]);
        
    end
    
    % close video
    if is_video
        close(v);
    end
    
    % save data
    save([project.folder,'compress_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat'],'data');
    
end
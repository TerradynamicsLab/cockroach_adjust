% Yaqing adopted this from D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroa
% ch_adjust_experiment\p2_64_selected\p3_head_analysis_barrier\barrier_stl
% _animal_data_1\pandora_space_analysis_compress_plot_stl_animal_data.m

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

project = struct();
% video settings
is_video = 1;

% set project name and folder
project.name = 'barrier_32';
% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
video_folder = [[REPO,'/output/'],project.name,'\video\'];

if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end
addpath([REPO,'/code/model_construction/Dependences_stl']);


% focus on the ideal trial
trial_i = 38;
disp(['Trial: ',num2str(trial_i)]);

Xs = nan(19,91,296);
Ys = nan(19,91,296);
Zs = nan(19,91,296);
head_flexions = -25:5:65;


for i_head_flexion = 1:19
    head_flexion = head_flexions(i_head_flexion);
    disp(['head_flexion:',num2str(head_flexion)]);
    
    landscape_folder = project.folder;
    load([landscape_folder,'landscape_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat']);
    
    % variables you fond.
    data = struct();
    data.body_x = nan(size(landscape.potential_energy,1),1);
    data.R_body_pitch = nan(size(landscape.potential_energy,1),1);
    data.R_body_roll = nan(size(landscape.potential_energy,1),1);
    data.body_roll = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.body_pitch = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.landscape_value = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.landscape_body_Z = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.landscape_left_angle = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    data.landscape_right_angle = nan(size(landscape.potential_energy,1),size(landscape.potential_energy,7),size(landscape.potential_energy,6));
    
    % for each frame
    for f = 1:landscape.frame_num
        data.body_x(f) = landscape.var(f,1).data;
        data.R_body_yaw(f) = landscape.var(f,4).data;
        % loading your landscape at this head_pitch_b, this frame
        for i = 1:length(landscape.var(f,4).coordinate)
            % load a pixel
            data.body_yaw(f,i) = landscape.var(f,4).coordinate(i);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            PEs = landscape.potential_energy(f,:,i);
            LAs = landscape.left_beam_angle(f,:,i);
            RAs =  landscape.right_beam_angle(f,:,i);
            
            PEs = reshape(PEs,[length(PEs),1]);
            LAs = reshape(LAs,[length(LAs),1]);
            RAs = reshape(RAs,[length(RAs),1]);
            [data.landscape_value(f,i),i_body_Z] = min(PEs);
            data.landscape_body_Z(f,i) = landscape.var(f,3).coordinate(i_body_Z);
            data.landscape_left_angle(f,i) = LAs(i_body_Z);
            data.landscape_right_angle(f,i) = RAs(i_body_Z);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        % plot
        Xs(i_head_flexion,:,f) = -90:2:90;
        Ys(i_head_flexion,:,f) = ones(1,91)*head_flexion;
        Zs(i_head_flexion,:,f) = reshape(data.landscape_value(f,:),[1,91]);
        
        % save data
        save([project.folder,'compress_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat'],'data');
    end
end
save([project.folder,'plot_data.mat'],'Xs','Ys','Zs');

%%
if is_video
    load([project.folder,'plot_data.mat']);
    % load video writer
    video_file = [video_folder,'compress_trial_',num2str(trial_i),'.avi'];
    v = VideoWriter(video_file);
    close(v);
    open(v);
    
    for f = 1:296
        if f == 1
            colormap(fire)
            X = Xs(:,:,f);
            Y = Ys(:,:,f);
            Z = Zs(:,:,f);
            s = surf(Y,X,Z,'EdgeAlpha',0);
            xlabel('Head flexion (°)');
            ylabel('Body yaw (°)');
            xlim([-25,65]);
            ylim([-90,90]);
            zlim([0,2.1]);
            view([-135,70])
            
            set(gca, 'XDir','reverse')
        else
            Z = Zs(:,:,f);
            s.ZData = Z;
        end
        
        % get frame and write in video
        frame = getframe(gcf);
        writeVideo(v,frame);
        disp(['Frame:',num2str(f)]);
        
        A_stop_sign = 1;
    end
    
    % close video
    close(v);
end


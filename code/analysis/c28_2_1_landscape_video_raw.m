% Yaqing adopted this from D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroa
% ch_adjust_experiment\p2_64_selected\p3_head_analysis_barrier\barrier_stl
% _animal_data_1\pandora_space_analysis_compress_plot_stl_animal_data.m

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

project = struct();

% set project name and folder
project.name = 'barrier_leg';
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
    load([project.folder,'compress_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat']);
    
    % load video writer
    video_file = [video_folder,'compress_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.avi'];
    v = VideoWriter(video_file);
    close(v);
    open(v);

    % for each frame
    for f = 1:length(data.body_x)
        sizes = [size(data.landscape_value,2),size(data.landscape_value,3)];
        
        % plot
            if f == 1
                colormap(fire)
                X = reshape(data.body_roll(f,:,:),sizes);
                Y = reshape(data.body_pitch(f,:,:),sizes);
                Z = reshape(data.landscape_value(f,:,:),sizes);
                
                X = [-X(end:-1:1,:);X];
                Y = [Y(end:-1:1,:);Y];
                Z = [Z(end:-1:1,:);Z];
                
                s = surf(X*180/pi,Y*180/pi,Z,'EdgeAlpha',0);
                xlabel('Body roll (°)');
                ylabel('Body pitch (°)');
                xlim([-90,90]);
                ylim([-90,90]);
                % zlim([0,6]);
                view([-135,70])
            else
                Z = reshape(data.landscape_value(f,:,:),sizes);
                Z = [Z(end:-1:1,:);Z];
                s.ZData = Z;
            end
            
            % get frame and write in video
            frame = getframe(gcf);
            writeVideo(v,frame);
            
        A_stop_sign = 1;
        disp(['Frame:',num2str(f)]);
        
    end
    
    % close video
    close(v);
    
    % save data
    save([project.folder,'compress_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat'],'data');
    
end
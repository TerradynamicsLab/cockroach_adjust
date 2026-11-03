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

body_X = -26:0.2:31.2;
increment = 0.01;

load([REPO,'/output/landscape/barrier_32/plot_data.mat'])

% holders
yaw_stay = nan(19,287);
yaw_def_left = nan(19,287);
yaw_Saddle_left = nan(19,287);
yaw_def_right = nan(19,287);
yaw_Saddle_right = nan(19,287);
energy_stay = nan(19,287);
energy_def_left = nan(19,287);
energy_Saddle_left = nan(19,287);
energy_def_right = nan(19,287);
energy_Saddle_right = nan(19,287);

if is_video
    % load video writer
    video_file = [video_folder,'basin_trial_',num2str(trial_i),'.avi'];
    v = VideoWriter(video_file);
    close(v);
    open(v);
end

for f = 1:287
    Z = Zs(:,:,f);
    
    for i_head_flexion = 1:19
        temp_Z = Z(i_head_flexion,:);
        [pks,locs] = findpeaks(-temp_Z);
        % find critical points
        if isempty(locs)
            yaw_stay(i_head_flexion,f) = 46;
            yaw_def_left(i_head_flexion,f) = 46;
            yaw_Saddle_left(i_head_flexion,f) = 46;
            yaw_def_right(i_head_flexion,f) = 46;
            yaw_Saddle_right(i_head_flexion,f) = 46;
        else
            [~,loc_stay] = min(abs(locs-40));
            loc_stay = locs(loc_stay);
            yaw_stay(i_head_flexion,f) = loc_stay;
            
            loc_def_left = locs(end);
            if(temp_Z(91)<temp_Z(loc_def_left))
                loc_def_left = 91;
            end
            yaw_def_left(i_head_flexion,f) = loc_def_left;
            
            [~,loc_Saddle_left] = max(temp_Z(loc_stay:loc_def_left));
            loc_Saddle_left = loc_Saddle_left + loc_stay - 1;
            yaw_Saddle_left(i_head_flexion,f) = loc_Saddle_left;
            
            loc_def_right = locs(1);
            if(temp_Z(1)<temp_Z(loc_def_right))
                loc_def_left = 1;
            end
            yaw_def_right(i_head_flexion,f) = loc_def_right;
            
            [~,loc_Saddle_right] = max(temp_Z(loc_def_right:loc_stay));
            loc_Saddle_right = loc_Saddle_right + loc_def_right - 1;
            yaw_Saddle_right(i_head_flexion,f) = loc_Saddle_right;
        end
        
        energy_stay(i_head_flexion,f) = temp_Z(yaw_stay(i_head_flexion,f));
        energy_def_left(i_head_flexion,f) = temp_Z(yaw_def_left(i_head_flexion,f));
        energy_Saddle_left(i_head_flexion,f) = temp_Z(yaw_Saddle_left(i_head_flexion,f));
        energy_def_right(i_head_flexion,f) = temp_Z(yaw_def_right(i_head_flexion,f));
        energy_Saddle_right(i_head_flexion,f) = temp_Z(yaw_Saddle_right(i_head_flexion,f));
    end
    
    if f == 1
        figure(1);
        clf;
        subplot(1,2,1);
        set(gcf,'Position',[379 789 2.0447e+03 420]);
        ti = title(['body X = ',num2str(body_X(f),'%.1f')]);
        hold on;
        
        colormap(fire);
        s1 = surf(Z,'EdgeAlpha',0);
        colorbar;
        
        l_stay = plot3(yaw_stay(:,f),1:19,energy_stay(:,f)+increment,'LineStyle','-','LineWidth',5,'Color','b');
        l_def_left = plot3(yaw_def_left(:,f),1:19,energy_def_left(:,f)+increment,'LineStyle','-','LineWidth',3,'Color','r');
        l_Saddle_left = plot3(yaw_Saddle_left(:,f),1:19,energy_Saddle_left(:,f)+increment,'LineStyle','-','LineWidth',3,'Color',[0.9294,0.6902,0.1294]);
        
        xlim([0,91]);
        ylim([0,19]);
        zlim([0,2.2]);
        view([-180,70]);
        
        subplot(1,2,2);
        ti = title(['body X = ',num2str(body_X(f),'%.1f')]);
        hold on;
        s2 = surf(Z,'EdgeAlpha',0);
        colorbar;
        l_stay2 = plot3(yaw_stay(:,f),1:19,energy_stay(:,f)+increment,'LineStyle','-','LineWidth',5,'Color','b');
        l_def_right = plot3(yaw_def_right(:,f),1:19,energy_def_right(:,f)+increment,'LineStyle','-','LineWidth',3,'Color','r');
        l_Saddle_right = plot3(yaw_Saddle_right(:,f),1:19,energy_Saddle_right(:,f)+increment,'LineStyle','-','LineWidth',3,'Color',[0.9294,0.6902,0.1294]);
        
        xlim([0,91]);
        ylim([0,19]);
        zlim([0,2.2]);
        view([-180,70]);
    else
        subplot(1,2,1);
        ti = title(['body X = ',num2str(body_X(f),'%.1f')]);
        subplot(1,2,2);
        ti = title(['body X = ',num2str(body_X(f),'%.1f')]);
        s1.ZData = Z;
        s2.ZData = Z;
        l_stay.XData = yaw_stay(:,f);
        l_stay.ZData = energy_stay(:,f)+increment;
        l_stay2.XData = yaw_stay(:,f);
        l_stay2.ZData = energy_stay(:,f)+increment;
        l_def_left.XData = yaw_def_left(:,f);
        l_def_left.ZData = energy_def_left(:,f)+increment;
        l_Saddle_left.XData = yaw_Saddle_left(:,f);
        l_Saddle_left.ZData = energy_Saddle_left(:,f)+increment;
        l_def_right.XData = yaw_def_right(:,f);
        l_def_right.ZData = energy_def_right(:,f)+increment;
        l_Saddle_right.XData = yaw_Saddle_right(:,f);
        l_Saddle_right.ZData = energy_Saddle_right(:,f)+increment;
    end
    if is_video
        % get frame and write in video
        frame = getframe(gcf);
        writeVideo(v,frame);
    else
        pause(0.2);
    end
end
if is_video
    close(v);
end

save([project.folder,'basin_trial_',num2str(trial_i),'_2.mat'],...
    'yaw_stay','yaw_def_left', 'yaw_Saddle_left', 'yaw_def_right',...
    'yaw_Saddle_right', 'energy_stay', 'energy_def_left', 'energy_Saddle_left',...
    'energy_def_right', 'energy_Saddle_right');

figure(2)
barrier_left = energy_Saddle_left- energy_stay;
plot(barrier_left')

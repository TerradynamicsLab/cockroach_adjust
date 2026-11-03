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
i_head = 9;
increment = 0.01;

load([project.folder,'basin_trial_',num2str(trial_i),'.mat']);
load([REPO,'/output/landscape/barrier_32/plot_data.mat'])


if is_video
    % load video writer
    video_file = [video_folder,'basin_trial_',num2str(trial_i),'_2.avi'];
    v = VideoWriter(video_file);
    close(v);
    open(v);
end


for frame_i = 1:length(body_X)
    X = Xs(:,:,frame_i);
    Y = Ys(:,:,frame_i);
    Z = Zs(:,:,frame_i);
    
    yaw_def_left_temp = yaw_def_left(i_head,frame_i);
    yaw_def_right_temp = yaw_def_right(i_head,frame_i);
    
    if frame_i == 1
        % plot
        figure(10);
        set(gcf, 'Position',[480 169 1440 500]);
        clf;
        subplot(1,2,1)
        hold on;
        ti = title(['Body X: ',num2str(body_X(frame_i),'%.1f'),' mm']);
        colormap(fire);
        s1 = surf(X,Y,Z,'EdgeAlpha',0);
        colorbar;
        xlim([-90,90]);
        ylim([-25,65]);
        zlim([0,2.2]);
        view([-135,70]);
        set(gca,'FontSize', 20);
        
        route_X = X(i_head,yaw_def_right_temp:yaw_def_left_temp);
        route_Z = Z(i_head,yaw_def_right_temp:yaw_def_left_temp);
        l1 = plot3(route_X,route_Z*0+15,route_Z,'LineStyle','-','LineWidth',3,'Color','g');
        
        p11 = plot3(X(i_head,yaw_stay(i_head,frame_i)),...
            Y(i_head,yaw_stay(i_head,frame_i)),...
            Z(i_head,yaw_stay(i_head,frame_i))+increment,'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p12 = plot3(X(i_head,yaw_def_left(i_head,frame_i)),...
            Y(i_head,yaw_def_left(i_head,frame_i)),...
            Z(i_head,yaw_def_left(i_head,frame_i))+increment,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p13 = plot3(X(i_head,yaw_Saddle_left(i_head,frame_i)),...
            Y(i_head,yaw_Saddle_left(i_head,frame_i)),...
            Z(i_head,yaw_Saddle_left(i_head,frame_i))+increment,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p14 = plot3(X(i_head,yaw_def_right(i_head,frame_i)),...
            Y(i_head,yaw_def_right(i_head,frame_i)),...
            Z(i_head,yaw_def_right(i_head,frame_i))+increment,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p15 = plot3(X(i_head,yaw_Saddle_right(i_head,frame_i)),...
            Y(i_head,yaw_Saddle_right(i_head,frame_i)),...
            Z(i_head,yaw_Saddle_right(i_head,frame_i))+increment,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        
        ax1 = gca;
        axHidden = axes('Visible','off','hittest','off'); % Invisible axes
        linkprop([ax1 axHidden],{'CameraPosition' 'XLim' 'YLim' 'ZLim' 'Position'}); % The axes should stay aligned
        set(p11,'Parent',axHidden); % Put the text in the invisible Axes
        set(p12,'Parent',axHidden); % Put the text in the invisible Axes
        set(p13,'Parent',axHidden); % Put the text in the invisible Axes
        set(p14,'Parent',axHidden); % Put the text in the invisible Axes
        set(p15,'Parent',axHidden); % Put the text in the invisible Axes
    else
        route_X = X(i_head,yaw_def_right_temp:yaw_def_left_temp);
        route_Z = Z(i_head,yaw_def_right_temp:yaw_def_left_temp);
        l1.XData = route_X;
        l1.YData = route_X*0+15;
        l1.ZData = route_Z;
        
        ti.String = ['Body X: ',num2str(body_X(frame_i),'%.1f'),' mm'];
        s1.ZData = Z;
        p11.XData = X(i_head,yaw_stay(i_head,frame_i));
        p11.ZData = Z(i_head,yaw_stay(i_head,frame_i))+increment;
        p12.XData = X(i_head,yaw_def_left(i_head,frame_i));
        p12.ZData = Z(i_head,yaw_def_left(i_head,frame_i))+increment;
        p13.XData = X(i_head,yaw_Saddle_left(i_head,frame_i));
        p13.ZData = Z(i_head,yaw_Saddle_left(i_head,frame_i))+increment;
        p14.XData = X(i_head,yaw_def_right(i_head,frame_i));
        p14.ZData = Z(i_head,yaw_def_right(i_head,frame_i))+increment;
        p15.XData = X(i_head,yaw_Saddle_right(i_head,frame_i));
        p15.ZData = Z(i_head,yaw_Saddle_right(i_head,frame_i))+increment;
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
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% video settings
is_video = 1;

% set project name and folder
project = struct();
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

trial_i = 37;
for leg_spr = 0%:5:180
    % holder
    xPitch1s = [];
    yPitch1s = [];
    xPitch2s = [];
    yPitch2s = [];
    xRolls = [];
    yRolls = [];
    
    load([project.folder,'compress_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat']);

    if is_video
        % load video writer
        video_file = [video_folder,'basin_select_coarse_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.avi'];
        v = VideoWriter(video_file);
        close(v);
        open(v);
    end
    
    for f = 1:size(data.landscape_value,1)
        disp(f);

        % load data
        sizes = [size(data.body_roll,2),size(data.body_roll,3)];
        X = reshape(data.body_roll(1,:,:),sizes);
        Y = reshape(data.body_pitch(1,:,:),sizes);
        Z = reshape(data.landscape_value(f,:,:),sizes);
        
        X = [-X(end:-1:2,:);X]';
        Y = [Y(end:-1:2,:);Y]';
        Z = [Z(end:-1:2,:);Z]';
        landscape = Z;
        
        [xPitch1,yPitch1,xPitch2,yPitch2,xRoll,yRoll] = select_minima_coarse(landscape);
        [Xs,Ys,Zs] = find_all_minima(landscape,1,1);
        minima_num = length(Xs);
        for i = 1:minima_num
            minima_X(i) = X(Ys(i),Xs(i))*180/pi;
            minima_Y(i) = Y(Ys(i),Xs(i))*180/pi;
            minima_Z(i) = Z(Ys(i),Xs(i));
        end
        if f == 1
            
            
            % figure
            figure(1);
            clf;
            %             set(gcf,'Position',[2443 423 1124 490]);
            ti = title(['body X = ',num2str(data.body_x(f),'%.1f')]);
            hold on;
            
            s1 = surf(X*180/pi,Y*180/pi,Z,'EdgeAlpha',0);
            colormap(fire)
            axis equal
            xlabel('Body roll (°)');
            ylabel('Body pitch (°)');
            xlim([-180,180]);
            ylim([-180,180]);
            % zlim([0,6]);
            view([0,-90])
            line([-180,180],[0,0]+2.5,...
                'Color','g','LineWidth',3);
            line([-180,180],[90,90]+2.5,...
                'Color','g','LineWidth',3);
            line([-180,180],[-90,-90]+2.5,...
                'Color','g','LineWidth',3);
            line([0,0]+2.5,[-180,180],...
                'Color','g','LineWidth',3);
            line([90,90]+2.5,[-180,180],...
                'Color','g','LineWidth',3);
            line([-90,-90]+2.5,[-180,180],...
                'Color','g','LineWidth',3);
            p1 = plot(minima_X+2.5,minima_Y+2.5,'.','MarkerSize',50,'Color','g');
            pp2 = plot(X(yPitch2,xPitch2)*180/pi+2.5,Y(yPitch2,xPitch2)*180/pi+2.5,'.','MarkerSize',50,'Color',[0.5,0.5,1]);
            pp1 = plot(X(yPitch1,xPitch1)*180/pi+2.5,Y(yPitch1,xPitch1)*180/pi+2.5,'.','MarkerSize',50,'Color','b');
            pr = plot(X(yRoll,xRoll)*180/pi+2.5,Y(yRoll,xRoll)*180/pi+2.5,'.','MarkerSize',50,'Color','r');
            
        else
            ti = title(['body X = ',num2str(data.body_x(f),'%.1f')]);
            s1.ZData = Z;
            p1.XData = minima_X+2.5;
            p1.YData = minima_Y+2.5;
            pp1.XData = X(yPitch1,xPitch1)*180/pi+2.5;
            pp1.YData = Y(yPitch1,xPitch1)*180/pi+2.5;
            pp2.XData = X(yPitch2,xPitch2)*180/pi+2.5;
            pp2.YData = Y(yPitch2,xPitch2)*180/pi+2.5;
            pr.XData = X(yRoll,xRoll)*180/pi+2.5;
            pr.YData = Y(yRoll,xRoll)*180/pi+2.5;
        end
        if is_video
            % get frame and write in video
            frame = getframe(gcf);
            writeVideo(v,frame);
        else
            pause(0.2);
        end
        % record
        xPitch1s = [xPitch1s,xPitch1];
        yPitch1s = [yPitch1s,yPitch1];
        xPitch2s = [xPitch2s,xPitch2];
        yPitch2s = [yPitch2s,yPitch2];
        xRolls = [xRolls,xRoll];
        yRolls = [yRolls,yRoll];
        
        A_stop_sign = 1;
        
        
    end
     % close video
    if is_video
        close(v);
    end
    % save record
    record = [xPitch1s;yPitch1s;xPitch2s;yPitch2s;xRolls;yRolls];
    save([project.folder,'basin_select_coarse_trial_',num2str(trial_i),'_leg_spr_',num2str(leg_spr),'.mat'],'record');
end


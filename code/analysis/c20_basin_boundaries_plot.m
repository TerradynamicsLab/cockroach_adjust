close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

is_re = 0;
beam_cal_re = 0;
is_fix = 1;

% video settings
is_video = 0;

% set project name and folder
project = struct();
project.name = 'barrier_3';
% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
video_folder = [[REPO,'/output/'],project.name,'\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

for trial_i = 37
    disp(['Trial: ',num2str(trial_i)]);
    load([project.folder,'landscape_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
    load([project.folder,'data_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
    load([project.folder,'basin_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
    if is_video
        % load video writer
        video_file = [video_folder,'basin_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.avi'];
        v = VideoWriter(video_file);
        close(v);
        open(v);
    end
    
    for f = 1:length(data.body_x)
        % plot
        if f == 1
            % load data
            sizes = [size(data.body_roll,2),size(data.body_roll,3)];
            X = reshape(data.body_roll(f,:,:),sizes);
            Y = reshape(data.body_pitch(f,:,:),sizes);
            Z = reshape(data.landscape_value(f,:,:),sizes);
            basin = basin_landscape(f).data'; %%%% why transpose?
            
            % find minima
            [Xs,Ys,Zs] = find_all_minima(Z,1,1);
            minima_num = length(Xs);
            for i = 1:minima_num
                minima_X(i) = X(Ys(i),Xs(i))*180/pi;
                minima_Y(i) = Y(Ys(i),Xs(i))*180/pi;
                minima_Z(i) = Z(Ys(i),Xs(i));
            end
            
            % figure
            figure(1);
            set(gcf,'Position',[2443 423 1124 490]);
            ti = title(["body X = ",num2str(data.body_x(f))]);
            hold on;
            
            % sp1
            sp1 = subplot(1,2,1);
            hold on;
            s1 = surf(X*180/pi,Y*180/pi,Z,'EdgeAlpha',0);
            colormap(sp1,fire)
            xlabel('Body roll (°)');
            ylabel('Body pitch (°)');
            xlim([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi);
            ylim([landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi);
            % zlim([0,6]);
            view([0,-90])
            line([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi,[0,0]+2.5,...
                'Color','g','LineWidth',3);
            line([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi,[90,90]+2.5,...
                'Color','g','LineWidth',3);
            line([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi,[-90,-90]+2.5,...
                'Color','g','LineWidth',3);
            line([0,0]+2.5,[landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi,...
                'Color','g','LineWidth',3);
            line([90,90]+2.5,[landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi,...
                'Color','g','LineWidth',3);
            line([-90,-90]+2.5,[landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi,...
                'Color','g','LineWidth',3);
            p1 = plot(minima_X+2.5,minima_Y+2.5,'.','MarkerSize',50,'Color','g');
            
            % sp2
            sp2 = subplot(1,2,2);
            hold on;
            s2 = surf(X*180/pi,Y*180/pi,basin,'EdgeAlpha',0);
            colormap(sp2,jet)
            xlabel('Body roll (°)');
            ylabel('Body pitch (°)');
            xlim([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi);
            ylim([landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi);
            % zlim([0,6]);
            view([0,-90])
            line([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi,[0,0]+2.5,...
                'Color','w','LineWidth',3);
            line([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi,[90,90]+2.5,...
                'Color','w','LineWidth',3);
            line([landscape.var(f,6).coordinate(1),landscape.var(f,6).coordinate(end)]*180/pi,[-90,-90]+2.5,...
                'Color','w','LineWidth',3);
            line([0,0]+2.5,[landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi,...
                'Color','w','LineWidth',3);
            line([90,90]+2.5,[landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi,...
                'Color','w','LineWidth',3);
            line([-90,-90]+2.5,[landscape.var(f,5).coordinate(1),landscape.var(f,5).coordinate(end)]*180/pi,...
                'Color','w','LineWidth',3);
            p2 = plot(minima_X+2.5,minima_Y+2.5,'.','MarkerSize',50,'Color','w');
            A_stop_sign = 1;
        else
            Z = reshape(data.landscape_value(f,:,:),sizes);
            basin = basin_landscape(f).data';  %%%% why transpose?            
            s1.ZData = Z;
            s2.ZData = basin;
            % find minima
            [Xs,Ys,Zs] = find_all_minima(Z,1,1);
            minima_num = length(Xs);
            minima_X = [];
            minima_Y = [];
            minima_Z = [];
            for i = 1:minima_num
                minima_X(i) = X(Ys(i),Xs(i))*180/pi;
                minima_Y(i) = Y(Ys(i),Xs(i))*180/pi;
                minima_Z(i) = Z(Ys(i),Xs(i));
            end
            p1.XData = minima_X+2.5;
            p1.YData = minima_Y+2.5;
            p2.XData = minima_X+2.5;
            p2.YData = minima_Y+2.5;
            
        end
        if is_video
            % get frame and write in video
            frame = getframe(gcf);
            writeVideo(v,frame);
        else
            pause(0.3);
        end
        A_stop_sign = 1;
        disp(['Frame:',num2str(f)]);
        
    end
    
    % close video
    if is_video
        close(v);
    end
    
    
    
    
end
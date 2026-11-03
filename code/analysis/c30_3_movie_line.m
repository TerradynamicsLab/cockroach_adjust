% check c6_create_labeled_video.m
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
addpath('Dependences\');
addpath([REPO,'/code/model_construction/Dependences_stl/']);

for is_head_abdomen = 0%0:1

font_size = 20;

% specify the trials and cams
for trial_i = 5%1:36
    
    disp('d')
    disp(trial_i)
    
    % video folder
    if is_head_abdomen
        video_folder = [[REPO,'/output/Yaqing_sup_video/head_abdomen/trial_'],num2str(trial_i),'\'];
    else
        video_folder = [[REPO,'/output/Yaqing_sup_video/leg_sprawl_height/trial_'],num2str(trial_i),'\'];
    end
    if ~exist(video_folder, 'dir')
        mkdir(video_folder)
    end
    
    % frames
    frames = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame;
    
    % data
    time = (frames-frames(1))/100;
    if is_head_abdomen
        head_flexion = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frames,2)*180/pi;
        abdomen_flexion = - DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frames,2)*180/pi;
    else
        leg_sprawl = nan(1,frames(end));
        for frame_i = frames
            a = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
            b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
            a = [a(1:2),0];
            b = [b(1:2),0];
            leg_sprawl(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
        end
        leg_sprawl = leg_sprawl(frames)*180/pi;
        leg_height_L = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frames,3);
        leg_height_R = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frames,3);
    end
    
    fig = figure(1);
    set(gcf,'position',[200,100, 2592/2,2048/2]);
    set(gcf,'PaperPosition',[0,0,2592,2048]/100)
    set(gca,'position',[0,0,1,1]);
    
    sp1 = subplot(2,1,1);
    if is_head_abdomen
        plot(time,head_flexion,'Color','k','LineWidth',5);
    else
        plot(time,leg_sprawl,'Color','k','LineWidth',5);
    end
    set(gca, 'FontSize', font_size);
    xlim([0 time(end)]);
    hold on;
    ax = gca;
%     line(ax.XLim,[0,0],'Color','k','LineStyle','--','LineWidth',2)
    l1 = line([0,0],ax.YLim,'Color',[0.2,0.8,0],'LineStyle','--','LineWidth',3);
    
    sp2 = subplot(2,1,2);
    if is_head_abdomen
        plot(time,abdomen_flexion,'Color','k','LineWidth',5);
    else
        hold on;
        box on;
        plot(time,leg_height_L,'Color','b','LineWidth',5);
        plot(time,leg_height_R,'Color','r','LineWidth',5);
    end
    ylim([-22 5]); %%%%%%%
    set(gca, 'FontSize', font_size);
    xlim([0 time(end)]);
    hold on;
    ax = gca;
    line(ax.XLim,[0,0],'Color','k','LineStyle','--','LineWidth',2)
    l2 = line([0,0],ax.YLim,'Color',[0.2,0.8,0],'LineStyle','--','LineWidth',3);
    
    for frame_i = 1:length(time)
        
        l1.XData = [time(frame_i),time(frame_i)];
        l2.XData = [time(frame_i),time(frame_i)];
        
        % save figure
        drawnow;
        print([video_folder,'Frame_',num2str(frame_i,'%03.f'),'.jpg'],'-djpeg','-r100');
        
    end
    
    
end

end


% check c6_create_labeled_video.m
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
addpath('Dependences\');
addpath([REPO,'/code/model_construction/Dependences_stl/']);

% specify the trials and cams
% trial_i = 2;
% cam_i = 1;
for trial_i = 5%1:36
for cam_i = [1,3]%1:8
    disp('d')
    disp(trial_i)
    disp('c')
    disp(cam_i)
    
% settings
% origin_size = 30;
% arrow_size = 15;
% arrow_width = 6;
% arrow_length = 10;

% cam 4, 5
origin_size = 30;
arrow_size = 15;
arrow_width = 6;
arrow_length = 10;

animal_dia = DataBase.cockroach_model.dia(DataBase.Trial(trial_i).Info.AnimalNum);

head_x_bias = 5;
body_x_bias = 8;
abdomen_x_bias = -13;

% video folder
video_folder = [[REPO,'/output/Yaqing_sup_video/head_abdomen/trial_'],num2str(trial_i),'_cam_',num2str(cam_i),'\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file,'selected_36');
info_frame_num = info_num(:,4);
info_cal_series = info_txt(2:end,8);
infor_roll_dir = info_num(:,13);

% load calibration
cal_folder = [REPO,'/data/calibration/'];
cal_file = [cal_folder,'cal_',char(info_cal_series(trial_i)),'DLTcoefs.csv'];
CalFile = load(cal_file);
Cal = CalFile(:,cam_i);

% open video
input_video_folder = [REPO,'/raw_videos/f2_raw_videos_36/'];
InputObj = VideoReader([input_video_folder,'Trial_',num2str(trial_i),'_Cam_',num2str(cam_i),'.avi']);

% frames
frames = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame-1;

fig = figure(1);

XYZ_bias = info_num(trial_i,31:33);

% mirror back
if info_num(trial_i,13) == -1
    DataBase.Trial(trial_i).modified.Cockroach.Body.com(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Body.com(:,2);
    DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,1);
    DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3);
    DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,1);
    DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,3);
    DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,1);
    DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,3);
    
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,1);
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,3);
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,1);
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,3);
    
end

for frame_i = frames

    
    % calculate body 3d
    body_origin_3d = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_i,:)';
    body_origin_3d = body_origin_3d - [-[0,DataBase.Trial(trial_i).Info.Gap*20-20+5,0]-XYZ_bias]';
    body_eul = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_i,:);
    body_R = eul2rotm(body_eul);
    body_origin_3d_b = body_origin_3d + body_R(:,1)*body_x_bias; %
    body_xvect_3d = body_R(:,1)*arrow_length + body_origin_3d_b;
    body_yvect_3d = body_R(:,2)*arrow_length + body_origin_3d_b;
    body_zvect_3d = body_R(:,3)*arrow_length + body_origin_3d_b;
    
    % calculate head and abdomen 3d
    input = struct();
    input.body.com = body_origin_3d';
    input.body.eul = body_eul;
    input.head.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_i,:);
    input.abdomen.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_i,:);
    input = calculate_head_abdomen(animal_dia,input);
    
    head_origin_3d = input.head.com';
   	head_eul = DataBase.Trial(trial_i).modified.Cockroach.Head.eul(frame_i,:);
    head_R = eul2rotm(head_eul);
    head_origin_3d = head_origin_3d + head_R(:,1)*head_x_bias; %
    head_xvect_3d = head_R(:,1)*arrow_length + head_origin_3d;
    head_yvect_3d = head_R(:,2)*arrow_length + head_origin_3d;
    head_zvect_3d = head_R(:,3)*arrow_length + head_origin_3d;
    
    abdomen_origin_3d = input.abdomen.com';
   	abdomen_eul = DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(frame_i,:);
    abdomen_R = eul2rotm(abdomen_eul);
    abdomen_origin_3d = abdomen_origin_3d + abdomen_R(:,1)*abdomen_x_bias; %
    abdomen_xvect_3d = abdomen_R(:,1)*arrow_length + abdomen_origin_3d;
    abdomen_yvect_3d = abdomen_R(:,2)*arrow_length + abdomen_origin_3d;
    abdomen_zvect_3d = abdomen_R(:,3)*arrow_length + abdomen_origin_3d;
    
    % calculate 2d
    body_origin_2d = fDLT3D22D(Cal,body_origin_3d_b);
    body_xvect_2d = fDLT3D22D(Cal,body_xvect_3d);
    body_yvect_2d = fDLT3D22D(Cal,body_yvect_3d);
    body_zvect_2d = fDLT3D22D(Cal,body_zvect_3d);
%     body_xvect_2d = fDLT3D22D(Cal,body_xvect_3d)-body_origin_2d;
%     body_yvect_2d = fDLT3D22D(Cal,body_yvect_3d)-body_origin_2d;
%     body_zvect_2d = fDLT3D22D(Cal,body_zvect_3d)-body_origin_2d;
     
    
    head_origin_2d = fDLT3D22D(Cal,head_origin_3d);
    head_xvect_2d = fDLT3D22D(Cal,head_xvect_3d);
    head_yvect_2d = fDLT3D22D(Cal,head_yvect_3d);
    head_zvect_2d = fDLT3D22D(Cal,head_zvect_3d);
%     head_xvect_2d = fDLT3D22D(Cal,head_xvect_3d)-head_origin_2d;
%     head_yvect_2d = fDLT3D22D(Cal,head_yvect_3d)-head_origin_2d;
%     head_zvect_2d = fDLT3D22D(Cal,head_zvect_3d)-head_origin_2d;
    
    abdomen_origin_2d = fDLT3D22D(Cal,abdomen_origin_3d);
    abdomen_xvect_2d = fDLT3D22D(Cal,abdomen_xvect_3d);
    abdomen_yvect_2d = fDLT3D22D(Cal,abdomen_yvect_3d);
    abdomen_zvect_2d = fDLT3D22D(Cal,abdomen_zvect_3d);
%     abdomen_xvect_2d = fDLT3D22D(Cal,abdomen_xvect_3d)-abdomen_origin_2d;
%     abdomen_yvect_2d = fDLT3D22D(Cal,abdomen_yvect_3d)-abdomen_origin_2d;
%     abdomen_zvect_2d = fDLT3D22D(Cal,abdomen_zvect_3d)-abdomen_origin_2d;
    
    % prepare for the first frame
    im = read(InputObj, frame_i);
    fig;
    clf(fig);
    img = image();
    img.CData = im(end:-1:1,:,:);
    set(gcf,'position',[100,100, 2592/2,2048/2]);
    set(gcf,'PaperPosition',[0,0,2592,2048]/100)
    set(gca,'position',[0,0,1,1]);
    xlim([0 2592]);
    ylim([0 2048]);
    hold on;

    % arrows
    if ~isnan(body_origin_2d(1))
        
        b_x = arrow(body_origin_2d,body_xvect_2d,arrow_size,'BaseAngle',60,'Color',[1,0,0],'LineWidth',arrow_width);
        b_y = arrow(body_origin_2d,body_yvect_2d,arrow_size,'BaseAngle',60,'Color',[0,1,0],'LineWidth',arrow_width);
        b_z = arrow(body_origin_2d,body_zvect_2d,arrow_size,'BaseAngle',60,'Color',[0,0,1],'LineWidth',arrow_width);
        b_o = plot(body_origin_2d(1),body_origin_2d(2),'.','Color',[0,0,0],'MarkerSize',origin_size);
    end
    if ~isnan(head_origin_2d(1))
        
        h_x = arrow(head_origin_2d,head_xvect_2d,arrow_size,'BaseAngle',60,'Color',[1,0,0],'LineWidth',arrow_width);
        h_y = arrow(head_origin_2d,head_yvect_2d,arrow_size,'BaseAngle',60,'Color',[0,1,0],'LineWidth',arrow_width);
        h_z = arrow(head_origin_2d,head_zvect_2d,arrow_size,'BaseAngle',60,'Color',[0,0,1],'LineWidth',arrow_width);
        h_o = plot(head_origin_2d(1),head_origin_2d(2),'.','Color',[0,0,0],'MarkerSize',origin_size);
    end
    if ~isnan(abdomen_origin_2d(1))
        
        a_x = arrow(abdomen_origin_2d,abdomen_xvect_2d,arrow_size,'BaseAngle',60,'Color',[1,0,0],'LineWidth',arrow_width);
        a_y = arrow(abdomen_origin_2d,abdomen_yvect_2d,arrow_size,'BaseAngle',60,'Color',[0,1,0],'LineWidth',arrow_width);
        a_z = arrow(abdomen_origin_2d,abdomen_zvect_2d,arrow_size,'BaseAngle',60,'Color',[0,0,1],'LineWidth',arrow_width);
        a_o = plot(abdomen_origin_2d(1),abdomen_origin_2d(2),'.','Color',[0,0,0],'MarkerSize',origin_size);
    end
    % save figure
    drawnow;
    print([video_folder,'Frame_',num2str(frame_i,'%03.f'),'.jpg'],'-djpeg','-r100');

end


end
end




% check c6_create_labeled_video.m
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
addpath('Dependences\');
addpath([REPO,'/code/model_construction/Dependences_stl/']);

is_video = 1;

% specify the trials and cams
% trial_i = 2;
% cam_i = 1;
for trial_i = 5%1:36
for cam_i = [1]%1:8
    disp('d')
    disp(trial_i)
    disp('c')
    disp(cam_i)
    
% settings
origin_size = 30;
arrow_size = 30;
arrow_width = 10;
arrow_length = 10;
arrow_length_body = 5;
lin_width = 10;
lin_width2 = 5;
waist_y_length = 20;

x_rel_range = [-1,1]*650;
y_rel_range = x_rel_range/2592*2048;

% % cam 4, 5
% origin_size = 30/2;
% arrow_size = 15/2;
% arrow_width = 6/2;
% arrow_length = 10;
% lin_width = 5;

animal_dia = DataBase.cockroach_model.dia(DataBase.Trial(trial_i).Info.AnimalNum);

head_x_bias = 5;
body_x_bias = 8;
abdomen_x_bias = -13;

% video folder
video_folder = [[REPO,'/output/Yaqing_sup_video/leg_pronation/trial_'],num2str(trial_i),'_cam_',num2str(cam_i),'\'];
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
% frames = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame-1;
frames = [40,96,210,269] %38, 98, 213, 271
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
    
    temp = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b;
    DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b;
    DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b = temp;
    DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,2);
    DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,2);
end

for frame_i = frames

    
    % calculate body 3d
    body_origin_3d = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_i,:)';
    body_origin_3d = body_origin_3d - [-[0,DataBase.Trial(trial_i).Info.Gap*20-20+5,0]-XYZ_bias]';
    body_eul = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_i,:);
    body_R = eul2rotm(body_eul);
    body_origin_3d_b = body_origin_3d + body_R(:,1)*body_x_bias; %

    % calculate leg and leg_project
    left_leg = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:)';
    left_leg_proj = [left_leg(1:2,1);0];
    left_leg = body_R*left_leg + body_origin_3d;
    left_leg_proj = body_R*left_leg_proj + body_origin_3d;
    
    right_leg = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:)';
    right_leg_proj = [right_leg(1:2,1);0];
    right_leg = body_R*right_leg + body_origin_3d;
    right_leg_proj = body_R*right_leg_proj + body_origin_3d;
    
    % calculate 2d
    body_origin_2d = fDLT3D22D(Cal,body_origin_3d_b);  
    left_leg_2d = fDLT3D22D(Cal,left_leg);
    right_leg_2d = fDLT3D22D(Cal,right_leg);
    left_leg_proj_2d = fDLT3D22D(Cal,left_leg_proj);
    right_leg_proj_2d = fDLT3D22D(Cal,right_leg_proj);
    
    % prepare for the first frame
    im = read(InputObj, frame_i);
    fig;
    clf(fig);
    img = image();
    img.CData = im(end:-1:1,:,:);
    set(gcf,'position',[100,0, 2592/2,2048/2]);
    set(gcf,'PaperPosition',[0,0,2592,2048]/100)
    set(gca,'position',[0,0,1,1]);
    xlim(x_rel_range+body_origin_2d(1));
    ylim(y_rel_range+body_origin_2d(2));
    hold on;

    % arrows
    
    l_leg = plot([body_origin_2d(1),left_leg_2d(1)],[body_origin_2d(2),left_leg_2d(2)],'Color','r','LineWidth',lin_width);
    r_leg = plot([body_origin_2d(1),right_leg_2d(1)],[body_origin_2d(2),right_leg_2d(2)],'Color','b','LineWidth',lin_width);
    
    l_p_leg = plot([body_origin_2d(1),left_leg_proj_2d(1)],[body_origin_2d(2),left_leg_proj_2d(2)],'Color','r','LineWidth',lin_width2,'LineStyle','--');
    r_p_leg = plot([body_origin_2d(1),right_leg_proj_2d(1)],[body_origin_2d(2),right_leg_proj_2d(2)],'Color','b','LineWidth',lin_width2,'LineStyle','--');
    
    b_o = plot(body_origin_2d(1),body_origin_2d(2),'o','Color','k','MarkerSize',origin_size,'MarkerFaceColor','w','LineWidth',lin_width);
    l_o = plot(left_leg_2d(1),left_leg_2d(2),'o','Color','r','MarkerSize',origin_size,'MarkerFaceColor','w','LineWidth',lin_width);
    r_o = plot(right_leg_2d(1),right_leg_2d(2),'o','Color','b','MarkerSize',origin_size,'MarkerFaceColor','w','LineWidth',lin_width);
    l_p_o = plot(left_leg_proj_2d(1),left_leg_proj_2d(2),'o','Color','r','MarkerSize',origin_size,'MarkerFaceColor','w','LineWidth',lin_width2,'LineStyle','--');
    r_p_o = plot(right_leg_proj_2d(1),right_leg_proj_2d(2),'o','Color','b','MarkerSize',origin_size,'MarkerFaceColor','w','LineWidth',lin_width2,'LineStyle','--');
    


    % save figure
    drawnow;
    if is_video
        print([video_folder,'Frame_',num2str(frame_i,'%03.f'),'.jpg'],'-djpeg','-r100');
    else
        pause(0.2);
    end
end


end
end




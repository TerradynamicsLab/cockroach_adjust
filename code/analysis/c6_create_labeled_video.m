%% Yaqing created this function on 5/31/2020 to create labeled videos
clear all; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

load([REPO,'/data/kinematics/DataBase.mat']);

%% Basic Settings...
Trials = [];
Cams   = [];

for t = [2]
    for c = [1]
        Trials = [Trials,t];
        Cams = [Cams,c];
    end
end

video_num = length(Trials);

% Path of the Input .avi video
input_video_folder = [REPO,'/raw_videos/f1_raw_videos/'];
% Path of the Output .avi video
output_video_folder = [REPO,'/output/labeled_videos/'];
if ~exist(output_video_folder, 'dir')
    mkdir(output_video_folder)
end
% tag data
tag_folder = [REPO,'/data/reconstruction/f2_tags/'];

% point data
point_data = load([REPO,'/data/reconstruction/point_data.mat']);
% point_data = load('D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p3_recontruction\point_data_v2.mat');
% point_data = load('D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p3_recontruction\point_data_v3.mat');
% point_data = load('D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p3_recontruction\point_data_v4.mat');

point_data = point_data.PointData;

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file);
info_frame_num = info_num(:,4);
info_cal_series = info_txt(2:end,8);
infor_roll_dir = info_num(:,13);

%  calibration folder
cal_folder = [REPO,'/data/calibration/'];

%% Drawing Settings...
% Color map
ChosenColormap='jet';
Colormap = colormap(ChosenColormap);% DO NOT EDIT THIS LINE USUALLY.
% Width
WidthMode = 'Uniform';%'Uniform','Grade'
WidthLimit = 2;
% Radius
Radius = 10;
close all; 

%% Loop each video
for video_i = 1:video_num
    % basic info
    Trial = Trials(video_i);
    Cam = Cams(video_i);
    series = ['Trial_',num2str(Trial),'_Cam_',num2str(Cam)];
    frame_num = info_frame_num(Trial);
    disp(series);
    
    % load calibration
    cal_file = [cal_folder,'cal_',char(info_cal_series(Trial)),'DLTcoefs.csv'];
    CalFile = load(cal_file);
    Cal = CalFile(:,Cam);
    
    % load tag
    tag = load([tag_folder,'Trial_',num2str(Trial),'.mat']);
    tag = tag.tag;
    
    % load video reader and writter
    InputObj = VideoReader([input_video_folder,series,'.avi']);
    OutputObj = VideoWriter([output_video_folder,series,'_labeled.avi']);
    OutputObj.FrameRate = 100;
    open(OutputObj)
    
    % Loop frame and draw
    fig = figure(Cam);
    for frame_i = 1:frame_num
        disp(['Frame ',num2str(frame_i)]);
        
        % show original image
        im = read(InputObj, frame_i);
        imshow(im);
        set(fig,'position',[0 0 1280 1024]);
        set(gca, 'OuterPosition', [0,0,1,1])
        hold on;
        
        % Drawing points
        for p = [1,4:8]
            % calculate 2D
            XYZ = point_data(Trial, p).xyz(frame_i,:);
            UV = fDLT3D22D(Cal,XYZ);
            % transformation
            UV(2) = 2048 - UV(2);
            
            C = fcircle(UV(1),UV(2),Radius);
            C.LineWidth = WidthLimit;
%             C.LineWidth = PointData(Trial,p).rmse(frame_i);
            C.Color = Colormap(int16(256*p/8),:);
        end
        
        % Draw tags
        for tag_i = 1:length(tag)
            % find tag
            mxyz = tag(tag_i).xyz(frame_i,:);
            fxyz = tag(tag_i).fxyz(frame_i,:);
            c1xyz = tag(tag_i).c1xyz(frame_i,:);
            c2xyz = 2*(mxyz+c1xyz-fxyz)-c1xyz;
            c3xyz = 2*mxyz-c1xyz;
            c4xyz = 2*mxyz-c2xyz;
            % calculate 2D
            mUV = fDLT3D22D(Cal,mxyz);
            c1UV = fDLT3D22D(Cal,c1xyz);
            c2UV = fDLT3D22D(Cal,c2xyz);
            c3UV = fDLT3D22D(Cal,c3xyz);
            c4UV = fDLT3D22D(Cal,c4xyz);
            
            % transformation
            mUV(2) = 2048 - mUV(2);
            c1UV(2) = 2048 - c1UV(2);
            c2UV(2) = 2048 - c2UV(2);
            c3UV(2) = 2048 - c3UV(2);
            c4UV(2) = 2048 - c4UV(2);
            
            % draw
            plot([c1UV(1),c2UV(1),c3UV(1),c4UV(1),c1UV(1)],[c1UV(2),c2UV(2),c3UV(2),c4UV(2),c1UV(2)],'Color','g','LineWidth',1);
            C = fcircle(c1UV(1),c1UV(2),Radius);
            C.LineWidth = 1;
            C.Color = [1,0,0];
            C = fcircle(mUV(1),mUV(2),Radius);
            C.LineWidth = 1;
            C.Color = [0,1,0];
        end
        
        % save fig into video
        drawnow;
        CurrentFrame = getframe(fig);
        writeVideo(OutputObj, CurrentFrame);
        hold off;
    end
    
    % Close and exit
    close(OutputObj);
    fig.clo();

end

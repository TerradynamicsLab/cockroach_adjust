close all; clear; clc;
REPO = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); % repository root
% addpath(genpath('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\c1_maltab_code\BFS_dependences'));
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% video settings
is_video = 1;

% set project name and folder
project = struct();
project.name = 'movie_giraffe_2';

% folders
video_folder = [[REPO,'/output/'],project.name,'\video\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

% project.folder = ['D:\Dropbox\Cockroach Adjust\added_movie\',project.name,'\'];
project.folder = [[REPO,'/data/landscape_examples/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
addpath([REPO,'/code/model_construction/Dependences_stl']);
% load('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p4_kinematics_36\DataBase.mat');
% addpath('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p5_PEL_model\p1_cockroach_model\c1_matlabcode_local\Dependences_stl');

% loop trials
trial_i = 38;
body_X = -26:0.2:31.2;
increment = 0.01;
disp(['Trial: ',num2str(trial_i)]);

head_flexions = -25:5:65;
i_head = 9;
head_flexion = head_flexions(i_head);
disp(['head_flexion:',num2str(head_flexion)]);

% load
% load([project.folder,'compress_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat']);
load([project.folder,'basin_trial_',num2str(trial_i),'.mat']);
load([REPO,'/output/landscape/barrier_32/plot_data.mat'])
% load('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p5_PEL_model\f3_landscape\barrier_32\plot_data.mat')

% overwrite
% num = xlsread("D:\Dropbox\Cockroach Adjust\added_movie\movie_giraffe_2\manual.xlsx");
num = xlsread([REPO,'/data/landscape_examples/movie_giraffe_2/manual.xlsx']);
yaw_stay(i_head,:) = num(:,2)';
yaw_def_left(i_head,:) = num(:,3)';
yaw_def_right(i_head,:) = num(:,4)';
% holder
left_barrier = [];
right_barrier = [];

% choose the data you want...
frame_range = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LandFrame;
frame_num_selected = length(frame_range);

for frame_i = 1:length(body_X)%[1, 29, 65, 126]%
    X = Xs(:,:,frame_i);
    Y = Ys(:,:,frame_i);
    Z = Zs(:,:,frame_i);

    yaw_def_left_temp = yaw_def_left(i_head,frame_i);
    yaw_def_right_temp = yaw_def_right(i_head,frame_i);
    yaw_stay_temp = yaw_stay(i_head,frame_i);

    route_X = X(i_head,yaw_def_right_temp:yaw_def_left_temp);
    route_Z = Z(i_head,yaw_def_right_temp:yaw_def_left_temp);

    % recalculate saddle
    [~,i_saddle_right] = max(Z(i_head,yaw_def_right_temp:yaw_stay_temp));
    yaw_Saddle_right(i_head,frame_i) = i_saddle_right + yaw_def_right_temp-1;
    [~,i_saddle_left] = max(Z(i_head,yaw_stay_temp:yaw_def_left_temp));
    yaw_Saddle_left(i_head,frame_i) = i_saddle_left + yaw_stay_temp-1;

    if frame_i >60 && frame_i < 220 && frame_i~=150 && frame_i~=149
        [~,i_yaw_stay] = min(Z(i_head,yaw_Saddle_right(i_head,frame_i):yaw_Saddle_left(i_head,frame_i)));
        yaw_stay_temp = i_yaw_stay + yaw_Saddle_right(i_head,frame_i) -1;        
    end

    left_barrier = [left_barrier,Z(i_head,yaw_Saddle_left(i_head,frame_i))-Z(i_head,yaw_stay_temp)];
    right_barrier = [right_barrier,Z(i_head,yaw_Saddle_right(i_head,frame_i))-Z(i_head,yaw_stay_temp)];


    if frame_i == 1
        % plot
        fig1 = figure(1);
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

        l1 = plot3(route_X,route_Z*0+15,route_Z,'LineStyle','-','LineWidth',3,'Color','g');

        p11 = plot3(X(i_head,yaw_stay_temp),...r'
            Y(i_head,yaw_stay_temp),...
            Z(i_head,yaw_stay_temp)+increment,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p12 = plot3(X(i_head,yaw_def_left(i_head,frame_i)),...
            Y(i_head,yaw_def_left(i_head,frame_i)),...
            Z(i_head,yaw_def_left(i_head,frame_i))+increment,'o','MarkerFaceColor',[0.6,0,1],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p13 = plot3(X(i_head,yaw_Saddle_left(i_head,frame_i)),...
            Y(i_head,yaw_Saddle_left(i_head,frame_i)),...
            Z(i_head,yaw_Saddle_left(i_head,frame_i))+increment,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
        p14 = plot3(X(i_head,yaw_def_right(i_head,frame_i)),...
            Y(i_head,yaw_def_right(i_head,frame_i)),...
            Z(i_head,yaw_def_right(i_head,frame_i))+increment,'o','MarkerFaceColor',[0.6,0,1],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
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

        % green curve
        fig2 = figure(2);
        set(gcf, 'Position',[480 169 500 500]);
        clf;
        hold on;
        l_hori_1 = line([X(i_head,yaw_stay_temp),X(i_head,yaw_Saddle_left(i_head,frame_i))],[Z(i_head,yaw_stay_temp),Z(i_head,yaw_stay_temp)],'LineStyle',':','Color','k','LineWidth',2);
        l_vert_1 = line([X(i_head,yaw_Saddle_left(i_head,frame_i)),X(i_head,yaw_Saddle_left(i_head,frame_i))],[Z(i_head,yaw_stay_temp), Z(i_head,yaw_Saddle_left(i_head,frame_i))],'LineStyle','-','Color','r','LineWidth',3);
        l_hori_2 = line([X(i_head,yaw_stay_temp),X(i_head,yaw_Saddle_right(i_head,frame_i))],[Z(i_head,yaw_stay_temp),Z(i_head,yaw_stay_temp)],'LineStyle',':','Color','k','LineWidth',2);
        l_vert_2 = line([X(i_head,yaw_Saddle_right(i_head,frame_i)),X(i_head,yaw_Saddle_right(i_head,frame_i))],[Z(i_head,yaw_stay_temp), Z(i_head,yaw_Saddle_right(i_head,frame_i))],'LineStyle','-','Color',[0.6,0,1],'LineWidth',3);

        l2 = plot(route_X,route_Z,'LineStyle','-','LineWidth',3,'Color',[0.1,0.7,0.1]);
        p21 = plot(X(i_head,yaw_stay_temp),...
            Z(i_head,yaw_stay_temp),'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);
        p22 = plot(X(i_head,yaw_def_left(i_head,frame_i)),...
            Z(i_head,yaw_def_left(i_head,frame_i)),'o','MarkerFaceColor',[0.6,0,1],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);
        p23 = plot(X(i_head,yaw_Saddle_left(i_head,frame_i)),...
            Z(i_head,yaw_Saddle_left(i_head,frame_i)),'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);
        p24 = plot(X(i_head,yaw_def_right(i_head,frame_i)),...
            Z(i_head,yaw_def_right(i_head,frame_i)),'o','MarkerFaceColor',[0.6,0,1],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);
        p25 = plot(X(i_head,yaw_Saddle_right(i_head,frame_i)),...
            Z(i_head,yaw_Saddle_right(i_head,frame_i)),'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);

        xlim([-90,90]);
        set(gca, 'XDir','reverse')
        ylim([0,2.2]);
        box on;
        set(gca,'FontSize', 20);

    else
        l1.XData = route_X;
        l1.YData = route_X*0+15;
        l1.ZData = route_Z;

        ti.String = ['Body X: ',num2str(body_X(frame_i),'%.1f'),' mm'];
        s1.ZData = Z;
        p11.XData = X(i_head,yaw_stay_temp);
        p11.ZData = Z(i_head,yaw_stay_temp)+increment;
        p12.XData = X(i_head,yaw_def_left(i_head,frame_i));
        p12.ZData = Z(i_head,yaw_def_left(i_head,frame_i))+increment;
        p13.XData = X(i_head,yaw_Saddle_left(i_head,frame_i));
        p13.ZData = Z(i_head,yaw_Saddle_left(i_head,frame_i))+increment;
        p14.XData = X(i_head,yaw_def_right(i_head,frame_i));
        p14.ZData = Z(i_head,yaw_def_right(i_head,frame_i))+increment;
        p15.XData = X(i_head,yaw_Saddle_right(i_head,frame_i));
        p15.ZData = Z(i_head,yaw_Saddle_right(i_head,frame_i))+increment;

        l2.XData = route_X;
        l2.YData = route_Z;

        p21.XData = X(i_head,yaw_stay_temp);
        p21.YData = Z(i_head,yaw_stay_temp);
        p22.XData = X(i_head,yaw_def_left(i_head,frame_i));
        p22.YData = Z(i_head,yaw_def_left(i_head,frame_i));
        p23.XData = X(i_head,yaw_Saddle_left(i_head,frame_i));
        p23.YData = Z(i_head,yaw_Saddle_left(i_head,frame_i));
        p24.XData = X(i_head,yaw_def_right(i_head,frame_i));
        p24.YData = Z(i_head,yaw_def_right(i_head,frame_i));
        p25.XData = X(i_head,yaw_Saddle_right(i_head,frame_i));
        p25.YData = Z(i_head,yaw_Saddle_right(i_head,frame_i));

        l_hori_1.XData = [X(i_head,yaw_stay_temp),X(i_head,yaw_Saddle_left(i_head,frame_i))];
        l_hori_1.YData = [Z(i_head,yaw_stay_temp),Z(i_head,yaw_stay_temp)];
        l_vert_1.XData = [X(i_head,yaw_Saddle_left(i_head,frame_i)),X(i_head,yaw_Saddle_left(i_head,frame_i))];
        l_vert_1.YData = [Z(i_head,yaw_stay_temp), Z(i_head,yaw_Saddle_left(i_head,frame_i))];
        l_hori_2.XData = [X(i_head,yaw_stay_temp),X(i_head,yaw_Saddle_right(i_head,frame_i))];
        l_hori_2.YData = [Z(i_head,yaw_stay_temp),Z(i_head,yaw_stay_temp)];
        l_vert_2.XData = [X(i_head,yaw_Saddle_right(i_head,frame_i)),X(i_head,yaw_Saddle_right(i_head,frame_i))];
        l_vert_2.YData = [Z(i_head,yaw_stay_temp), Z(i_head,yaw_Saddle_right(i_head,frame_i))];


    end

    if is_video
        % get frame and write in video
        saveas(fig1, [video_folder,'landscape_',num2str(frame_i, '%03d'),'.jpg'])
        saveas(fig2, [video_folder,'profile_',num2str(frame_i, '%03d'),'.jpg'])
    else
        pause(0.2);
    end
end

for frame_i = length(body_X)+1:296
    left_barrier = [left_barrier,left_barrier(end)];
    right_barrier = [right_barrier,right_barrier(end)];

    if is_video
        % get frame and write in video
        saveas(fig1, [video_folder,'landscape_',num2str(frame_i, '%03d'),'.jpg'])
        saveas(fig2, [video_folder,'profile_',num2str(frame_i, '%03d'),'.jpg'])
    else
        pause(0.2);
    end
end

save([project.folder,'barrier_trial_',num2str(trial_i),'.mat'], 'left_barrier', 'right_barrier');
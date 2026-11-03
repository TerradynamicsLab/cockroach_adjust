close all; clear; clc;
REPO = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); % repository root
% addpath(genpath('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\c1_maltab_code\BFS_dependences'));
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

% video settings
is_video = 1;

% set project name and folder
project = struct();
project.name = 'movie_fish';

% folders
video_folder = [[REPO,'/output/'],project.name,'\video\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

% project.folder = ['D:\Dropbox\Cockroach Adjust\added_movie\',project.name,'\'];
project.folder = [[REPO,'/data/landscape_examples/'],project.name,'\'];
shared_folder = [REPO,'/data/landscape_examples/shared_HD15/'];
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
disp(['Trial: ',num2str(trial_i)]);

head_flexions = -25:5:65;
i_head_flexion = 9;
head_flexion = head_flexions(i_head_flexion);
disp(['head_flexion:',num2str(head_flexion)]);

BFS_result.roll_PM = [];
BFS_result.pitch_PM = [];
BFS_result.energy_PM = [];
BFS_result.roll_RM = [];
BFS_result.pitch_RM = [];
BFS_result.energy_RM = [];
BFS_result.roll_S = [];
BFS_result.pitch_S = [];
BFS_result.energy_S = [];
BFS_result.energy_barrier = [];

% load
load([shared_folder,'compress_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat']);
p_r_mini = csvread([shared_folder,'basin_select_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.csv']);

% choose the data you want...
frame_range = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LandFrame;
frame_num_selected = length(frame_range);

% animal information
animal_NO = DataBase.Trial(trial_i).Info.AnimalNum;
animal_dia = DataBase.cockroach_model.dia(animal_NO);
input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass * 1e-3;
input.body.mass = input.total.mass;
input.mass_bias_b = [DataBase.cockroach_model.dia(animal_NO).total.mass_bias_b;0;0];
%%% model mat
head_mat_origin = DataBase.cockroach_model.head(animal_NO);
body_mat_origin = DataBase.cockroach_model.body(animal_NO);
abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);
%%% scalers
scaler0 = [0.7,0.9,0.9,  1,1,0.9,  1,1,0.9];
shift0 = [0,-1,-1]; % head, body, abdomen
is_axis_shift = 1;
is_ab_trans = 0;
%%% changing in the model
ratio = struct();
ratio.head.length = scaler0(1);
ratio.head.width = scaler0(2);
ratio.head.thickness = scaler0(3);
ratio.body.length = scaler0(4);
ratio.body.width = scaler0(5);
ratio.body.thickness = scaler0(6);
ratio.abdomen.length = scaler0(7);
ratio.abdomen.width = scaler0(8);
ratio.abdomen.thickness = scaler0(9);
%%%%%%%%%%% model modification %%%%%%%%%%%%%%%%%%
head_mat= head_mat_origin;
head_mat.vertice_position(:,1) = head_mat.vertice_position(:,1) * ratio.head.length;
head_mat.vertice_position(:,2) = head_mat.vertice_position(:,2) * ratio.head.width;
head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3) * ratio.head.thickness + shift0(1);
body_mat= body_mat_origin;
body_mat.vertice_position(:,1) = body_mat.vertice_position(:,1) * ratio.body.length;
body_mat.vertice_position(:,2) = body_mat.vertice_position(:,2) * ratio.body.width;
body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3) * ratio.body.thickness + shift0(2);
abdomen_mat= abdomen_mat_origin;
abdomen_mat.vertice_position(:,1) = abdomen_mat.vertice_position(:,1) * ratio.abdomen.length;
abdomen_mat.vertice_position(:,2) = abdomen_mat.vertice_position(:,2) * ratio.abdomen.width;
abdomen_mat.vertice_position(:,3) = abdomen_mat.vertice_position(:,3) * ratio.abdomen.thickness + shift0(3);
if is_axis_shift
    animal_dia.total.neck_point = animal_dia.total.neck_point * ratio.body.length + [0,0,shift0(2)]';
    animal_dia.total.waist_point = animal_dia.total.waist_point * ratio.body.length + [0,0,shift0(2)]';
else
    animal_dia.total.neck_point = animal_dia.total.neck_point;
    animal_dia.total.waist_point = animal_dia.total.waist_point;
end

% landscape
sizes = [size(data.body_roll,2),size(data.body_roll,3)];
X = reshape(data.body_roll(1,:,:),sizes)*180/pi;
Y = reshape(data.body_pitch(1,:,:),sizes)*180/pi;
X = X';
Y = Y';


for frame_i = 1:frame_num_selected
    disp(frame_i);

    % load landscape
    landscape = data.landscape_value(frame_i,:,:);
    landscape = reshape(landscape,[size(landscape,2),size(landscape,3)]);
    Z = landscape';

    % load configuration
    xPitch =  p_r_mini(1,frame_i);
    yPitch =  p_r_mini(2,frame_i);
    xRoll =  p_r_mini(3,frame_i);
    yRoll =  p_r_mini(4,frame_i);

    %%% set barrier to not go left
    BFS_landscape_noLeft = Z;
    BFS_landscape_noLeft(:,xPitch-1) = BFS_landscape_noLeft(:,xPitch-1)*0+1000;

    % BFS
    [saddleXYZ,routeXYZ,basin_landscape] = mini2mini(BFS_landscape_noLeft,xPitch,yPitch,xRoll,yRoll,0,0);
    [xPitch,yPitch,xRoll,yRoll,routeXYZ] = route2P_R_S(routeXYZ);
    for i = 1:size(basin_landscape,2)
        for j = 1:size(basin_landscape,1)
            if basin_landscape(j,i) == 1
                c(j,i,1:3) = [0.5,0.5,1];
            elseif basin_landscape(j,i) == 2
                c(j,i,1:3) = [1,0.5,0.5];
            else
                c(j,i,1:3) = [0,0,0];
            end
        end
    end

    roll_PM = X(yPitch,xPitch);
    pitch_PM = Y(yPitch,xPitch);
    energy_PM = Z(yPitch,xPitch);
    roll_RM = X(yRoll,xRoll);
    pitch_RM = Y(yRoll,xRoll);
    energy_RM = Z(yRoll,xRoll);
    roll_S = X(saddleXYZ(2),saddleXYZ(1));
    pitch_S = Y(saddleXYZ(2),saddleXYZ(1));
    energy_S = saddleXYZ(3);
    energy_barrier = energy_S-energy_PM;
    route_length = length(routeXYZ);
    roll_route = [];
    pitch_route = [];
    energy_route = [];
    for route_i = 1:route_length
        roll_route(route_i) = X(routeXYZ(2,route_i),routeXYZ(1,route_i));
        pitch_route(route_i) = Y(routeXYZ(2,route_i),routeXYZ(1,route_i));
        energy_route(route_i) = Z(routeXYZ(2,route_i),routeXYZ(1,route_i));
    end

    %%%%%%%% maybe record %%%%%%%%%
    BFS_result.roll_PM = [BFS_result.roll_PM, roll_PM];
    BFS_result.pitch_PM = [BFS_result.pitch_PM, pitch_PM];
    BFS_result.energy_PM = [BFS_result.energy_PM, energy_PM];
    BFS_result.roll_RM = [BFS_result.roll_RM, roll_RM];
    BFS_result.pitch_RM = [BFS_result.pitch_RM, pitch_RM];
    BFS_result.energy_RM = [BFS_result.energy_RM, energy_RM];
    BFS_result.roll_S = [BFS_result.roll_S, roll_S];
    BFS_result.pitch_S = [BFS_result.pitch_S, pitch_S];
    BFS_result.energy_S = [BFS_result.energy_S, energy_S];
    BFS_result.energy_barrier = [BFS_result.energy_barrier, energy_barrier];

    input.body.com = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_i,:);
    input.head.eul_b = [0,15,0] *pi/180;

    input.abdomen.eul_b = [0,-7,0] *pi/180;
    input.beam_cal_re = 0;
    input.beam.ref_left_pitch = 0;
    input.beam.ref_right_pitch = 0;

    [~,saddle_id] = max(energy_route);
    if frame_i == 1
        % plot
        fig1 = figure(1);
        set(gcf, 'Position',[480 169 500 500]);
        clf;
        hold on;
        l_hori = line([1,saddle_id],[energy_PM,energy_PM],'LineStyle',':','Color','k','LineWidth',2);
        l_vert = line([saddle_id,saddle_id],[energy_PM,energy_S],'LineStyle','-','Color','k','LineWidth',3);

        l3 = plot(1:route_length,energy_route,'LineStyle','-','LineWidth',3,'Color',[0.1,0.7,0.1]);
        p31 = plot(1,energy_PM,'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);
        p32 = plot(route_length,energy_RM,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);
        p33 = plot(saddle_id,energy_S,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',[0.1,0.7,0.1]);

        
        xlim([0,route_length+1])
        ylim([min(energy_route)-max(energy_route)*0.1,max(energy_route)*1.1]);
        box on;
        set(gca,'FontSize', 20);

    else
        l3.XData = 1:route_length;
        l3.YData = energy_route;
        p31.XData = 1;
        p31.YData = energy_PM;
        p32.XData = route_length;
        p32.YData = energy_RM;
        p33.XData = saddle_id;
        p33.YData = energy_S;
        l_hori.XData = [1,saddle_id];
        l_hori.YData = [energy_PM,energy_PM];
        l_vert.XData = [saddle_id,saddle_id];
        l_vert.YData = [energy_PM,energy_S];
        xlim([0,route_length+1])
        ylim([min(energy_route)-max(energy_route)*0.1,max(energy_route)*1.1]);
    end
    if is_video
        % get frame and write in video
        saveas(fig1, [video_folder,'profile_',num2str(frame_i, '%03d'),'.jpg'])
    else
        pause(0.2);
    end
end

%
% save([project.folder,'basin_trial_',num2str(trial_i),'_HD_',num2str(head_flexion),'.mat'],'BFS_result')
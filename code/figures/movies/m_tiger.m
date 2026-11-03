close all; clear; clc;
REPO = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); % repository root
% addpath(genpath('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\c1_maltab_code\Dependences'));
addpath(genpath([REPO,'/code/analysis/Dependences']));

project = struct();
project.name = 'movie_tiger';

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);
load([REPO,'/data/kinematics/DataBase.mat']);
% addpath('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p5_PEL_model\p1_cockroach_model\c1_matlabcode_local\Dependences_stl');
% load('D:\Dropbox\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p4_kinematics_36\DataBase.mat');

is_video = 1;

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

% ideal trial only
trial_i = 37;

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

input.is_ab_trans = is_ab_trans;
input.beam_cal_re = 0;

%%%
% frame_i = 63; %transition


for frame_i = 1:DataBase.Trial(trial_i).Info.LeaveFrame
    % for leg sprawl
    figure(1)
    clf;

    input.body.com = DataBase.Trial(37).modified.Cockroach.Body.com(frame_i,:);
    input.body.com(3) = 10; 
    input.body.eul = DataBase.Trial(37).modified.Cockroach.Body.eul(frame_i,:);
    input.head.eul_b = DataBase.Trial(37).modified.Cockroach.Head.eul_b(frame_i,:);
    input.abdomen.eul_b = DataBase.Trial(37).modified.Cockroach.Abdomen_Up.eul_b(frame_i,:);
    input.beam.ref_left_pitch = 0;
    input.beam.ref_right_pitch = 0;

    input = calculate_head_abdomen(animal_dia,input);
    [input,body_mat_after,head_mat_after,abdomen_mat_after] = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
    % reconstruction_visualization_nogroundbeam(input,body_mat,head_mat,abdomen_mat);
    reconstruction_visualization_stl_tribody(input,body_mat_after,head_mat_after,abdomen_mat_after);
    set(gcf,'Position',[30,30,1200,1000])
    % view(-40, 30)
    % view(-90, 90)
    % view(90, 0)

    if is_video
        % get frame and write in video
        saveas(gcf, [video_folder,'animalAnime_',num2str(frame_i, '%03d'),'.jpg'])
    else
        pause(0.2);
    end

end





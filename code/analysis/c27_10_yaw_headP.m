% Yaqing adopted this from c24_1_Pandora_generator.m

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
% maxNumCompThreads(1); %% only one thread
addpath(genpath([REPO,'/code/analysis/Dependences']));

sweep_unit = 5; %°

project = struct();
project.name = 'barrier_5';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
savefolder = [REPO,'/output/Yaqing_landscape/'];

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);
load([REPO,'/data/kinematics/DataBase.mat']);

% range
head_angle_range = -25:5:65;
yaw_range = -90:5:90;
X_range = -24.2:0.2:33;

potential_energy = nan(length(head_angle_range),length(yaw_range),length(X_range));

% ideal trial only
trial_i = 37;

% choose the data you want...
frame_range = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.LandFrame;
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
input.is_axis_shift = 1;
is_ab_trans = 0;
input.is_ab_trans = 0;
input.beam_cal_re = 0;
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

input.body.com(1) = 0;
input.body.com(2) = 0;
input.body.com(3) = 0;
input.body.eul(1) = 0;
input.body.eul(2) = 0;
input.body.eul(3) = pi/2;
input.head.eul_b(1) = 0;
input.head.eul_b(2) = 0;
input.head.eul_b(3) = 0;
input.abdomen.eul_b(1) = 0;
input.abdomen.eul_b(2) = -6/180*pi;
input.abdomen.eul_b(3) = 0;
input.beam.ref_left_pitch = 0;
input.beam.ref_right_pitch = 0;

% loop 
for i_HA = 1:length(head_angle_range)
    disp(i_HA);
    head_angle = head_angle_range(i_HA);
    input.head.eul_b(2) = head_angle/180*pi;
    for i_yaw = 1:length(yaw_range)
    yaw = yaw_range(i_yaw);
    input.body.eul(1) = yaw/180*pi;
        for i_X = 1:length(X_range)
            X = X_range(i_X);
            input.body.com(1) = X;
            
            % calculate head and abdomen com and eul
            input = calculate_head_abdomen(animal_dia,input);
            % calculate beam angle
            input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
            % record
            potential_energy(i_HA,i_yaw,i_X) = calculate_state_potential_energy(input);
        end
    end
end
save([project.folder,'PE_c27_10.mat'],'potential_energy');



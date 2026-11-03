% compare the real measured beam data with calculation result using the old
% method: ground contact constraint, only bend forward. For the paper!

% Yaqing 7/6/2021

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

% set project name and folder
project = struct();
project.name = 'barrier_5';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);
load([REPO,'/data/kinematics/DataBase.mat']);


% holders
left_angle_calculate = [];
right_angle_calculate = [];
left_angle_measure = [];
right_angle_measure  = [];

% for every trial
for i_trial = 1:36
    
    % animal information
    animal_NO = DataBase.Trial(i_trial).Info.AnimalNum;
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
    
    % select all the frames
    frames = DataBase.Trial(i_trial).Info.EnterFrame:DataBase.Trial(i_trial).Info.LeaveFrame;
    
    % for each frame
    for i_frame = frames
        
        % prepare input
        input.body.com = DataBase.Trial(i_trial).modified.Cockroach.Body.com(i_frame,:);
        input.body.eul = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(i_frame,:);
        input.head.eul_b = DataBase.Trial(i_trial).modified.Cockroach.Head.eul_b(i_frame,:);
        input.abdomen.eul_b = DataBase.Trial(i_trial).modified.Cockroach.Abdomen_Up.eul_b(i_frame,:);
        input.body.com(3) = 0;
        
        % calculate head and abdomen com and eul
        input = calculate_head_abdomen(animal_dia,input);
        
        % calculate beam angles using old method
        input.beam_cal_re = 0;
        input.beam.ref_left_pitch = 0;
        input.beam.ref_right_pitch = 0;
        input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
        
        % record
        left_angle_calculate = [left_angle_calculate,input.beam.angle_left];
        right_angle_calculate = [right_angle_calculate,input.beam.angle_right];
    end
    
    % record measured data
    left_angle_measure = [left_angle_measure,DataBase.Trial(i_trial).modified.Cockroach.Beam.left_pitch(frames)];
    right_angle_measure  = [right_angle_measure,DataBase.Trial(i_trial).modified.Cockroach.Beam.right_pitch(frames)];
    
end

% compare
error = [left_angle_calculate-left_angle_measure,right_angle_calculate-right_angle_measure];
mean(error)*180/pi
std(error)*180/pi







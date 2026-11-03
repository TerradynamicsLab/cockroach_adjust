% Yaqing adopted this from c28_1_Pandora_generator_legs.m

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
maxNumCompThreads(1); %% only one thread
addpath(genpath([REPO,'/code/analysis/Dependences']));

%%%%%%%%%%%%%%% hyper settings %%%%%%%%%%%%%%%%%
sweep_unit = 2; %°
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set project name and folder
project = struct();
project.name = 'barrier_leg_32';

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);
load([REPO,'/data/kinematics/DataBase.mat']);

% ideal trial only
trial_i = 38;
head_flexions = -25:5:65;

for head_flexion = head_flexions

    
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
    head_mat = head_mat_origin;
    head_mat.vertice_position(:,1) = head_mat.vertice_position(:,1) * ratio.head.length;
    head_mat.vertice_position(:,2) = head_mat.vertice_position(:,2) * ratio.head.width;
    head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3) * ratio.head.thickness + shift0(1);
    body_mat = body_mat_origin;
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
    
    % kinematics
    selected_data = struct();
    selected_data.body.com = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_range,:);
    selected_data.body.eul = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_range,:);
    selected_data.head.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_range,:).*[0,1,0];
    selected_data.abdomen.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_range,:).*[0,1,0];
    ground_truth_beam_pitch_left = DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch(frame_range)';
    ground_truth_beam_pitch_right = DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch(frame_range)';
    %%% zero beam
    ground_truth_beam_pitch_left = ground_truth_beam_pitch_left-nanmean(ground_truth_beam_pitch_left(1:10));
    ground_truth_beam_pitch_right = ground_truth_beam_pitch_right-nanmean(ground_truth_beam_pitch_right(1:10));
    
    
    % form grid
    grid = struct();
    %%%% grid.mode: 0:compress this dimension, ignore other params; 1:limit
    %%%% relevant to 0; 2: limit relevant to true value.
    % settings
    %%% body_x
    grid.var(1).mode = 0;
    grid.var(1).unit = 2;
    grid.var(1).limit = [-10,10];
    %%% body_y
    grid.var(2).mode = 0;
    grid.var(2).unit = 1;
    grid.var(2).limit = [-3,3];
    %%% body_z
    grid.var(3).mode = 1;
    grid.var(3).unit = 1;
    grid.var(3).limit = [0,15];
    %%% body_yaw
    grid.var(4).mode = 1;
    grid.var(4).unit = sweep_unit *pi/180;
    grid.var(4).limit = [-90,90] *pi/180;
    %%% body_pitch
    grid.var(5).mode = 0;
    grid.var(5).unit = sweep_unit *pi/180;
    grid.var(5).limit = [-90,90] *pi/180;
    %%% body_roll
    grid.var(6).mode = 0;
    grid.var(6).unit = sweep_unit *pi/180;
    grid.var(6).limit = [-180,180] *pi/180;
    %%% head_yaw_b
    grid.var(7).mode = 0;
    grid.var(7).unit = 2 *pi/180;
    grid.var(7).limit = [-90,90] *pi/180;
    %%% head_pitch_b
    grid.var(8).mode = 0;
    grid.var(8).unit = 5 *pi/180;
    grid.var(8).limit = [-25,65] *pi/180;
    %%% head_row_b
    grid.var(9).mode = 0;
    grid.var(9).unit = 2 *pi/180;
    grid.var(9).limit = [-90,90] *pi/180;
    %%% abdomen_yaw_b
    grid.var(10).mode = 0;
    grid.var(10).unit = 2 *pi/180;
    grid.var(10).limit = [-90,90] *pi/180;
    %%% abdomen_pitch_b
    grid.var(11).mode = 0;
    grid.var(11).unit = 6 *pi/180;
    grid.var(11).limit = [-20,90] *pi/180;
    %%% abdomen_row_b
    grid.var(12).mode = 0;
    grid.var(12).unit = 2 *pi/180;
    grid.var(12).limit = [-90,90] *pi/180;
    
    % calculate grid length, coordinate
    for v = 1:12
        if grid.var(v).mode == 0
            grid.var(v).length = 1;
        else
            grid.var(v).length = floor((grid.var(v).limit(2)-grid.var(v).limit(1))/grid.var(v).unit)+1;
        end
    end
    
    % form the result holder, 12-D.
    landscape = struct();
    landscape.potential_energy = nan(frame_num_selected,grid.var(3).length,grid.var(4).length);
    landscape.left_beam_angle = nan(frame_num_selected,grid.var(3).length,grid.var(4).length);
    landscape.right_beam_angle = nan(frame_num_selected,grid.var(3).length,grid.var(4).length);
    
    % loop
    %%% frame number
    for frame_i = 1:frame_num_selected
        disp(['Frame: ',num2str(frame_i)])
        
        % set input structure
        input.is_ab_trans = is_ab_trans;
        input.beam_cal_re = 0; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % get cockroach status at this time...
        input.body.com = selected_data.body.com(frame_i,:);
        input.body.eul = selected_data.body.eul(frame_i,:);
        input.head.eul_b = selected_data.head.eul_b(frame_i,:);
        input.abdomen.eul_b = selected_data.abdomen.eul_b(frame_i,:);
        input.beam.ref_left_pitch = ground_truth_beam_pitch_left(frame_i);
        input.beam.ref_right_pitch = ground_truth_beam_pitch_right(frame_i);
        
        v_init = zeros(1,9);
        v_init(1) = input.body.com(1);
        v_init(2) = input.body.com(2);
        v_init(3) = input.body.com(3);
        v_init(4) = input.body.eul(1);
        v_init(5) = input.body.eul(2);
        v_init(6) = input.body.eul(3);
        v_init(7) = input.head.eul_b(1);
        v_init(8) = input.head.eul_b(2);
        v_init(9) = input.head.eul_b(3);
        v_init(10) = input.abdomen.eul_b(1);
        v_init(11) = input.abdomen.eul_b(2);
        v_init(12) = input.abdomen.eul_b(3);
        
        % caluclate range of each var
        for v = 1:12
            if grid.var(v).mode == 0
                grid.var(v).range = [v_init(v)];
            elseif grid.var(v).mode == 1
                grid.var(v).range = grid.var(v).limit(1):grid.var(v).unit:grid.var(v).limit(2);
            else
                grid.var(v).range = grid.var(v).limit(1):grid.var(v).unit:grid.var(v).limit(2)+v_init(v);
            end
            landscape.var(frame_i,v).coordinate = grid.var(v).range;
            landscape.var(frame_i,v).data = v_init(v);
        end
        
        index = zeros(1,12);
        for v3 = grid.var(3).range
            index(3) = index(3)+1;
            index(4) = 0;
            %%% body_pitch
            for v4 = grid.var(4).range
                index(4) = index(4)+1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % input
                input.body.com(1) = grid.var(1).range;
                input.body.com(2) = grid.var(2).range;
                input.body.com(3) = v3;
                input.body.eul(1) = v4;
                input.body.eul(2) = grid.var(5).range;
                input.body.eul(3) = grid.var(6).range;
                input.head.eul_b(1) = grid.var(7).range;
                input.head.eul_b(2) = head_flexion*pi/180; %v8;
                input.head.eul_b(3) = grid.var(9).range;
                input.abdomen.eul_b(1) = grid.var(10).range;
                input.abdomen.eul_b(2) = grid.var(11).range;
                input.abdomen.eul_b(3) = grid.var(12).range;
                
                % calculate head and
                % abdomen com and eul
                input = calculate_head_abdomen(animal_dia,input);
                % calculate beam angle
                input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
                
                % calculate landscape
                landscape.left_beam_angle(frame_i,index(3),index(4)) = input.beam.angle_left;
                landscape.right_beam_angle(frame_i,index(3),index(4)) = input.beam.angle_right;
                landscape.potential_energy(frame_i,index(3),index(4)) = calculate_state_potential_energy(input);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            
        end
    end
    
    
    % record other stuff
    landscape.frame_num = frame_num_selected;
    % save
    save([project.folder,'landscape_trial_',num2str(trial_i),...
        '_HD_',num2str(head_flexion),'.mat'],'landscape');
    
end
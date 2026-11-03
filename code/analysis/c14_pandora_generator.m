% Yaqing adopted this from D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroa
% ch_adjust_experiment\p2_64_selected\p3_head_analysis_barrier\barrier_stl
% _animal_data_1\pandora_space_generator_stl_animal_data.m

% add abdomen, though not useful now

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

%%%%%%%%%%%%%%% hyper settings %%%%%%%%%%%%%%%%%
sweep_unit = 2; %°
is_re = 0;
beam_cal_re = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

project = struct();

if is_re == 1
    % set project name and folder
    project.name = 'barrier_1_re';
    % load database and code
    load([REPO,'/data/kinematics/DataBase_re.mat']);
else
    % set project name and folder
    project.name = 'barrier_1';
    % load database and code
    load([REPO,'/data/kinematics/DataBase.mat']);
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end
addpath([REPO,'/code/model_construction/Dependences_stl']);

% loop trials
for trial_i = 37
    disp(['Trial: ',num2str(trial_i)]);

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
        animal_dia_.total.neck_point = animal_dia.total.neck_point * ratio.body.length + [0,0,shift0(2)]';
        animal_dia_.total.waist_point = animal_dia.total.waist_point * ratio.body.length + [0,0,shift0(2)]';
    else
        animal_dia_.total.neck_point = animal_dia.total.neck_point;
        animal_dia_.total.waist_point = animal_dia.total.waist_point;
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
    grid.var(2).unit = 2;
    grid.var(2).limit = [-10,10];
    %%% body_z
    grid.var(3).mode = 0;
    grid.var(3).unit = 2;
    grid.var(3).limit = [-10,10];
    %%% body_yaw
    grid.var(4).mode = 0;
    grid.var(4).unit = 2 *pi/180;
    grid.var(4).limit = [-90,90] *pi/180;
    %%% body_pitch
    grid.var(5).mode = 1;
    grid.var(5).unit = sweep_unit *pi/180;
    grid.var(5).limit = [-90,90] *pi/180;
    %%% body_row
    grid.var(6).mode = 1;
    grid.var(6).unit = sweep_unit *pi/180;
    grid.var(6).limit = [-90,90] *pi/180;
    %%% head_yaw_b
    grid.var(7).mode = 0;
    grid.var(7).unit = 2 *pi/180;
    grid.var(7).limit = [-90,90] *pi/180;
    %%% head_pitch_b
    grid.var(8).mode = 0;
    grid.var(8).unit = sweep_unit *pi/180;
    grid.var(8).limit = [-20,90] *pi/180;
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
    landscape.potential_energy = nan(frame_num_selected, ...
        grid.var(1).length,grid.var(2).length,grid.var(3).length,...
        grid.var(4).length,grid.var(5).length,grid.var(6).length,...
        grid.var(7).length,grid.var(8).length,grid.var(9).length,...
        grid.var(10).length,grid.var(11).length,grid.var(12).length);
    landscape.left_beam_angle = nan(frame_num_selected, ...
        grid.var(1).length,grid.var(2).length,grid.var(3).length,...
        grid.var(4).length,grid.var(5).length,grid.var(6).length,...
        grid.var(7).length,grid.var(8).length,grid.var(9).length,...
        grid.var(10).length,grid.var(11).length,grid.var(12).length);
    landscape.right_beam_angle = nan(frame_num_selected, ...
        grid.var(1).length,grid.var(2).length,grid.var(3).length,...
        grid.var(4).length,grid.var(5).length,grid.var(6).length,...
        grid.var(7).length,grid.var(8).length,grid.var(9).length,...
        grid.var(10).length,grid.var(11).length,grid.var(12).length);
    
    

    
    % loop
    %%% frame number
    for frame_i = 1:frame_num_selected
        disp(['Frame: ',num2str(frame_i)])
        
        % set input structure
        input.is_ab_trans = is_ab_trans;
        input.beam_cal_re = beam_cal_re;
        
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
        %%% body_x
        for v1 = grid.var(1).range
            index(1) = index(1)+1;
            input.body.com(1) = v1;
            index(2) = 0;
            %%% body_y
            for v2 = grid.var(2).range
                index(2) = index(2)+1;
                input.body.com(2) = v2;
                index(3) = 0;
                %%% body_z
                for v3 = grid.var(3).range
                    index(3) = index(3)+1;
                    input.body.com(3) = v3;
                    index(4) = 0;
                    %%% body_yaw
                    for v4 = grid.var(4).range
                        index(4) = index(4)+1;
                        input.body.eul(1) = v4;
                        index(5) = 0;
                        %%% body_pitch
                        for v5 = grid.var(5).range
                            index(5) = index(5)+1;
                            input.body.eul(2) = v5;
                            index(6) = 0;
                            %%% body_roll
                            for v6 = grid.var(6).range
                                index(6) = index(6)+1;
                                input.body.eul(3) = v6;
                                index(7) = 0;
                                %%% head_yaw
                                for v7 = grid.var(7).range
                                    index(7) = index(7)+1;
                                    input.head.eul_b(1) = v7;
                                    index(8) = 0;
                                    %%% head_pitch
                                    for v8 = grid.var(8).range
                                        index(8) = index(8)+1;
                                        input.head.eul_b(2) = v8; %15/180*pi; % 
                                        index(9) = 0;
                                        %%% head_roll
                                        for v9 = grid.var(9).range
                                            index(9) = index(9)+1;
                                            input.head.eul_b(3) = v9;
                                            index(10) = 0;
                                            %%% abdomen_yaw
                                            for v10 = grid.var(10).range
                                                index(10) = index(10)+1;
                                                input.abdomen.eul_b(1) = v10;
                                                index(11) = 0;
                                                %%% abdomen_pitch
                                                for v11 = grid.var(11).range
                                                    index(11) = index(11)+1;
                                                    input.abdomen.eul_b(2) = v11; %-7/180*pi; % 
                                                    index(12) = 0;
                                                    %%% abdomen_roll
                                                    for v12 = grid.var(12).range
                                                        index(12) = index(12)+1;
                                                        input.abdomen.eul_b(3) = v12;
                                                        
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        % calculate head and abdomen com and eul
                                                        input = calculate_head_abdomen(animal_dia_,input);
                                                        % calculate beam angle
                                                        input = calculate_state_stl_tribody_v2(input,body_mat,head_mat,abdomen_mat);
                                                        
                                                        % calculate landscape
                                                        landscape.left_beam_angle(frame_i, index(1),index(2),index(3),index(4),index(5),...
                                                            index(6),index(7),index(8),index(9),index(10),index(11),index(12)) = input.beam.angle_left;
                                                        landscape.right_beam_angle(frame_i, index(1),index(2),index(3),index(4),index(5),...
                                                            index(6),index(7),index(8),index(9),index(10),index(11),index(12)) = input.beam.angle_right;
                                                        landscape.potential_energy(frame_i, index(1),index(2),index(3),index(4),index(5),...
                                                            index(6),index(7),index(8),index(9),index(10),index(11),index(12)) = calculate_state_potential_energy(input);

                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    % record other stuff
    landscape.frame_num = frame_num_selected;
    % save
    save([project.folder,'landscape_trial_',num2str(trial_i),'_beam_cal_re_',num2str(beam_cal_re),'.mat'],'landscape');
end





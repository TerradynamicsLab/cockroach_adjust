% interactive code database collection code
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% set project name and folder
project = struct();
project.name = 'barrier_5';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];

% fixed
trial_i = 37;
head_angle = 5;

% sweep steps
x_steps = -24.2:0.2:33;
y_steps = -3:1:3; %3;
yaw_steps = -30:10:30; %-90:10:90;
pitch_steps = -180:5:50;
roll_steps = -180:5:180;

% sweep length
x_length = length(x_steps);
y_length = length(y_steps);
yaw_length = length(yaw_steps);
pitch_length = length(pitch_steps);
roll_length = length(roll_steps);

%% recalculate body Z
Z_add = nan(pitch_length,roll_length);

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);
load([REPO,'/data/kinematics/DataBase.mat']);

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

for i_roll = 1:roll_length
    roll = roll_steps(i_roll);

    for i_pitch = 1:pitch_length
        pitch = pitch_steps(i_pitch);
        

        
        % input
        input.body.com(1) = 0;
        input.body.com(2) = 0;
        input.body.com(3) = 0;
        input.body.eul(1) = 0;
        input.body.eul(2) = pitch *pi/180;
        input.body.eul(3) = roll *pi/180;
        input.head.eul_b(1) = 0;
        input.head.eul_b(2) = head_angle *pi/180; 
        input.head.eul_b(3) = 0;
        input.abdomen.eul_b(1) = 0;
        input.abdomen.eul_b(2) = 0 *pi/180;
        input.abdomen.eul_b(3) = 0;
        
        % calculate head and abdomen com and eul
        input = calculate_head_abdomen(animal_dia,input);
        
        %%% body
        body_mat_t = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
        minZ_body = min(body_mat_t.vertice_position(:,3));
        %%% head
        head_mat_t = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
        minZ_head = min(head_mat_t.vertice_position(:,3));
        %%% abdomen
        abdomen_mat_t = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
        minZ_abdomen = min(abdomen_mat_t.vertice_position(:,3));
        %%% get the minZ and shift the body and head
        minZ = min([minZ_body,minZ_head,minZ_abdomen]);
        
        Z_add(i_pitch,i_roll) = -minZ;
    end
end

%%
% load in PE
potential_energy = nan(x_length,y_length,yaw_length,pitch_length,roll_length);
left_angle = nan(x_length,y_length,yaw_length,pitch_length,roll_length);
right_angle = nan(x_length,y_length,yaw_length,pitch_length,roll_length);
body_Z = nan(x_length,y_length,yaw_length,pitch_length,roll_length);

for i_y = 1:y_length
    for i_yaw = 1:yaw_length
        
        % settle y and yaw
        y_displacement = y_steps(i_y);
        yaw = yaw_steps(i_yaw);
        
        % load PE
        landscape_data = load([project.folder,'compress_trial_',num2str(trial_i),'_head_angle_',num2str(head_angle),'_y_',num2str(y_displacement),'_yaw_',num2str(yaw),'.mat']);
        landscape_data = landscape_data.data;
        %%% mirrored landscape
        landscape_data_m = load([project.folder,'compress_trial_',num2str(trial_i),'_head_angle_',num2str(head_angle),'_y_',num2str(-y_displacement),'_yaw_',num2str(-yaw),'.mat']);
        landscape_data_m = landscape_data_m.data;
        
        % loop
        for i_x = 1:x_length
            for i_pitch = 1:pitch_length
                i_roll_mid = (roll_length+1)/2;
                for i_roll = 1:i_roll_mid
                    % v1
                    % potential_energy(i_x,i_y,i_yaw,i_pitch,i_roll) = landscape_data.landscape_value(i_x,i_roll,i_pitch);
                    
                    % v2
                    potential_energy(i_x,i_y,i_yaw,i_pitch,i_roll_mid + i_roll - 1) = landscape_data.landscape_value(i_x,i_roll,i_pitch);
                    potential_energy(i_x,i_y,i_yaw,i_pitch,i_roll_mid - i_roll + 1) = landscape_data_m.landscape_value(i_x,i_roll,i_pitch);
                    left_angle(i_x,i_y,i_yaw,i_pitch,i_roll_mid + i_roll - 1) = landscape_data.landscape_left_angle(i_x,i_roll,i_pitch);
                    left_angle(i_x,i_y,i_yaw,i_pitch,i_roll_mid - i_roll + 1) = landscape_data_m.landscape_right_angle(i_x,i_roll,i_pitch);
                    right_angle(i_x,i_y,i_yaw,i_pitch,i_roll_mid + i_roll - 1) = landscape_data.landscape_right_angle(i_x,i_roll,i_pitch);
                    right_angle(i_x,i_y,i_yaw,i_pitch,i_roll_mid - i_roll + 1) = landscape_data_m.landscape_left_angle(i_x,i_roll,i_pitch);
                    %%% note: this body Z is the lowest point
                    body_Z(i_x,i_y,i_yaw,i_pitch,i_roll_mid + i_roll - 1) = max(landscape_data.landscape_body_Z(i_x,i_roll,i_pitch), Z_add(i_pitch,i_roll_mid + i_roll - 1));
                    body_Z(i_x,i_y,i_yaw,i_pitch,i_roll_mid - i_roll + 1) = max(landscape_data_m.landscape_body_Z(i_x,i_roll,i_pitch), Z_add(i_pitch,i_roll_mid - i_roll + 1));
                end
            end
        end
    end
end

steps.x_steps = x_steps;
steps.y_steps = y_steps;
steps.yaw_steps = yaw_steps;
steps.pitch_steps = pitch_steps;
steps.roll_steps = roll_steps;

%% save
save([project.folder,'interact_data.mat'],'potential_energy','steps','left_angle','right_angle','body_Z');
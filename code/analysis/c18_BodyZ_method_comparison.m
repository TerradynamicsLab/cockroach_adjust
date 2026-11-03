% Yaqing created this to see if the method "Setting Z to minimize PE(Z)" is
% matching the result with animal experiments.

% Method:
% plot in one figure
%   real animal body Z
%   body Z of "ground contact constraint"
%   body Z of "Setting Z to minimize PE(Z)"
% calculate
%   average different

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

%%%%%%%%%%
save_folder = [REPO,'/output/barrier_3/compare/'];




% load database
load([REPO,'/data/kinematics/DataBase.mat']);
addpath(genpath([REPO,'/code/analysis/Dependences']));
addpath([REPO,'/code/model_construction/Dependences_stl']);


for trial_i = 2:36
    disp(['Trial: ',num2str(trial_i)]);
    
    frame_range = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.LandFrame;
    frame_num_selected = length(frame_range);
    
    % animal information
    animal_NO = DataBase.Trial(trial_i).Info.AnimalNum;
    animal_dia = DataBase.cockroach_model.dia(animal_NO);
    input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass * 1e-3;
    input.body.mass = input.total.mass;
    input.mass_bias_b = [DataBase.cockroach_model.dia(animal_NO).total.mass_bias_b;0;0];
    input.is_ab_trans = 0;
    input.beam_cal_re = 0;
    
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
    animal_dia_.total.neck_point = animal_dia.total.neck_point;
    animal_dia_.total.waist_point = animal_dia.total.waist_point;
    
    % kinematics
    ground_truth_beam_pitch_left = DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch(frame_range)';
    ground_truth_beam_pitch_right = DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch(frame_range)';
    %%% zero beam
    ground_truth_beam_pitch_left = ground_truth_beam_pitch_left-nanmean(ground_truth_beam_pitch_left(1:10));
    ground_truth_beam_pitch_right = ground_truth_beam_pitch_right-nanmean(ground_truth_beam_pitch_right(1:10));
    
    % real animal body Z
    Zr = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_range,3);
    Xr = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_range,1);
    Rr = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_range,3)*180/pi;
    Zo = Zr*0;
    Zn = Zr*0;
    
    for frame_i = 1:length(frame_range)
        
        input.body.com = DataBase.Trial(trial_i).modified.Cockroach.Body.com(frame_range(frame_i),:);
        input.body.eul = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_range(frame_i),:);
        input.head.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_range(frame_i),:);
        input.abdomen.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_range(frame_i),:);
        input.beam.ref_left_pitch = ground_truth_beam_pitch_left(frame_i);
        input.beam.ref_right_pitch = ground_truth_beam_pitch_right(frame_i);
        
        
        %   body Z of "ground contact constraint" 
        input1 = calculate_head_abdomen(animal_dia_,input);
        output = calculate_state_stl_tribody_v2(input1,body_mat,head_mat,abdomen_mat);
        Zo(frame_i) = output.body.com(3);
        
        %   body Z of "Setting Z to minimize PE(Z)"
        body_Zs = [0:1:100];
%         angle_left = [];
        for Z_i = 1:length(body_Zs)
            body_Z = body_Zs(Z_i);
            input1 = input;
            input1.body.com(3) = body_Z;
            input1 = calculate_head_abdomen(animal_dia_,input1);
            input1 = calculate_state_stl_tribody_v2_noshift(input1,body_mat,head_mat,abdomen_mat);
            PE(Z_i) = calculate_state_potential_energy(input1);
%             angle_left = [angle_left,input1.beam.angle_left];
            body_Zs(Z_i) = input1.body.com(3);
        end
        [~,Z_i_min] = min(PE);
%         plot(PE)
%         disp(angle_left)
        Zn(frame_i) = body_Zs(Z_i_min);
        
    end
    
    % plot in one figure
    %   real animal body Z
    %   body Z of "ground contact constraint"
    %   body Z of "Setting Z to minimize PE(Z)"
    
    figure(trial_i);
    hold on;
    
    t = (1:length(frame_range))/100;
    plot(Xr,Zr);
    plot(Xr,Zo);
    plot(Xr,Zn);
    legend('real animal body Z','body Z of ground contact constraint','body Z of Setting Z to minimize PE(Z)','Location','NE');
    title(['Trial: ',num2str(trial_i)]);
    grid on;
    box on;
    
    xlabel('X (mm)')
    ylabel('Body Z (mm)')
    saveas(gcf,[save_folder,'Trial_',num2str(trial_i),'_X.jpg']);

end




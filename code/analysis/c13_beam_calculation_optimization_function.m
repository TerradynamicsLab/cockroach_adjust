function total_error = c13_beam_calculation_optimization_function(trial_i,x0)
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% settings
is_reconstruct = 0;
a_thresh = -100;

% changing in the model
ratio = struct();
ratio.head.length = x0(1);
ratio.head.width = x0(2);
ratio.head.thickness = x0(3);
ratio.body.length = x0(4);
ratio.body.width = x0(5);
ratio.body.thickness = x0(6);
ratio.abdomen.length = x0(7);
ratio.abdomen.width = x0(8);
ratio.abdomen.thickness = x0(9);

% basic
addpath([REPO,'/code/model_construction/Dependences_stl']);
%%% load database
load([REPO,'/data/kinematics/DataBase.mat']);


% input holder
input = struct();

% information
animal_NO = DataBase.Trial(trial_i).Info.AnimalNum;
animal_dia = DataBase.cockroach_model.dia(animal_NO);
frame_num = DataBase.Trial(trial_i).Info.FrameNum;
input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass;

% model mat
head_mat_origin = DataBase.cockroach_model.head(animal_NO);
body_mat_origin = DataBase.cockroach_model.body(animal_NO);
abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);


%%%%%%%%%%% model modification %%%%%%%%%%%%%%%%%%

head_mat= head_mat_origin;
head_mat.vertice_position(:,1) = head_mat.vertice_position(:,1) * ratio.head.length;
head_mat.vertice_position(:,2) = head_mat.vertice_position(:,2) * ratio.head.width;
head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3) * ratio.head.thickness;

body_mat= body_mat_origin;
body_mat.vertice_position(:,1) = body_mat.vertice_position(:,1) * ratio.body.length;
body_mat.vertice_position(:,2) = body_mat.vertice_position(:,2) * ratio.body.width;
body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3) * ratio.body.thickness;

abdomen_mat= abdomen_mat_origin;
abdomen_mat.vertice_position(:,1) = abdomen_mat.vertice_position(:,1) * ratio.abdomen.length;
abdomen_mat.vertice_position(:,2) = abdomen_mat.vertice_position(:,2) * ratio.abdomen.width;
abdomen_mat.vertice_position(:,3) = abdomen_mat.vertice_position(:,3) * ratio.abdomen.thickness;

animal_dia.total.neck_point = animal_dia.total.neck_point * ratio.body.length;
animal_dia.total.waist_point = animal_dia.total.waist_point * ratio.body.length;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% kinematics
body_com = DataBase.Trial(trial_i).modified.Cockroach.Body.com;
body_eul = DataBase.Trial(trial_i).modified.Cockroach.Body.eul;
head_eul_b = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b.*[0,1,0];
abdomen_eul_b = DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b.*[0,1,0];
beam_pitch_left = DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch';
beam_pitch_right = DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch';

% create beam angle holder
beam_pitch_left_model = NaN(length(beam_pitch_left),1);
beam_pitch_right_model = beam_pitch_left_model;

% loop frame to calculate the model beam angle
for frame_i = 1:frame_num
    
    %         disp(frame_i)
    
    % load body frame and head/abdomen relative eul angle
    input.body.com = body_com(frame_i,:);
    input.body.eul = body_eul(frame_i,:);
    input.head.eul_b = head_eul_b(frame_i,:);
    input.abdomen.eul_b = abdomen_eul_b(frame_i,:);
    input.beam.ref_left_pitch = beam_pitch_left(frame_i);
    input.beam.ref_right_pitch = beam_pitch_right(frame_i);
    
    % calculate head and abdomen com and eul
    input = calculate_head_abdomen(animal_dia,input);
    % calculate beam angle
    input = calculate_state_stl_tribody_v2(input,body_mat,head_mat,abdomen_mat);
    
    % load beam
    beam_pitch_left_model(frame_i) = input.beam.angle_left;
    beam_pitch_right_model(frame_i) = input.beam.angle_right;
    
    % reconstruct video
    if is_reconstruct
        body_mat_ = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
        head_mat_ = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
        abdomen_mat_ = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
        reconstruction_visualization_stl_tribody(input,body_mat_,head_mat_,abdomen_mat_);
    end
end

% select frame left
[x,~,a] = fadaptiveB(beam_pitch_left*180/pi,100,5,20,6);
b = (1*x>0)-(1*x<0);
c = a.*b;
frame_selected = [];
for frame_i = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.LandFrame
    if ~isnan(c(frame_i)) && c(frame_i)>a_thresh
        frame_selected = [frame_selected;frame_i];
    end
end
beam_angle_error = [beam_pitch_left_model(frame_selected)-beam_pitch_left(frame_selected)];
% select frame right
[x,~,a] = fadaptiveB(beam_pitch_right*180/pi,100,5,20,6);
b = (1*x>0)-(1*x<0);
c = a.*b;
frame_selected = [];
for frame_i = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.LandFrame
    if ~isnan(c(frame_i)) && c(frame_i)>a_thresh
        frame_selected = [frame_selected;frame_i];
    end
end
beam_angle_error = [beam_angle_error;beam_pitch_right_model(frame_selected)-beam_pitch_right(frame_selected)];

total_error = sqrt(nanmean(beam_angle_error.*beam_angle_error))*180/pi;
% disp(total_error);


end







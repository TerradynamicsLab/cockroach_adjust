close all;
clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
load([REPO,'/data/kinematics/DataBase.mat']);

% holders
LPaPs = nan(36,3);
LPaTs = nan(36,3);
LPaRs = nan(36,3);
RPaPs = nan(36,3);
RPaTs = nan(36,3);
RPaRs = nan(36,3);

for trial_i = 1:36
    PaP_frame = DataBase.Trial(trial_i).Info.RollStartFrame;
    PaT_frame = DataBase.Trial(trial_i).Info.Roll60inFrame;
%     PaR_frame = DataBase.Trial(trial_i).Info.RollEndFrame;
% [~,PaT_frame] = max(DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,3));
    [~,PaR_frame] = max(DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,3));
    
    LPaP = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(PaP_frame,:);
    LPaT = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(PaT_frame,:);
    LPaR = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(PaR_frame,:);
    RPaP = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(PaP_frame,:);
    RPaT = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(PaT_frame,:);
    RPaR = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(PaR_frame,:);
   
    LPaPs(trial_i,:) = LPaP;
    LPaTs(trial_i,:) = LPaT;
    LPaRs(trial_i,:) = LPaR;
    RPaPs(trial_i,:) = RPaP;
    RPaTs(trial_i,:) = RPaT;
    RPaRs(trial_i,:) = RPaR;
    
end


L_Pos_P = mean(LPaPs)
L_STD_P = std(LPaPs)

L_Pos_T = mean(LPaTs)
L_STD_T = std(LPaTs)

L_Pos_R = mean(LPaRs)
L_STD_R = std(LPaRs)

R_Pos_P = mean(RPaPs)
R_STD_P = std(RPaPs)

R_Pos_T = mean(RPaTs)
R_STD_T = std(RPaTs)

R_Pos_R = mean(RPaRs)
R_STD_R = std(RPaRs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath([REPO,'/code/analysis/Dependences']));

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);

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



% % for leg sprawl
% figure(1)
% 
% input.body.com = [-10,0,10];
% input.body.eul = [0,0,0];
% input.head.eul_b = [0,15,0]*pi/180;
% input.abdomen.eul_b = [0,-7,0]*pi/180;
% input.beam.ref_left_pitch = 0;
% input.beam.ref_right_pitch = 0;
% 
% input = calculate_head_abdomen(animal_dia,input);
% [input,body_mat,head_mat,abdomen_mat] = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
% reconstruction_visualization_nogroundbeam(input,body_mat,head_mat,abdomen_mat);
% 
% leg_length = 20.6;
% leg_height = 5;
% leg_r_xy = sqrt(leg_length^2-leg_height^2);
% 
% sprawl_angle = 0; %deg
% 
% toe = [-leg_r_xy*cosd(sprawl_angle/2),-leg_r_xy*sind(sprawl_angle/2),-leg_height]+input.body.com;
% toe2 = [-leg_r_xy*cosd(sprawl_angle/2),leg_r_xy*sind(sprawl_angle/2),-leg_height]+input.body.com;
% plot3([input.body.com(1),toe(1)],[input.body.com(2),toe(2)],[input.body.com(3),toe(3)],'Color','k','LineWidth',5)
% plot3([input.body.com(1),toe2(1)],[input.body.com(2),toe2(2)],[input.body.com(3),toe2(3)],'Color','k','LineWidth',5)
% 
% view(-40, 30)
% view(-90, 90)
% 
% %%% calculate the real sprawl angle
% toe = [-leg_r_xy*cosd(sprawl_angle/2),-leg_r_xy*sind(sprawl_angle/2),-leg_height];
% toe2 = [-leg_r_xy*cosd(sprawl_angle/2),leg_r_xy*sind(sprawl_angle/2),-leg_height];
% acosd((norm(toe)^2+norm(toe2)^2-norm(toe2-toe)^2)/(2*norm(toe)*norm(toe2)))

% for head flexion
figure(1)

head_angle = 5;%-15 5 25 45 65

input.body.com = [0,0,0];
input.body.eul = [0,0,0];
input.head.eul_b = [0,head_angle,0]*pi/180;
input.abdomen.eul_b = [0,-7,0]*pi/180;
input.beam.ref_left_pitch = 0;
input.beam.ref_right_pitch = 0;

input = calculate_head_abdomen(animal_dia,input);
% [input,body_mat,head_mat,abdomen_mat] = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
body_mat = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
head_mat = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
abdomen_mat = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);

reconstruction_visualization_nogroundbeam(input,body_mat,head_mat,abdomen_mat);

% view(-40, 30)
% view(0, 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LINEWIDTH = 3;
MARKERSIZE = 50;

plot3(L_Pos_P(1),L_Pos_P(2),L_Pos_P(3),'.','MarkerSize',MARKERSIZE,'Color','b');
line([L_Pos_P(1)-L_STD_P(1),L_Pos_P(1)+L_STD_P(1)],[L_Pos_P(2),L_Pos_P(2)],[L_Pos_P(3),L_Pos_P(3)],'Color','r','LineWidth',LINEWIDTH);
line([L_Pos_P(1),L_Pos_P(1)],[L_Pos_P(2)-L_STD_P(2),L_Pos_P(2)+L_STD_P(2)],[L_Pos_P(3),L_Pos_P(3)],'Color','g','LineWidth',LINEWIDTH);
line([L_Pos_P(1),L_Pos_P(1)],[L_Pos_P(2),L_Pos_P(2)],[L_Pos_P(3)-L_STD_P(3),L_Pos_P(3)+L_STD_P(3)],'Color','b','LineWidth',LINEWIDTH);

plot3(R_Pos_P(1),R_Pos_P(2),R_Pos_P(3),'.','MarkerSize',MARKERSIZE,'Color','b');
line([R_Pos_P(1)-R_STD_P(1),R_Pos_P(1)+R_STD_P(1)],[R_Pos_P(2),R_Pos_P(2)],[R_Pos_P(3),R_Pos_P(3)],'Color','r','LineWidth',LINEWIDTH);
line([R_Pos_P(1),R_Pos_P(1)],[R_Pos_P(2)-R_STD_P(2),R_Pos_P(2)+R_STD_P(2)],[R_Pos_P(3),R_Pos_P(3)],'Color','g','LineWidth',LINEWIDTH);
line([R_Pos_P(1),R_Pos_P(1)],[R_Pos_P(2),R_Pos_P(2)],[R_Pos_P(3)-R_STD_P(3),R_Pos_P(3)+R_STD_P(3)],'Color','b','LineWidth',LINEWIDTH);

plot3(L_Pos_T(1),L_Pos_T(2),L_Pos_T(3),'.','MarkerSize',MARKERSIZE,'Color',[0.9294    0.6941    0.1255]);
line([L_Pos_T(1)-L_STD_T(1),L_Pos_T(1)+L_STD_T(1)],[L_Pos_T(2),L_Pos_T(2)],[L_Pos_T(3),L_Pos_T(3)],'Color','r','LineWidth',LINEWIDTH);
line([L_Pos_T(1),L_Pos_T(1)],[L_Pos_T(2)-L_STD_T(2),L_Pos_T(2)+L_STD_T(2)],[L_Pos_T(3),L_Pos_T(3)],'Color','g','LineWidth',LINEWIDTH);
line([L_Pos_T(1),L_Pos_T(1)],[L_Pos_T(2),L_Pos_T(2)],[L_Pos_T(3)-L_STD_T(3),L_Pos_T(3)+L_STD_T(3)],'Color','b','LineWidth',LINEWIDTH);

plot3(R_Pos_T(1),R_Pos_T(2),R_Pos_T(3),'.','MarkerSize',MARKERSIZE,'Color',[0.9294    0.6941    0.1255]);
line([R_Pos_T(1)-R_STD_T(1),R_Pos_T(1)+R_STD_T(1)],[R_Pos_T(2),R_Pos_T(2)],[R_Pos_T(3),R_Pos_T(3)],'Color','r','LineWidth',LINEWIDTH);
line([R_Pos_T(1),R_Pos_T(1)],[R_Pos_T(2)-R_STD_T(2),R_Pos_T(2)+R_STD_T(2)],[R_Pos_T(3),R_Pos_T(3)],'Color','g','LineWidth',LINEWIDTH);
line([R_Pos_T(1),R_Pos_T(1)],[R_Pos_T(2),R_Pos_T(2)],[R_Pos_T(3)-R_STD_T(3),R_Pos_T(3)+R_STD_T(3)],'Color','b','LineWidth',LINEWIDTH);

plot3(L_Pos_R(1),L_Pos_R(2),L_Pos_R(3),'.','MarkerSize',MARKERSIZE,'Color','r');
line([L_Pos_R(1)-L_STD_R(1),L_Pos_R(1)+L_STD_R(1)],[L_Pos_R(2),L_Pos_R(2)],[L_Pos_R(3),L_Pos_R(3)],'Color','r','LineWidth',LINEWIDTH);
line([L_Pos_R(1),L_Pos_R(1)],[L_Pos_R(2)-L_STD_R(2),L_Pos_R(2)+L_STD_R(2)],[L_Pos_R(3),L_Pos_R(3)],'Color','g','LineWidth',LINEWIDTH);
line([L_Pos_R(1),L_Pos_R(1)],[L_Pos_R(2),L_Pos_R(2)],[L_Pos_R(3)-L_STD_R(3),L_Pos_R(3)+L_STD_R(3)],'Color','b','LineWidth',LINEWIDTH);

plot3(R_Pos_R(1),R_Pos_R(2),R_Pos_R(3),'.','MarkerSize',MARKERSIZE,'Color','r');
line([R_Pos_R(1)-R_STD_R(1),R_Pos_R(1)+R_STD_R(1)],[R_Pos_R(2),R_Pos_R(2)],[R_Pos_R(3),R_Pos_R(3)],'Color','r','LineWidth',LINEWIDTH);
line([R_Pos_R(1),R_Pos_R(1)],[R_Pos_R(2)-R_STD_R(2),R_Pos_R(2)+R_STD_R(2)],[R_Pos_R(3),R_Pos_R(3)],'Color','g','LineWidth',LINEWIDTH);
line([R_Pos_R(1),R_Pos_R(1)],[R_Pos_R(2),R_Pos_R(2)],[R_Pos_R(3)-R_STD_R(3),R_Pos_R(3)+R_STD_R(3)],'Color','b','LineWidth',LINEWIDTH);


zlim([-20,20])


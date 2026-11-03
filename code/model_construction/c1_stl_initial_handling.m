% Yaqing created this to change stl model to a real stl model usable.

clear; close; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/model_construction/Dependences_stl']));

model_path = [REPO,'/data/cockroach_model/f1_SW_model_V1/'];

%%%%%%%%%%%%%%%%%%%%%%%% body %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% transform stl to mat
fv = stlread_EJ([model_path,'body.stl']);
body = stl2mat_YW(fv);

%% shift to axis
body_tip_stl = [-7.77,-20,4.5];
body_tip_frame = [2.4+18,0,0.5];
Xi = [-pi/2,0,pi/2,body_tip_frame-body_tip_stl];
body = stl_SE3_YW(body,Xi);
save([model_path,'body.mat'],'body');

%% read stl
stl_file = load([model_path,'body.mat']);
stl_file = stl_file.body;

%% plot a stl_struct
body = mat2stl_patchable_YW(stl_file);

patch(body,...
         'FaceColor',       [0.9294,0.6902,0.1294], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);

set(gca,'fontsize',40);axis equal;
light('Position',[500 0 100]);light('Position',[-500 0 100]);light('Position',[0 0 200]);
xlabel('X');ylabel('Y'); 
view(-35,26);
xlim([-130 130]);ylim([-30 30]*1.5); zlim([0 80]);
ground = patch([-1 -1 1 1]*120,[-1 1 1 -1]*40,[0 0 0 0],'black');
set(ground,'facealpha' ,0.3);lighting gouraud;
hold on


%%%%%%%%%%%%%%%%%%%%%%%% head %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% transform stl to mat
fv = stlread_EJ([model_path,'head.stl']);
head = stl2mat_YW(fv);

%% shift to axis
head_tip_stl = [-6,-20,3.311];
head_tip_frame = [10.17,0,-0.5];
Xi = [-pi/2,0,pi/2,head_tip_frame-head_tip_stl];
head = stl_SE3_YW(head,Xi);
save([model_path,'head.mat'],'head');

%% read stl
stl_file = load([model_path,'head.mat']);
stl_file = stl_file.head;

%% shift [18,0,0.5]
stl_file = stl_SE3_YW(stl_file,[0,0,0,18,0,0.5]);

%% plot a stl_struct
head = mat2stl_patchable_YW(stl_file);

patch(head,...
         'FaceColor',       'r', ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);

%%%%%%%%%%%%%%%%%%%%%%%% abdomen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% transform stl to mat
fv = stlread_EJ([model_path,'abdomen.stl']);
abdomen = stl2mat_YW(fv);

%% shift to axis
abdomen_tip_stl = [-52.17,-13.81,3.659];
abdomen_tip_frame = [-27.5,0,0];
Xi = [-pi/2,0,pi/2,abdomen_tip_frame-abdomen_tip_stl];
abdomen = stl_SE3_YW(abdomen,Xi);
save([model_path,'abdomen.mat'],'abdomen');

%% read stl
stl_file = load([model_path,'abdomen.mat']);
stl_file = stl_file.abdomen;

%% shift [-14.5,0,0]+[18,0,0.5]
stl_file = stl_SE3_YW(stl_file,[0,0,0,-14.5+18,0,0.5]);

%% plot a stl_struct
abdomen = mat2stl_patchable_YW(stl_file);

patch(abdomen,...
         'FaceColor',       [1,1,0.2], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
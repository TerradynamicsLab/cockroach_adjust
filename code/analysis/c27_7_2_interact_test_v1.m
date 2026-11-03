% function c27_7_2_interact_test

% interactive code database collection code
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% is Chen's pc or not
is_Chen = 0;

% set project name and folder
project = struct();
project.name = 'barrier_5';
if is_Chen
    project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
else
    project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
end

global indexes ff steps potential_energy left_angle right_angle body_Z head_angle animal_dia body_mat head_mat abdomen_mat
head_angle = 5;
load([project.folder,'interact_data.mat']);

% setup figures
ff.fh = figure(1);
set(gcf,'Position',[1 41 1680 933])
clf;

mk_size = 8;
indexes = ones(1,5);

%% 3d section
%%% load in
% load data
if is_Chen
    addpath([REPO,'/code/model_construction/Dependences_stl']);
    load([REPO,'/data/kinematics/DataBase.mat']);
else
    addpath([REPO,'/code/model_construction/Dependences_stl']);
    load([REPO,'/data/kinematics/DataBase.mat']);
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

input.body.com(1) = 0;
input.body.com(2) = 0;
input.body.com(3) = 0;
input.body.eul(1) = 0;
input.body.eul(2) = 0;
input.body.eul(3) = 0;
input.head.eul_b(1) = 0;
input.head.eul_b(2) = head_angle *pi/180; %v8;
input.head.eul_b(3) = 0;
input.abdomen.eul_b(1) = 0;
input.abdomen.eul_b(2) = 0 *pi/180;
input.abdomen.eul_b(3) = 0;
input.beam.angle_left = 0;
input.beam.angle_right = 0;

% calculate head and abdomen com and eul
input = calculate_head_abdomen(animal_dia,input);

% paper and background
ff.sp(7) = subplot(3,3,9);
set(gca,'fontsize',20);
axis equal;
light('Position',[500 0 100]);light('Position',[-500 0 100]);light('Position',[0 0 200]);
xlabel('X');ylabel('Y');
view(-35,26);
xlim([-130 130]);ylim([-50 50]); zlim([0 80]);
ground = patch([-1 -1 1 1]*120,[-1 1 1 -1]*40,[0 0 0 0],'black');
set(ground,'facealpha' ,0.3);lighting gouraud;
hold on
% body drawing
body_patchable = mat2stl_patchable_YW(body_mat);
ff.Handler_3d.body = patch(body_patchable,...
    'FaceColor',       [0.9294,0.6902,0.1294], ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.15);
% head drawing
head_patchable = mat2stl_patchable_YW(head_mat);
ff.Handler_3d.head = patch(head_patchable,...
    'FaceColor',       'r', ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.15);
% abdomen drawing
abdomen_patchable = mat2stl_patchable_YW(abdomen_mat);
ff.Handler_3d.abdomen = patch(abdomen_patchable,...
    'FaceColor',       [1,1,0.2], ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.15);
% beams
beam_width = 10;
beam_height = 80;
beam_gap = 10;
beam_left_corners_x = [0 beam_height*sin(input.beam.angle_left) beam_height*sin(input.beam.angle_left) 0]';
beam_left_corners_y = [-1 -1 1 1]'*beam_width/2+(beam_gap + beam_width)/2;
beam_left_corners_z = [0 beam_height*cos(input.beam.angle_left) beam_height*cos(input.beam.angle_left) 0]';
ff.Handler_3d.beam_left = patch('XData',beam_left_corners_x,'YData',beam_left_corners_y,'ZData',beam_left_corners_z,'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',2);
beam_right_corners_x = [0 beam_height*sin(input.beam.angle_right) beam_height*sin(input.beam.angle_right) 0]';
beam_right_corners_y = [-1 -1 1 1]'*beam_width/2-(beam_gap + beam_width)/2;
beam_right_corners_z = [0 beam_height*cos(input.beam.angle_right) beam_height*cos(input.beam.angle_right) 0]';
ff.Handler_3d.beam_right = patch('XData',beam_right_corners_x,'YData',beam_right_corners_y,'ZData',beam_right_corners_z,'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',2);

%% 2d sections
% 1. y and yaw
ff.sp(1) = subplot(3,3,1);
hold on; box on; set(gca,'fontsize',15,'tag','sp_y_yaw_sec','boxstyle','full')
colormap(fire)
[Y,X] = meshgrid(steps.yaw_steps, steps.y_steps);
ff.sh(1) = surf(X,Y,squeeze(potential_energy(1,:,:,1,1)), 'edgealpha',0,'tag','y_yaw_sec');
ff.mh(1) = plot(0,0,'marker','o','markerfacecolor','g','markeredgecolor','k','markersize',mk_size,'tag','state_cx');
view(-90,-90)
xlim([min(steps.y_steps),max(steps.y_steps)]);           xticks([-3,-2,-1,0,1,2,3]*1); xticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3'})
ylim([min(steps.yaw_steps),max(steps.yaw_steps)]);       yticks([-3,-2,-1,0,1,2,3,4]*10); yticklabels({[char(8211) '30'],[char(8211) '20'],[char(8211) '10'],'0','10','20','30','40'})
ylabel('yaw (°)');
xlabel('y (mm)');
set(get(gca,'xaxis'),'direction','reverse');
set(get(gca,'yaxis'),'direction','reverse');

% 2. pitch and roll
ff.sp(2) = subplot(3,3,2);
hold on; box on; set(gca,'fontsize',15,'tag','sp_pitch_roll_sec','boxstyle','full')
colormap(fire)
[Y,X] = meshgrid(steps.roll_steps, steps.pitch_steps);
ff.sh(2) = surf(X,Y,squeeze(potential_energy(1,1,1,:,:)), 'edgealpha',0,'tag','pitch_roll_sec');
ff.mh(2) = plot(0,0,'marker','o','markerfacecolor','g','markeredgecolor','k','markersize',mk_size,'tag','state_cx');
view(-90,-90)
xlim([-180,50]);       xticks([-4,-3,-2,-1,0,1,2]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90'})
ylim([-180,180]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylabel('roll (°)');
xlabel('pitch (°)');
set(get(gca,'yaxis'),'direction','reverse');

% 3. yaw and pitch
ff.sp(3) = subplot(3,3,4);
hold on; box on; set(gca,'fontsize',15,'tag','sp_yaw_pitch_sec','boxstyle','full')
colormap(fire)
[Y,X] = meshgrid(steps.pitch_steps, steps.yaw_steps);
ff.sh(3) = surf(X,Y,squeeze(potential_energy(1,1,:,:,1)), 'edgealpha',0,'tag','yaw_pitch_sec');
ff.mh(3) = plot(0,0,'marker','o','markerfacecolor','g','markeredgecolor','k','markersize',mk_size,'tag','state_cx');
view(-90,-90)
xlim([min(steps.yaw_steps),max(steps.yaw_steps)]);       xticks([-3,-2,-1,0,1,2,3,4]*10); xticklabels({[char(8211) '30'],[char(8211) '20'],[char(8211) '10'],'0','10','20','30','40'})
ylim([-180,50]);       yticks([-4,-3,-2,-1,0,1,2]*45);   yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90'})
ylabel('pitch (°)');
xlabel('yaw (°)');
set(get(gca,'xaxis'),'direction','reverse');
set(get(gca,'yaxis'),'direction','reverse');

% 4. yaw and roll
ff.sp(4) = subplot(3,3,5);
hold on; box on; set(gca,'fontsize',15,'tag','sp_yaw_roll_sec','boxstyle','full')
colormap(fire)
[Y,X] = meshgrid(steps.roll_steps, steps.yaw_steps);
ff.sh(4) = surf(X,Y,squeeze(potential_energy(1,1,:,1,:)), 'edgealpha',0,'tag','yaw_pitch_sec');
ff.mh(4) = plot(0,0,'marker','o','markerfacecolor','g','markeredgecolor','k','markersize',mk_size,'tag','state_cx');
view(-90,-90)
xlim([min(steps.yaw_steps),max(steps.yaw_steps)]);       xticks([-3,-2,-1,0,1,2,3,4]*10); xticklabels({[char(8211) '30'],[char(8211) '20'],[char(8211) '10'],'0','10','20','30','40'})
ylim([-180,180]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylabel('roll (°)');
xlabel('yaw (°)');
set(get(gca,'xaxis'),'direction','reverse');
set(get(gca,'yaxis'),'direction','reverse');

% 5. y and pitch
ff.sp(5) = subplot(3,3,7);
hold on; box on; set(gca,'fontsize',15,'tag','sp_y_pitch_sec','boxstyle','full')
colormap(fire)
[Y,X] = meshgrid(steps.pitch_steps, steps.y_steps);
ff.sh(5) = surf(X,Y,squeeze(potential_energy(1,:,1,:,1)), 'edgealpha',0,'tag','y_pitch_sec');
ff.mh(5) = plot(0,0,'marker','o','markerfacecolor','g','markeredgecolor','k','markersize',mk_size,'tag','state_cx');
view(-90,-90)
xlim([min(steps.y_steps),max(steps.y_steps)]);       xticks([-3,-2,-1,0,1,2,3,4]*1); xticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3','4'})
ylim([-180,50]);       yticks([-4,-3,-2,-1,0,1,2]*45);   yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90'})
ylabel('pitch (°)');
xlabel('y (mm)');
set(get(gca,'xaxis'),'direction','reverse');
set(get(gca,'yaxis'),'direction','reverse');

% 6. y and roll
ff.sp(6) = subplot(3,3,8);
hold on; box on; set(gca,'fontsize',15,'tag','sp_yaw_roll_sec','boxstyle','full')
colormap(fire)
[Y,X] = meshgrid(steps.roll_steps, steps.y_steps);
ff.sh(6) = surf(X,Y,squeeze(potential_energy(1,:,1,1,:)), 'edgealpha',0,'tag','yaw_pitch_sec');
ff.mh(6) = plot(0,0,'marker','o','markerfacecolor','g','markeredgecolor','k','markersize',mk_size,'tag','state_cx');
view(-90,-90)
xlim([min(steps.y_steps),max(steps.y_steps)]);       xticks([-3,-2,-1,0,1,2,3,4]*1); xticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3','4'})
ylim([-180,180]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylabel('roll (°)');
xlabel('y (mm)');
set(get(gca,'xaxis'),'direction','reverse');
set(get(gca,'yaxis'),'direction','reverse');

%% gui controls
ff.sl.x = uicontrol('style','slider','units','pixel','string','x','tag','tag_sl_x');
ff.sl.x.Max = max(steps.x_steps);
ff.sl.x.Min = min(steps.x_steps);
addlistener(ff.sl.x,'ContinuousValueChange',@(hObject, event) update_fig(hObject,event));

ff.sl.y = uicontrol('style','slider','units','pixel','string','y','tag','tag_sl_y');
ff.sl.y.Max = max(steps.y_steps);
ff.sl.y.Min = min(steps.y_steps);
addlistener(ff.sl.y,'ContinuousValueChange',@(hObject, event) update_fig(hObject,event));

ff.sl.yaw = uicontrol('style','slider','units','pixel','string','yaw','tag','tag_sl_yaw');
ff.sl.yaw.Max = max(steps.yaw_steps);
ff.sl.yaw.Min = min(steps.yaw_steps);
addlistener(ff.sl.yaw,'ContinuousValueChange',@(hObject, event) update_fig(hObject,event));

ff.sl.pitch = uicontrol('style','slider','units','pixel','string','pitch','tag','tag_sl_pitch');
ff.sl.pitch.Max = max(steps.pitch_steps);
ff.sl.pitch.Min = min(steps.pitch_steps);
addlistener(ff.sl.pitch,'ContinuousValueChange',@(hObject, event) update_fig(hObject,event));

ff.sl.roll = uicontrol('style','slider','units','pixel','string','roll','tag','tag_sl_roll');
ff.sl.roll.Max = max(steps.roll_steps);
ff.sl.roll.Min = min(steps.roll_steps);
addlistener(ff.sl.roll,'ContinuousValueChange',@(hObject, event) update_fig(hObject,event));

ff.bt = uicontrol('style','pushbutton');
addlistener(ff.bt,'ButtonDown',@(hObject, event) reset_fig());

for ii=1:5
    ff.st(ii) = uicontrol('style','text','units','normalized','tag',['var_' num2str(ii)]);
end

% configure ui components
% set top right subplot emptly
subplot(2,3,3)
hold on
set(gca,'visible','off')

% set slider and its text positions
fn = fieldnames(ff.sl);
for ii = 1:numel(fn)
    ff.sl.(fn{ii}).Units = 'normalized';
    ff.sl.(fn{ii}).Position = [0.65 0.80-(ii-1)*0.07 .2 .02] ;
    ff.st(ii).Position      = [0.65 0.83-(ii-1)*0.07 .2 .03] ;
    ff.st(ii).FontSize      = 15;
    ff.st(ii).BackgroundColor = 'w';
end
ff.st(1).String = ['forward position = ', num2str(steps.x_steps(indexes(1)))];
ff.st(2).String = ['lateral position = ', num2str(steps.y_steps(indexes(2)))];
ff.st(3).String = ['yaw = ', num2str(steps.yaw_steps(indexes(3)))];
ff.st(4).String = ['pitch = ', num2str(steps.pitch_steps(indexes(4)))];
ff.st(5).String = ['roll = ', num2str(steps.roll_steps(indexes(5)))];

% reset button
ff.bt.Units = 'normalized';
ff.bt.Position = [0.65 0.9 0.2 0.03];
ff.bt.String = 'Right click here to reset';
ff.bt.FontSize = 15;

% reset the figure once before showing
reset_fig()

%% functions
function update_fig(hObject, event)

global indexes ff steps potential_energy left_angle right_angle body_Z head_angle animal_dia body_mat head_mat abdomen_mat

val_temp = get(hObject,'Value');
switch hObject.String
    case 'x'
        temp_steps = steps.x_steps;
    case 'y'
        temp_steps = steps.y_steps;
    case 'yaw'
        temp_steps = steps.yaw_steps;
    case 'pitch'
        temp_steps = steps.pitch_steps;
    case 'roll'
        temp_steps = steps.roll_steps;
end
[~, min_idx] = min(abs(temp_steps-val_temp));

if(temp_steps(min_idx)<0)
    str_app=char(8211);
else
    str_app='';
end

switch hObject.String
    case 'x'
        indexes(1) = min_idx;
        ff.st(1).String = ['forward position = ', num2str(steps.x_steps(indexes(1)))];
    case 'y'
        indexes(2) = min_idx;
        ff.st(2).String = ['lateral position = ', num2str(steps.y_steps(indexes(2)))];
        ff.mh(1).XData = steps.y_steps(indexes(2));
        ff.mh(5).XData = steps.y_steps(indexes(2));
        ff.mh(6).XData = steps.y_steps(indexes(2));
    case 'yaw'
        indexes(3) = min_idx;
        ff.st(3).String = ['yaw = ', num2str(steps.yaw_steps(indexes(3)))];
        ff.mh(1).YData = steps.yaw_steps(indexes(3));
        ff.mh(3).XData = steps.yaw_steps(indexes(3));
        ff.mh(4).XData = steps.yaw_steps(indexes(3));
    case 'pitch'
        indexes(4) = min_idx;
        ff.st(4).String = ['pitch = ', num2str(steps.pitch_steps(indexes(4)))];
        ff.mh(2).XData = steps.pitch_steps(indexes(4));
        ff.mh(3).YData = steps.pitch_steps(indexes(4));
        ff.mh(5).YData = steps.pitch_steps(indexes(4));
    case 'roll'
        indexes(5) = min_idx;
        ff.st(5).String = ['roll = ', num2str(steps.roll_steps(indexes(5)))];
        ff.mh(2).YData = steps.roll_steps(indexes(5));
        ff.mh(4).YData = steps.roll_steps(indexes(5));
        ff.mh(6).YData = steps.roll_steps(indexes(5));
end

% 3d plot
input.body.com(1) = steps.x_steps(indexes(1));
input.body.com(2) = steps.y_steps(indexes(2));
input.body.com(3) = body_Z(indexes(1),indexes(2),indexes(3),indexes(4),indexes(5));
input.body.eul(1) = steps.yaw_steps(indexes(3))*pi/180;
input.body.eul(2) = steps.pitch_steps(indexes(4))*pi/180;
input.body.eul(3) = steps.roll_steps(indexes(5))*pi/180;
input.head.eul_b(1) = 0;
input.head.eul_b(2) = head_angle *pi/180;
input.head.eul_b(3) = 0;
input.abdomen.eul_b(1) = 0;
input.abdomen.eul_b(2) = 0 *pi/180;
input.abdomen.eul_b(3) = 0;
input.beam.angle_left = left_angle(indexes(1),indexes(2),indexes(3),indexes(4),indexes(5));
input.beam.angle_right = right_angle(indexes(1),indexes(2),indexes(3),indexes(4),indexes(5));
input = calculate_head_abdomen(animal_dia,input);
body_mat_t = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
body_patchable = mat2stl_patchable_YW(body_mat_t);
head_mat_t = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
head_patchable = mat2stl_patchable_YW(head_mat_t);
abdomen_mat_t = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
abdomen_patchable = mat2stl_patchable_YW(abdomen_mat_t);

ff.Handler_3d.body.Vertices = body_patchable.vertices;
ff.Handler_3d.head.Vertices = head_patchable.vertices;
ff.Handler_3d.abdomen.Vertices = abdomen_patchable.vertices;

% beams
beam_width = 10;
beam_height = 80;
beam_gap = 10;
beam_left_corners_x = [0 beam_height*sin(input.beam.angle_left) beam_height*sin(input.beam.angle_left) 0]';
beam_left_corners_y = [-1 -1 1 1]'*beam_width/2+(beam_gap + beam_width)/2;
beam_left_corners_z = [0 beam_height*cos(input.beam.angle_left) beam_height*cos(input.beam.angle_left) 0]';
ff.Handler_3d.beam_left.XData = beam_left_corners_x;
ff.Handler_3d.beam_left.YData = beam_left_corners_y;
ff.Handler_3d.beam_left.ZData = beam_left_corners_z;
beam_right_corners_x = [0 beam_height*sin(input.beam.angle_right) beam_height*sin(input.beam.angle_right) 0]';
beam_right_corners_y = [-1 -1 1 1]'*beam_width/2-(beam_gap + beam_width)/2;
beam_right_corners_z = [0 beam_height*cos(input.beam.angle_right) beam_height*cos(input.beam.angle_right) 0]';
ff.Handler_3d.beam_right.XData = beam_right_corners_x;
ff.Handler_3d.beam_right.YData = beam_right_corners_y;
ff.Handler_3d.beam_right.ZData = beam_right_corners_z;


% 2d plot
ff.sh(1).ZData = squeeze(potential_energy(indexes(1),:,:,indexes(4),indexes(5)));
ff.sh(2).ZData = squeeze(potential_energy(indexes(1),indexes(2),indexes(3),:,:));
ff.sh(3).ZData = squeeze(potential_energy(indexes(1),indexes(2),:,:,indexes(5)));
ff.sh(4).ZData = squeeze(potential_energy(indexes(1),indexes(2),:,indexes(4),:));
ff.sh(5).ZData = squeeze(potential_energy(indexes(1),:,indexes(3),:,indexes(5)));
ff.sh(6).ZData = squeeze(potential_energy(indexes(1),:,indexes(3),indexes(4),:));
end

function reset_fig()
global indexes ff steps potential_energy left_angle right_angle body_Z head_angle animal_dia body_mat head_mat abdomen_mat
ff.sl.x.Value = -24.2;
[~, indexes(1)] = min(abs(steps.x_steps-ff.sl.x.Value));
ff.sl.y.Value = 0;
[~, indexes(2)] = min(abs(steps.y_steps-ff.sl.y.Value));
ff.sl.yaw.Value = 0;
[~, indexes(3)] = min(abs(steps.yaw_steps-ff.sl.yaw.Value));
ff.sl.pitch.Value = 0;
[~, indexes(4)] = min(abs(steps.pitch_steps-ff.sl.pitch.Value));
ff.sl.roll.Value = 0;
[~, indexes(5)] = min(abs(steps.roll_steps-ff.sl.roll.Value));

ff.st(1).String = ['forward position = ', num2str(steps.x_steps(indexes(1)))];
ff.st(2).String = ['lateral position = ', num2str(steps.y_steps(indexes(2)))];
ff.st(3).String = ['yaw = ', num2str(steps.yaw_steps(indexes(3)))];
ff.st(4).String = ['pitch = ', num2str(steps.pitch_steps(indexes(4)))];
ff.st(5).String = ['roll = ', num2str(steps.roll_steps(indexes(5)))];

% 3d plot
input.body.com(1) = steps.x_steps(indexes(1));
input.body.com(2) = steps.y_steps(indexes(2));
input.body.com(3) = body_Z(indexes(1),indexes(2),indexes(3),indexes(4),indexes(5));
input.body.eul(1) = steps.yaw_steps(indexes(3))*pi/180;
input.body.eul(2) = steps.pitch_steps(indexes(4))*pi/180;
input.body.eul(3) = steps.roll_steps(indexes(5))*pi/180;
input.head.eul_b(1) = 0;
input.head.eul_b(2) = head_angle *pi/180;
input.head.eul_b(3) = 0;
input.abdomen.eul_b(1) = 0;
input.abdomen.eul_b(2) = 0 *pi/180;
input.abdomen.eul_b(3) = 0;
input.beam.angle_left = left_angle(indexes(1),indexes(2),indexes(3),indexes(4),indexes(5));
input.beam.angle_right = right_angle(indexes(1),indexes(2),indexes(3),indexes(4),indexes(5));
input = calculate_head_abdomen(animal_dia,input);
body_mat_t = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
body_patchable = mat2stl_patchable_YW(body_mat_t);
head_mat_t = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
head_patchable = mat2stl_patchable_YW(head_mat_t);
abdomen_mat_t = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
abdomen_patchable = mat2stl_patchable_YW(abdomen_mat_t);

ff.Handler_3d.body.Vertices = body_patchable.vertices;
ff.Handler_3d.head.Vertices = head_patchable.vertices;
ff.Handler_3d.abdomen.Vertices = abdomen_patchable.vertices;

% beams
beam_width = 10;
beam_height = 80;
beam_gap = 10;
beam_left_corners_x = [0 beam_height*sin(input.beam.angle_left) beam_height*sin(input.beam.angle_left) 0]';
beam_left_corners_y = [-1 -1 1 1]'*beam_width/2+(beam_gap + beam_width)/2;
beam_left_corners_z = [0 beam_height*cos(input.beam.angle_left) beam_height*cos(input.beam.angle_left) 0]';
ff.Handler_3d.beam_left.XData = beam_left_corners_x;
ff.Handler_3d.beam_left.YData = beam_left_corners_y;
ff.Handler_3d.beam_left.ZData = beam_left_corners_z;
beam_right_corners_x = [0 beam_height*sin(input.beam.angle_right) beam_height*sin(input.beam.angle_right) 0]';
beam_right_corners_y = [-1 -1 1 1]'*beam_width/2-(beam_gap + beam_width)/2;
beam_right_corners_z = [0 beam_height*cos(input.beam.angle_right) beam_height*cos(input.beam.angle_right) 0]';
ff.Handler_3d.beam_right.XData = beam_right_corners_x;
ff.Handler_3d.beam_right.YData = beam_right_corners_y;
ff.Handler_3d.beam_right.ZData = beam_right_corners_z;


% 2d plot
ff.sh(2).ZData = squeeze(potential_energy(indexes(1),indexes(2),indexes(3),:,:));

end

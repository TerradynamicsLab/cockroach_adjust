% Yaqing created this on 09/16/2019 to visualize the reconstruction result.
% The stucture of input_stuct is as follows:
% input
%     body
%         com          %  mm 1*3
%         eul          % rad 1*3
%     head
%         com          %  mm 1*3
%         eul          % rad 1*3
%     abdomen
%         com          %  mm 1*3
%         eul          % rad 1*3
%     beam
%         angle_left   % rad 1*1
%         angle_right  % rad 1*1
%     varargin:
%         body_mat
%         head_mat
%         abdomen_mat

function reconstruction_visualization_stl_tribody(input,varargin)
% Check to use
if isempty(varargin)
    %%% calculation body_mat
    body_mat = load('../body.mat');
    body_mat = body_mat.body;
    body_mat = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
    %%% calculation head_mat
    head_mat = load('../head.mat');
    head_mat = head_mat.head;
    head_mat = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
    %%% calculation head_mat
    abdomen_mat = load('../abdomen.mat');
    abdomen_mat = abdomen_mat.abdomen;
    abdomen_mat = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
else
    body_mat = varargin{1};
    head_mat = varargin{2};
    abdomen_mat = varargin{3};
end

% paper and background
% f = figure(1);
% clf;
set(gcf,'Position',[30,30,1200,1000])
set(gca,'fontsize',40);
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
patch(body_patchable,...
    'FaceColor',       [0.9294,0.6902,0.1294], ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.15);
% head drawing
head_patchable = mat2stl_patchable_YW(head_mat);
patch(head_patchable,...
         'FaceColor',       'r', ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
% abdomen drawing
abdomen_patchable = mat2stl_patchable_YW(abdomen_mat);
patch(abdomen_patchable,...
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
beam_left = patch('XData',beam_left_corners_x,'YData',beam_left_corners_y,'ZData',beam_left_corners_z,'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',2);
beam_right_corners_x = [0 beam_height*sin(input.beam.angle_right) beam_height*sin(input.beam.angle_right) 0]';
beam_right_corners_y = [-1 -1 1 1]'*beam_width/2-(beam_gap + beam_width)/2;
beam_right_corners_z = [0 beam_height*cos(input.beam.angle_right) beam_height*cos(input.beam.angle_right) 0]';
beam_right = patch('XData',beam_right_corners_x,'YData',beam_right_corners_y,'ZData',beam_right_corners_z,'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',2);
end
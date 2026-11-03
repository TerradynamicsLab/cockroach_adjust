% Yaqing modified this to calculate potential_energy of state, knowing all cockroach information,
% and animal stl models in .mat format.
% input
%     head
%         com          % mm  1*3
%         eul          % rad 1*3
%     body
%         mass         % kg  1*1
%         com          % mm  1*3
%         eul          % rad 1*3
%     varargin:
%         body_mat_raw
%         head_mat_raw
% output:
% potential_energy     % mJ  1*1
% left_hit             % bool 1*1 :  0:no hit, 1: hit on the body, 2:hit on the head
% right_hit            % bool 1*1 :  0:no hit, 1: hit on the body, 2:hit on the head

function [potential_energy,left_hit,right_hit] = calculate_state_stl(input,isplot,varargin)
% loading and initializing
if isempty(varargin)
    body_mat = load('../body.mat');
    body_mat = body_mat.body;
    head_mat = load('../head.mat');
    head_mat = head_mat.head;
else
    body_mat = varargin{1};
    head_mat = varargin{2};
end

% set cockroach on the floor
%%% body
body_mat = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
minZ_body = min(body_mat.vertice_position(:,3));
%%% head
head_mat = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
minZ_head = min(head_mat.vertice_position(:,3));
%%% get the minZ and shift the body and head
minZ = min(minZ_body,minZ_head)-0.001;
input.body.com(3) = input.body.com(3)-minZ;
input.head.com(3) = input.head.com(3)-minZ;
body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3)-minZ;
head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3)-minZ;

% beam bending angle
[possible_angles_left_body,possible_angles_right_body] = calculate_ellip_tangent_angle_stl(body_mat);
[possible_angles_left_head,possible_angles_right_head] = calculate_ellip_tangent_angle_stl(head_mat);

%%% for the left
input.beam.angle_left = 0;
left_hit = 0;
possible_angles_left_body = possible_angles_left_body(possible_angles_left_body<=pi/2);
if ~isempty(possible_angles_left_body)
    if max(possible_angles_left_body)>input.beam.angle_left
        left_hit = 1;
        input.beam.angle_left = max(possible_angles_left_body);
    end
end
possible_angles_left_head = possible_angles_left_head(possible_angles_left_head<=pi/2);
if ~isempty(possible_angles_left_head)
    if max(possible_angles_left_head)>input.beam.angle_left
        left_hit = 2;
        input.beam.angle_left = max(possible_angles_left_head);
    end
end
    
%%% for the right
input.beam.angle_right = 0;
right_hit = 0;
possible_angles_right_body = possible_angles_right_body(possible_angles_right_body<=pi/2);
if ~isempty(possible_angles_right_body)
    if max(possible_angles_right_body)>input.beam.angle_right
        right_hit = 1;
        input.beam.angle_right = max(possible_angles_right_body);
    end
end
possible_angles_right_head = possible_angles_right_head(possible_angles_right_head<=pi/2);
if ~isempty(possible_angles_right_head)
    if max(possible_angles_right_head)>input.beam.angle_right
        right_hit = 2;
        input.beam.angle_right = max(possible_angles_right_head);
    end
end

% use calculation function to get result
potential_energy = calculate_state_potential_energy(input);
% disp(potential_energy);

% figure verification
if isplot == 1
reconstruction_visualization_stl(input,body_mat,head_mat);
end
end
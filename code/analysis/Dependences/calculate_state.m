% Yaqing created this on 09/19/2019 to calculate potential_energy of a
% state, knowing all cockroach information.
% input
%     head
%         dia          % mm  1*3
%         com          % mm  1*3
%         rpy          % rad 1*3
%     body
%         mass         % kg  1*1
%         dia          % mm  1*3
%         com          % mm  1*3
%         rpy          % rad 1*3
% output:
% potential_energy     % mJ  1*1
% left_hit             % bool 1*1 :  0:no hit, 1: hit on the body, 2:hit on the head
% right_hit            % bool 1*1 :  0:no hit, 1: hit on the body, 2:hit on the head

function [potential_energy,left_hit,right_hit] = calculate_state(input)
% set cockroach on the floor
%%% body
[body_pts_x , body_pts_y , body_pts_z ]  = ellipsoid(0, 0, 0,  input.body.dia(1),  input.body.dia(2),  input.body.dia(3) );
body_pts_raw_x_reshaped = reshape(body_pts_x, [1,prod(size(body_pts_x))]);
body_pts_raw_y_reshaped = reshape(body_pts_y, [1,prod(size(body_pts_y))]);
body_pts_raw_z_reshaped = reshape(body_pts_z, [1,prod(size(body_pts_z))]);
body_t = [eul2rotm(input.body.eul),input.body.com';0,0,0,1];
body_pts_now = body_t*[body_pts_raw_x_reshaped;body_pts_raw_y_reshaped;body_pts_raw_z_reshaped;ones(1,length(body_pts_raw_x_reshaped))];
minZ_body = min(body_pts_now(3,:));
%%% head
[head_pts_x , head_pts_y , head_pts_z ]  = ellipsoid(0, 0, 0,  input.head.dia(1),  input.head.dia(2),  input.head.dia(3) );
head_pts_raw_x_reshaped = reshape(head_pts_x, [1,prod(size(head_pts_x))]);
head_pts_raw_y_reshaped = reshape(head_pts_y, [1,prod(size(head_pts_y))]);
head_pts_raw_z_reshaped = reshape(head_pts_z, [1,prod(size(head_pts_z))]);
head_t = [eul2rotm(input.head.eul),input.head.com';0,0,0,1];
head_pts_now = head_t*[head_pts_raw_x_reshaped;head_pts_raw_y_reshaped;head_pts_raw_z_reshaped;ones(1,length(head_pts_raw_x_reshaped))];
minZ_head = min(head_pts_now(3,:));
%%% get the minZ and shift the body and head
minZ = min(minZ_body,minZ_head)-0.001;
input.body.com(3) = input.body.com(3)-minZ;
input.head.com(3) = input.head.com(3)-minZ;

% beam bending angle
[possible_angles_left_body,possible_angles_right_body] = calculate_ellip_tangent_angle(input.body);
[possible_angles_left_head,possible_angles_right_head] = calculate_ellip_tangent_angle(input.head);

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
% reconstruction_visualization(input);
end
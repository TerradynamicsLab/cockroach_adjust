% Yaqing modified this to calculate potential_energy of state, knowing all cockroach information,
% and animal stl models in .mat format.
% input
%     total
%         mass         % kg  1*1            
%     head
%         com          % mm  1*3
%         eul          % rad 1*3
%     body
%         com          % mm  1*3
%         eul          % rad 1*3
%     abdomen
%         com          % mm  1*3
%         eul          % rad 1*3
% varargin:
%         body_mat_raw
%         head_mat_raw
%         abdomen_mat_raw
%
% output (also name input):
%     total
%         mass         % kg  1*1            
%     head
%         com          % mm  1*3
%         eul          % rad 1*3
%     body
%         com          % mm  1*3
%         eul          % rad 1*3
%     abdomen
%         com          % mm  1*3
%         eul          % rad 1*3
%     beam
%         angle_left   % rad 1*1
%         angle_right   % rad 1*1
%         left_hit             % bool 1*1 :  0:no hit, 1: hit on the body, 2:head, 3: abdomen 
%         right_hit            % bool 1*1 :  0:no hit, 1: hit on the body, 2:head, 3: abdomen 

function input = calculate_state_stl_tribody(input,varargin)
% loading and initializing
if isempty(varargin)
    %%% calculation body_mat
    body_mat = load('../body.mat');
    body_mat = body_mat.body;
    %%% calculation head_mat
    head_mat = load('../head.mat');
    head_mat = head_mat.head;
    %%% calculation head_mat
    abdomen_mat = load('../abdomen.mat');
    abdomen_mat = abdomen_mat.abdomen;
else
    body_mat = varargin{1};
    head_mat = varargin{2};
    abdomen_mat = varargin{3};
end

% set cockroach on the floor
%%% body
body_mat = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
minZ_body = min(body_mat.vertice_position(:,3));
%%% head
head_mat = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
minZ_head = min(head_mat.vertice_position(:,3));
%%% abdomen
abdomen_mat = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
minZ_abdomen = min(abdomen_mat.vertice_position(:,3));
%%% get the minZ and shift the body and head
minZ = min([minZ_body,minZ_head,minZ_abdomen])-0.001;
input.body.com(3) = input.body.com(3)-minZ;
input.head.com(3) = input.head.com(3)-minZ;
input.abdomen.com(3) = input.abdomen.com(3)-minZ;
body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3)-minZ;
head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3)-minZ;
abdomen_mat.vertice_position(:,3) = abdomen_mat.vertice_position(:,3)-minZ;

% beam bending angle
[possible_angles_left_body,possible_angles_right_body] = calculate_ellip_tangent_angle_stl(body_mat);
[possible_angles_left_head,possible_angles_right_head] = calculate_ellip_tangent_angle_stl(head_mat);
[possible_angles_left_abdomen,possible_angles_right_abdomen] = calculate_ellip_tangent_angle_stl(abdomen_mat);

%%% for the left
input.beam.angle_left = 0;
input.beam.left_hit = 0;
possible_angles_left_body = possible_angles_left_body(possible_angles_left_body<=pi/2);
if ~isempty(possible_angles_left_body)
    if max(possible_angles_left_body)>input.beam.angle_left
        input.beam.left_hit = 1;
        input.beam.angle_left = max(possible_angles_left_body);
    end
end
possible_angles_left_head = possible_angles_left_head(possible_angles_left_head<=pi/2);
if ~isempty(possible_angles_left_head)
    if max(possible_angles_left_head)>input.beam.angle_left
        input.beam.left_hit = 2;
        input.beam.angle_left = max(possible_angles_left_head);
    end
end
possible_angles_left_abdomen = possible_angles_left_abdomen(possible_angles_left_abdomen<=pi/2);
if ~isempty(possible_angles_left_abdomen)
    if max(possible_angles_left_abdomen)>input.beam.angle_left
        input.beam.left_hit = 3;
        input.beam.angle_left = max(possible_angles_left_abdomen);
    end
end

%%% for the right
input.beam.angle_right = 0;
input.beam.right_hit = 0;
possible_angles_right_body = possible_angles_right_body(possible_angles_right_body<=pi/2);
if ~isempty(possible_angles_right_body)
    if max(possible_angles_right_body)>input.beam.angle_right
        input.beam.right_hit = 1;
        input.beam.angle_right = max(possible_angles_right_body);
    end
end
possible_angles_right_head = possible_angles_right_head(possible_angles_right_head<=pi/2);
if ~isempty(possible_angles_right_head)
    if max(possible_angles_right_head)>input.beam.angle_right
        input.beam.right_hit = 2;
        input.beam.angle_right = max(possible_angles_right_head);
    end
end
possible_angles_right_abdomen = possible_angles_right_abdomen(possible_angles_right_abdomen<=pi/2);
if ~isempty(possible_angles_right_abdomen)
    if max(possible_angles_right_abdomen)>input.beam.angle_right
        input.beam.right_hit = 3;
        input.beam.angle_right = max(possible_angles_right_abdomen);
    end
end

end
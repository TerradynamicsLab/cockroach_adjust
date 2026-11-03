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

%     beam
%         ref_left_pitch      % rad 1*1
%         ref_right_pitch     % rad 1*1

%     is_ab_trans      % bool 1*1

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

function input = calculate_state_stl_tribody_v2(input,varargin)
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

% mass bias
G = [eul2rotm(input.body.eul),input.body.com';0,0,0,1];
mass_bias = G*[input.mass_bias_b;0];
input.mass_z = input.body.com(3) + mass_bias(3);

% beam bending angle
[possible_angles_left_body,possible_angles_right_body] = calculate_ellip_tangent_angle_stl(body_mat);
[possible_angles_left_head,possible_angles_right_head] = calculate_ellip_tangent_angle_stl(head_mat);
if ~isfield(input, 'is_ab_trans')
    input.is_ab_trans = 0;
end
if input.is_ab_trans == 0
    [possible_angles_left_abdomen,possible_angles_right_abdomen] = calculate_ellip_tangent_angle_stl(abdomen_mat);
else
    possible_angles_left_abdomen = [NaN,NaN];
    possible_angles_right_abdomen = [NaN,NaN];
end

if input.beam_cal_re == 1
    
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
    
else
    % left beam angle
    
    %%% forbidden area
    left_forbid = [];
    if ~isnan(possible_angles_left_body(1))
        left_forbid = [left_forbid;possible_angles_left_body([2,1])];
    end
    if ~isnan(possible_angles_left_head(1))
        left_forbid = [left_forbid;possible_angles_left_head([2,1])];
    end
    if ~isnan(possible_angles_left_abdomen(1))
        left_forbid = [left_forbid;possible_angles_left_abdomen([2,1])];
    end
    
    forbidden_num = size(left_forbid,1);
    
    %%% possible ones
    left_possible = [0];
    for item_i = 1:forbidden_num
        if(left_forbid(item_i,1)<0)
            left_possible = [left_possible,left_forbid(item_i,1)];
        end
        if(left_forbid(item_i,2)>0)
            left_possible = [left_possible,left_forbid(item_i,2)];
        end
    end
    %%%%% eliminate the ones in forbid area
    is_possible = ones(1,length(left_possible));
    for possible_i = 1:length(left_possible)
        for item_i = 1:forbidden_num
            if(left_forbid(item_i,1)<left_possible(possible_i) && left_forbid(item_i,2)>left_possible(possible_i))
                is_possible(possible_i) = 0;
            end
        end
    end
    left_possible = left_possible(is_possible == 1);
    %%% reference
    left_ref = input.beam.ref_left_pitch;
    %%%%% check if ref in forbid area
    is_ref_forbid = 0;
    for item_i = 1:forbidden_num
        if(left_forbid(item_i,1)<left_ref && left_forbid(item_i,2)>left_ref)
            is_ref_forbid = 1;
        end
    end
    %%%%% if in forbid area, go outward
    if is_ref_forbid == 1
        % initiation
        left_angle = pi/2;
        distance_min = pi*2;
        % comparison
        for angle_temp = left_possible
            %         if sign(angle_temp) ~= sign(left_ref)  && sign(left_ref)*sign(angle_temp)~=0
            %             continue;
            %         end
            %         if abs(angle_temp) < abs(left_ref)
            %             continue;
            %         end
            dis_temp = abs(angle_temp-left_ref);
            if dis_temp < distance_min
                distance_min = dis_temp;
                left_angle = angle_temp;
            end
        end
        %%%%% if in forbid area, go inward
    else
        % initiation
        left_angle = pi/2;
        distance_min = pi*2;
        % comparison
        for angle_temp = left_possible
            if sign(angle_temp) ~= sign(left_ref) && sign(left_ref)*sign(angle_temp)~=0
                continue;
            end
            if abs(angle_temp) > abs(left_ref)
                continue;
            end
            dis_temp = abs(angle_temp-left_ref);
            if dis_temp < distance_min
                distance_min = dis_temp;
                left_angle = angle_temp;
            end
        end
    end
    if abs(left_angle)<pi/2
        input.beam.angle_left = left_angle;
    else
        error("error!");
    end
    
    
    % right beam angle
    %%% forbidden area
    right_forbid = [];
    if ~isnan(possible_angles_right_body(1))
        right_forbid = [right_forbid;possible_angles_right_body([2,1])];
    end
    if ~isnan(possible_angles_right_head(1))
        right_forbid = [right_forbid;possible_angles_right_head([2,1])];
    end
    if ~isnan(possible_angles_right_abdomen(1))
        right_forbid = [right_forbid;possible_angles_right_abdomen([2,1])];
    end
    
    forbidden_num = size(right_forbid,1);
    
    %%% possible ones
    right_possible = [0];
    for item_i = 1:forbidden_num
        if(right_forbid(item_i,1)<0)
            right_possible = [right_possible,right_forbid(item_i,1)];
        end
        if(right_forbid(item_i,2)>0)
            right_possible = [right_possible,right_forbid(item_i,2)];
        end
    end
    %%%%% eliminate the ones in forbid area
    is_possible = ones(1,length(right_possible));
    for possible_i = 1:length(right_possible)
        for item_i = 1:forbidden_num
            if(right_forbid(item_i,1)<right_possible(possible_i) && right_forbid(item_i,2)>right_possible(possible_i))
                is_possible(possible_i) = 0;
            end
        end
    end
    right_possible = right_possible(is_possible == 1);
    %%% reference
    right_ref = input.beam.ref_right_pitch;
    %%%%% check if ref in forbid area
    is_ref_forbid = 0;
    for item_i = 1:forbidden_num
        if(right_forbid(item_i,1)<right_ref && right_forbid(item_i,2)>right_ref)
            is_ref_forbid = 1;
        end
    end
    %%%%% if in forbid area, go outward
    if is_ref_forbid == 1
        % initiation
        right_angle = pi/2;
        distance_min = pi*2;
        % comparison
        for angle_temp = right_possible
            %         if sign(angle_temp) ~= sign(right_ref)  && sign(right_ref)*sign(angle_temp)~=0
            %             continue;
            %         end
            %         if abs(angle_temp) < abs(right_ref)
            %             continue;
            %         end
            dis_temp = abs(angle_temp-right_ref);
            if dis_temp < distance_min
                distance_min = dis_temp;
                right_angle = angle_temp;
            end
        end
        %%%%% if in forbid area, go inward
    else
        % initiation
        right_angle = pi/2;
        distance_min = pi*2;
        % comparison
        for angle_temp = right_possible
            if sign(angle_temp) ~= sign(right_ref) && sign(right_ref)*sign(angle_temp)~=0
                continue;
            end
            if abs(angle_temp) > abs(right_ref)
                continue;
            end
            dis_temp = abs(angle_temp-right_ref);
            if dis_temp < distance_min
                distance_min = dis_temp;
                right_angle = angle_temp;
            end
        end
    end
    
    if abs(right_angle)<pi/2
        input.beam.angle_right = right_angle;
    else
        error("error!");
    end
    
end

% reconstruction_visualization_stl_tribody(input,body_mat,head_mat,abdomen_mat);


end
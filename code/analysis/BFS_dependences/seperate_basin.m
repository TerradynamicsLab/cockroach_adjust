% Separate_basin
% Given a landscape, separate each point into basins
% 0: no following any basin
% landscape(y,x)

function [basin_landscape,basin_size] = seperate_basin(landscape,is_X_loop,is_Y_loop)

% Size of the landscape
Y_length = size(landscape,1);
X_length = size(landscape,2);

% find all minima
[minima_Xs,minima_Ys,~] = find_all_minima(landscape,is_X_loop,is_Y_loop);
num_minima = length(minima_Xs);

% initiation
basin_landscape = landscape*0;
is_boundary = landscape*0;
for basin_id = 1:num_minima
    basin_landscape(minima_Ys(basin_id),minima_Xs(basin_id)) = basin_id;
end

% BFS
landscape_size = size(landscape);
% form the trying array holder, not bigger than the pixels of landscape
array_x = nan(1,landscape_size(1)*landscape_size(2)+1);
array_y = nan(1,landscape_size(1)*landscape_size(2)+1);
% array_z = nan(1,landscape_size(1)*landscape_size(2)+1);
vector_x = [-1,1,0,0];
vector_y = [0,0,1,-1];
% initiation
array_x(1:num_minima) = minima_Xs;
array_y(1:num_minima) = minima_Ys;
% array_z(1:num_minima) = minima_Zs;
pointer_front = 1;
pointer_rear = num_minima+1;

% loop the array
while pointer_front < pointer_rear
%     disp(pointer_front)
    
    % go to next point
    temp_x = array_x(pointer_front);
    temp_y = array_y(pointer_front);
%     array_z(pointer_front) = landscape(temp_y,temp_x);
    
    % check whether this point can expand
    %%% boundary do not expand
    if is_boundary(temp_y,temp_x)
        pointer_front = pointer_front+1;
        continue;
    end
    
    % basin_id, the color
    basin_id = basin_landscape(temp_y,temp_x);
    if basin_id == 0
        error("basin_id == 0");
    end
    
    % generate next points
    for p_i = 1:4
        next_x = temp_x + vector_x(p_i);
        next_y = temp_y + vector_y(p_i);
        
        % check if is out of the map
        if is_X_loop == 1
            next_x = mod(next_x-1,X_length)+1;
        elseif next_x<1 || next_x>X_length
            continue;
        end
        if is_Y_loop == 1
            next_y = mod(next_y-1,Y_length)+1;
        elseif next_y<1 || next_y>Y_length
            continue;
        end
        
        % marker if the point is at the array
        is_insert = 0;
        % check if have gone there
        for j = 1:pointer_front-1
            if compare_points([next_x,next_y],[array_x(j),array_y(j)]) == 0
                % check if it is boundary
                if basin_id ~= basin_landscape(next_y,next_x)
                    is_boundary(next_y,next_x) = 1;
                    basin_landscape(next_y,next_x) = 0;
                end
                % mark and go out of the loop
                is_insert = 1;
                break;
            end
        end
        if is_insert == 0
            % find a place in the array for it
            for j = pointer_front+1:pointer_rear-1
                % if find the exact one for the future
                if compare_points([next_x,next_y],[array_x(j),array_y(j)]) == 0
                    % check if it is boundary
                    if basin_id ~= basin_landscape(next_y,next_x)
                        is_boundary(next_y,next_x) = 1;
                        basin_landscape(next_y,next_x) = 0;
                    end
                    % mark and go out of the loop
                    is_insert = 1;
                    break;
                end
                % if find a place to insert
                if compare_points([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == -1
                    % insert the point at j
                    %%% blank the space in j
                    array_x(j+1:end) = array_x(j:end-1);
                    array_y(j+1:end) = array_y(j:end-1);
                    %%% insert
                    array_x(j) = next_x;
                    array_y(j) = next_y;
                    %%% basin_id, the color
                    basin_landscape(next_y,next_x) = basin_id;
                    % move pointer_rear
                    pointer_rear = pointer_rear+1;
                    % mark and go out of the loop
                    is_insert = 1;
                    break;
                end
            end
        end
        if is_insert == 0
            % insert it at last
            array_x(pointer_rear) = next_x;
            array_y(pointer_rear) = next_y;
            % basin_id, the color
            basin_landscape(next_y,next_x) = basin_id;
            % move pointer_rear
            pointer_rear = pointer_rear+1;
        end 
    end
    % go to the next element in the array
    pointer_front = pointer_front + 1;
end

basin_size = zeros(1,num_minima);
for x_i = 1:X_length
    for y_i = 1:Y_length
        basin_color = basin_landscape(y_i,x_i);
        if basin_color > 0
            basin_size(basin_color) = basin_size(basin_color)+1;
        end
    end
end
end
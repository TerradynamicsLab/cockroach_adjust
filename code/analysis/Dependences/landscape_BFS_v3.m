% From landscape_BFS_v3
% 1. change all the "Barrier" to "Col", now the difference between Pitch
% minimum and Col is called barrier
% 2. generate a path PM->COL->RM

function output = landscape_BFS_v3(landscape, start_x, start_y)

% set whether check or not
to_check = 0;

landscape_size = size(landscape);
% form the trying array holder, not bigger than the pixels of landscape
array_x = nan(1,landscape_size(1)*landscape_size(2)+1);
array_y = nan(1,landscape_size(1)*landscape_size(2)+1);
array_value = nan(1,landscape_size(1)*landscape_size(2)+1);
vector_x = [-1,1,0,0];
vector_y = [0,0,1,-1];
% initiation
array_x(1) = start_x;
array_y(1) = start_y;
i_col = 1;
col_x = start_x;
col_y = start_y;
col_value = landscape(start_y,start_x);
pointer_front = 1; 
pointer_rear = 2;

if to_check == 1
    % For checking the code
    surf(landscape,'EdgeAlpha',0);
    colormap(fire);
    hold on;
    xlabel('x');
    ylabel('y');
%     xlabel('Body roll (°)');
%     ylabel('Body pitch (°)');
    xlim([0,90]);
    ylim([5,65]);
    zlim([0,6]);
    view([-129,66]);
end

% loop the array
while pointer_front < pointer_rear
    % go to next point
    temp_x = array_x(pointer_front);
    temp_y = array_y(pointer_front);
    array_value(pointer_front) = landscape(temp_y,temp_x);
    
    if to_check == 1
        % For checking the code
        disp(['X:',num2str(temp_x),',Y:',num2str(temp_y),',Value:',num2str(landscape(temp_y,temp_x))]);
        plot3(temp_x,temp_y,landscape(temp_y,temp_x),'Marker','.','Color','w','MarkerSize',10,'LineWidth',10);
        hold on;
%         disp(array_x(~isnan(array_x)));
%         disp(array_y(~isnan(array_y)));
    end
    
    % refresh col_value
    if landscape(temp_y,temp_x) > col_value
        i_col = pointer_front;
        col_x = temp_x;
        col_y = temp_y;
        col_value = landscape(temp_y,temp_x);
    end
    
    % check goal
    if check_point_BFS(landscape_size,temp_x,temp_y)==1
        A_pause = 1;
        break;
    end
    
    % generate next points
    for i = 1:4
        next_x = temp_x + vector_x(i);
        next_y = temp_y + vector_y(i);
        
        % check if is out of the map
        if check_point_BFS(landscape_size,next_x,next_y) == 0
            continue;
        end
        
        % marker if the point is at the array
        is_insert = 0;
        % check if have gone there
        for j = 1:pointer_front-1
            if compare_points_BFS([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == 0
                % mark and go out of the loop
                is_insert = 1;
                break;
            end
        end
        if is_insert == 0
            % find a place in the array for it
            for j = pointer_front+1:pointer_rear-1
                % if find the exact one for the future
                if compare_points_BFS([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == 0
                    % mark and go out of the loop
                    is_insert = 1;
                    break;
                end
                % if find a place to insert
                if compare_points_BFS([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == -1
                    % insert the point at j
                    %%% blank the space in j
                    array_x(j+1:end) = array_x(j:end-1);
                    array_y(j+1:end) = array_y(j:end-1);
                    %%% insert
                    array_x(j) = next_x;
                    array_y(j) = next_y;
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
            % move pointer_rear
            pointer_rear = pointer_rear+1;
        end
        
        
    end
    
    % go to the next element in the array
    pointer_front = pointer_front + 1;
end

% find Pitch_minimum, roll_minimum and col
output = struct();
col_value = array_value(i_col);
output.col.x = array_x(i_col);
output.col.y = array_y(i_col);
output.col.value = col_value;
[roll_mini_value,i_roll_mini] = min(array_value(i_col:end)); 
output.roll_minimum.x = array_x(i_roll_mini+i_col-1);
output.roll_minimum.y = array_y(i_roll_mini+i_col-1);
output.roll_minimum.value = roll_mini_value;

% find the path
path_from_col_to_RM_x = array_x(i_col:i_roll_mini+i_col-1);
path_from_col_to_RM_y = array_y(i_col:i_roll_mini+i_col-1);

% go from COL to PM
% second time initiation
PM_x = array_x(i_col);
PM_y = array_y(i_col);
PM_value = landscape(PM_y,PM_x);
array_x = nan(1,landscape_size(1)*landscape_size(2)+1);
array_y = nan(1,landscape_size(1)*landscape_size(2)+1);
array_value = nan(1,landscape_size(1)*landscape_size(2)+1);
array_x(1:length(path_from_col_to_RM_x)-1) = path_from_col_to_RM_x(2:end);
array_y(1:length(path_from_col_to_RM_x)-1) = path_from_col_to_RM_y(2:end);
array_x(length(path_from_col_to_RM_x)) = PM_x;
array_y(length(path_from_col_to_RM_x)) = PM_y;
pointer_front = length(path_from_col_to_RM_x); 
pointer_rear = length(path_from_col_to_RM_x)+1;
i_pitch_mini = length(path_from_col_to_RM_x);
% loop the array
while pointer_front < pointer_rear
    % go to next point
    temp_x = array_x(pointer_front);
    temp_y = array_y(pointer_front);
    array_value(pointer_front) = landscape(temp_y,temp_x);
    
    if to_check == 1
        % For checking the code
        disp(['X:',num2str(temp_x),',Y:',num2str(temp_y),',Value:',num2str(landscape(temp_y,temp_x))]);
        plot3(temp_x,temp_y,landscape(temp_y,temp_x),'Marker','.','Color','w','MarkerSize',10,'LineWidth',10);
        hold on;
%         disp(array_x(~isnan(array_x)));
%         disp(array_y(~isnan(array_y)));
    end
    
    
    % check goal
    is_local_mini = 0;
   
    % generate next points
    for i = 1:4
        next_x = temp_x + vector_x(i);
        next_y = temp_y + vector_y(i);
        
        % check if is out of the map
        if ~(next_x>=1 && next_x<=landscape_size(2) && next_y>=1 && next_y<=landscape_size(1))
            continue;
        end
        
        % marker if the point is at the array
        is_insert = 0;
        % check if have gone there
        for j = 1:pointer_front-1
            if compare_points_BFS([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == 0
                % mark and go out of the loop
                is_insert = 1;
                break;
            end
        end
        if is_insert == 0
            % find a place in the array for it
            for j = pointer_front+1:pointer_rear-1
                % if find the exact one for the future
                if compare_points_BFS([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == 0
                    % mark and go out of the loop
                    is_insert = 1;
                    break;
                end
                % if find a place to insert
                if compare_points_BFS([landscape(next_y,next_x),next_x,next_y],[landscape(array_y(j),array_x(j)),array_x(j),array_y(j)]) == -1
                    % insert the point at j
                    %%% blank the space in j
                    array_x(j+1:end) = array_x(j:end-1);
                    array_y(j+1:end) = array_y(j:end-1);
                    %%% insert
                    array_x(j) = next_x;
                    array_y(j) = next_y;
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
            % move pointer_rear
            pointer_rear = pointer_rear+1;
        end
        if landscape(temp_y,temp_x) < landscape(next_y,next_x)
            is_local_mini = is_local_mini+1;
        end
        
    end
    % check goal
    if is_local_mini == 4
        i_pitch_mini = pointer_front;
        break;
    end
    
    % go to the next element in the array
    pointer_front = pointer_front + 1;
end

%%% pitch minimum
output.pitch_minimum.x = array_x(i_pitch_mini);
output.pitch_minimum.y = array_y(i_pitch_mini);
output.pitch_minimum.value = array_value(i_pitch_mini);

if pointer_front == pointer_rear
    pointer_front = pointer_front-1;
end

path_from_PM_to_COL_x = array_x(pointer_front:-1:length(path_from_col_to_RM_x)+1);
path_from_PM_to_COL_y = array_y(pointer_front:-1:length(path_from_col_to_RM_x)+1);
output.path.x = [path_from_PM_to_COL_x,path_from_col_to_RM_x];
output.path.y = [path_from_PM_to_COL_y,path_from_col_to_RM_y];
end




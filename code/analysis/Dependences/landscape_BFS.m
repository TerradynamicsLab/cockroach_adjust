% sequence, barrier_value,|x|,|y|

function [barrier_x, barrier_y, barrier_value] = landscape_BFS(landscape, start_x, start_y)
% set whether check or not
to_check = 0;

landscape_size = size(landscape);
% form the trying array holder, not bigger than the pixels of landscape
array_x = nan(1,landscape_size(1)*landscape_size(2)+1);
array_y = nan(1,landscape_size(1)*landscape_size(2)+1);
vector_x = [-1,1,0,0];
vector_y = [0,0,1,-1];
% initiation
array_x(1) = start_x;
array_y(1) = start_y;
barrier_x = start_x;
barrier_y = start_y;
barrier_value = landscape(start_y,start_x);
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
    
    if to_check == 1
        % For checking the code
        disp(['X:',num2str(temp_x),',Y:',num2str(temp_y),',Value:',num2str(landscape(temp_y,temp_x))]);
        plot3(temp_x,temp_y,landscape(temp_y,temp_x),'Marker','.','Color','w','MarkerSize',10,'LineWidth',10);
        hold on;
%         disp(array_x(~isnan(array_x)));
%         disp(array_y(~isnan(array_y)));
    end
    
    % refresh barrier_value
    if landscape(temp_y,temp_x) > barrier_value
        barrier_x = temp_x;
        barrier_y = temp_y;
        barrier_value = landscape(temp_y,temp_x);
    end
    
    % check goal
    if check_point_BFS(landscape_size,temp_x,temp_y)==1
        A_pause = 1;
        return;
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
end




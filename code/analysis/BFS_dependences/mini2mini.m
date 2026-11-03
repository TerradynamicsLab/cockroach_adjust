% mini2mini.m
% Yaqing created this on 11/5/2020
% input:
%   landscape(y,x)  n*m
%   xA              1*1
%   yA              1*1
%   xB              1*1
%   yB              1*1
% output:
%   saddleXYZ       3*1
%   routeXYZ        k*1
%   basin_landscape n*m 1:A 2:B 0: saddle -1: not involved

function [saddleXYZ,routeXYZ,basin_landscape] = mini2mini(landscape,xA,yA,xB,yB,is_X_loop,is_Y_loop)

is_check = 0;

zA = landscape(yA,xA);
zB = landscape(yB,xB);

% Size of the landscape
Y_length = size(landscape,1);
X_length = size(landscape,2);

% initiation
basin_landscape = landscape*0-1;
basin_landscape(yA,xA) = 1;
basin_landscape(yB,xB) = 2;

% BFS
landscape_size = size(landscape);
% form the trying array holder, not bigger than the pixels of landscape
array_x = nan(1,landscape_size(1)*landscape_size(2)+1);
array_y = nan(1,landscape_size(1)*landscape_size(2)+1);
array_z = nan(1,landscape_size(1)*landscape_size(2)+1);
father_x = landscape*0;
father_y = landscape*0;
father_x_2 = landscape*0;
father_y_2 = landscape*0;
% array_z = nan(1,landscape_size(1)*landscape_size(2)+1);
vector_x = [0,0,-1,1];
vector_y = [-1,1,0,0];
% initiation
if zA < zB
    array_x(1:2) = [xA,xB];
    array_y(1:2) = [yA,yB];
    array_z(1:2) = [landscape(yA,xA),landscape(yB,xB)];
else
    array_x(1:2) = [xB,xA];
    array_y(1:2) = [yB,yA];
    array_z(1:2) = [landscape(yB,xB),landscape(yA,xA)];
end
father_x(yA,xA) = -1;
father_y(yA,xA) = -1;
father_x(yB,xB) = -1;
father_y(yB,xB) = -1;
pointer_front = 1;
pointer_rear = 3;
found_saddle = 0;


if is_check
    figure(1);
    surf(landscape);
    view(0,-90);
    hold on;
end

% BFS - loop the array
while pointer_front < pointer_rear
    %     disp(pointer_front)
    
    % go to next point
    temp_x = array_x(pointer_front);
    temp_y = array_y(pointer_front);
    %     array_z(pointer_front) = landscape(temp_y,temp_x);
    
    % check saddle
    if basin_landscape(temp_y,temp_x) == 0
        saddle_NO = pointer_front;
        break;
    end
  
    if is_check
        plot3(temp_x,temp_y,landscape(temp_y,temp_x),'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g')
        
    end
    
    % basin_id, the color
    basin_id = basin_landscape(temp_y,temp_x);

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
                    found_saddle = 1;
                    saddle_NO = j;
                    saddle_x = next_x;
                    saddle_y = next_y;
                    basin_landscape(next_y,next_x) = 0;
                    father_x_2(next_y,next_x) = temp_x;
                    father_y_2(next_y,next_x) = temp_y;
                    break;
                end
                % mark and go out of the loop
                is_insert = 1;
                break;
            end
        end
        if found_saddle == 1
            break;
        end
  
        if is_insert == 0
            % find a place in the array for it
            for j = pointer_front+1:pointer_rear-1
                % if find the exact one for the future
                if compare_points([next_x,next_y],[array_x(j),array_y(j)]) == 0
                    % check if it is boundary
                    if basin_id ~= basin_landscape(next_y,next_x)
%                         found_saddle = 1;
%                         saddle_NO = j;
                        saddle_x = next_x;
                        saddle_y = next_y;
                        basin_landscape(next_y,next_x) = 0;
                        father_x_2(next_y,next_x) = temp_x;
                        father_y_2(next_y,next_x) = temp_y;
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
                    array_z(j+1:end) = array_z(j:end-1);
                    %%% insert
                    array_x(j) = next_x;
                    array_y(j) = next_y;
                    array_z(j) = landscape(next_y,next_x);
                    father_x(next_y,next_x) = temp_x;
                    father_y(next_y,next_x) = temp_y;
                    %%% basin_id, the color
                    basin_landscape(next_y,next_x) = basin_id;
                    % move pointer_rear
                    pointer_rear = pointer_rear+1;
                    % mark and go out of the loop
                    is_insert = 1;
                    if is_check
                        plot3(next_x,next_y,landscape(next_y,next_x),'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g')
                    end
                    break;
                end
            end
%             if found_saddle == 1
%                 break;
%             end
        end
        if is_insert == 0
            % insert it at last
            array_x(pointer_rear) = next_x;
            array_y(pointer_rear) = next_y;
            array_z(pointer_rear) = landscape(next_y,next_x);
            if is_check
                plot3(next_x,next_y,landscape(next_y,next_x),'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g')
            end
            father_x(next_y,next_x) = temp_x;
            father_y(next_y,next_x) = temp_y;
            % basin_id, the color
            basin_landscape(next_y,next_x) = basin_id;
            % move pointer_rear
            pointer_rear = pointer_rear+1;
        end
    end
    if found_saddle == 1
        break;
    end
    % go to the next element in the array
    pointer_front = pointer_front + 1;
end

if is_check
    plot3(array_x(saddle_NO+1:end),array_y(saddle_NO+1:end),array_z(saddle_NO+1:end),'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g')
    
end


% two part of route
%%% 1. saddle -> one of the minima
pointer_x = array_x(saddle_NO);
pointer_y = array_y(saddle_NO);
routeXYZ = [array_x(saddle_NO);array_y(saddle_NO);landscape(array_y(saddle_NO),array_x(saddle_NO))];
while father_x(pointer_y,pointer_x) ~= -1
    pointer_x_new = father_x(pointer_y,pointer_x);
    pointer_y_new = father_y(pointer_y,pointer_x);
    pointer_x = pointer_x_new;
    pointer_y = pointer_y_new;
    new_XYZ = [pointer_x;pointer_y;landscape(pointer_y,pointer_x)];
    routeXYZ = [new_XYZ,routeXYZ];
end

%%% 2. saddle -> pointer_front -> the other one
pointer_x = father_x_2(array_y(saddle_NO),array_x(saddle_NO));
pointer_y = father_y_2(array_y(saddle_NO),array_x(saddle_NO));
new_XYZ = [pointer_x;pointer_y;landscape(pointer_y,pointer_x)];
routeXYZ = [routeXYZ,new_XYZ];
while father_x(pointer_y,pointer_x) ~= -1
    pointer_x_new = father_x(pointer_y,pointer_x);
    pointer_y_new = father_y(pointer_y,pointer_x);
    pointer_x = pointer_x_new;
    pointer_y = pointer_y_new;
    new_XYZ = [pointer_x;pointer_y;landscape(pointer_y,pointer_x)];
    routeXYZ = [routeXYZ,new_XYZ];
end

%%% once inverse route
if routeXYZ(1,1) ~= xA
    l = size(routeXYZ,2);
    for i = 1:l
        new_routeXYZ(1:3,i) = routeXYZ(1:3,l-i+1);
    end
    routeXYZ = new_routeXYZ;
end

% saddle point
[~,saddle_NO] = max(routeXYZ(3,:));
saddleXYZ = routeXYZ(1:3,saddle_NO);

end
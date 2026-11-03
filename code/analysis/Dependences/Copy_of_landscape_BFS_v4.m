% From landscape_BFS_v3
% 1. change all the "Barrier" to "Saddle", now the difference between Pitch
% minimum and Col is called barrier
% 2. generate a path PM->SD->RM

function output = landscape_BFS_v4(landscape, start_x, start_y)

% set whether check or not
to_check = 0;

landscape_size = size(landscape);
% form the trying array holder, not bigger than the pixels of landscape
array_x = nan(1,landscape_size(1)*landscape_size(2)+1);
array_y = nan(1,landscape_size(1)*landscape_size(2)+1);
father_x = nan(landscape_size(1),landscape_size(2));
father_y = nan(landscape_size(1),landscape_size(2));
array_value = nan(1,landscape_size(1)*landscape_size(2)+1);
vector_x = [-1,1,0,0];
vector_y = [0,0,1,-1];
% initiation
array_x(1) = start_x;
array_y(1) = start_y;
father_x(start_y,start_x) = 0;
father_y(start_y,start_x) = 0;
pointer_front = 1; 
pointer_rear = 2;

% loop the array
while pointer_front < pointer_rear
    % go to next point
    temp_x = array_x(pointer_front);
    temp_y = array_y(pointer_front);
    array_value(pointer_front) = landscape(temp_y,temp_x);
    
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
                    
                    % mark father
                    father_x(next_y,next_x) = temp_x;
                    father_y(next_y,next_x) = temp_y;
                    
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
            father_x(next_y,next_x) = temp_x;
            father_y(next_y,next_x) = temp_y;
            
            % move pointer_rear
            pointer_rear = pointer_rear+1;
        end
        
        
    end
    
    % go to the next element in the array
    pointer_front = pointer_front + 1;
end

% find Pitch_minimum, roll_minimum and saddle
old_array_point_num = pointer_front-1;
old_array_x = array_x(1:old_array_point_num);
old_array_y = array_y(1:old_array_point_num);
old_array_value = array_value(1:old_array_point_num);

array_x = [old_array_x(end)];
array_y = [old_array_y(end)];
array_value = [old_array_value(end)];

while (1)
    % find the father of 1st point
    x1 = array_x(1);
    y1 = array_y(1);
    temp_x = father_x(y1,x1);
    temp_y = father_y(y1,x1);
    
    % check exit
    if temp_x == 0
        break;
    elseif isnan(temp_x)
        error("Error here");
    end
    
    % insert point at beginning
    array_x = [temp_x, array_x];
    array_y = [temp_y, array_y];
    array_value = [landscape(temp_y,temp_x), array_value];

end


% [~,maxloc] = findpeaks(array_value);

% set a middle point to seperate the things to two part
x_mid = 65;
for index = 1:length(array_x)
    if array_x(index)>x_mid
        break;
    end
end
i_mid = index-1;

if i_mid<3 % findpeaks is not useful
    [~,i_pitch_minimum] = min(array_value(1:i_mid));
else
    [~,minloc_p] = findpeaks(-array_value(1:i_mid));
    if array_value(1)<array_value(2) % 1st point is Pitch_minimum
        i_pitch_minimum = 1;
    elseif isempty(minloc_p)
        i_pitch_minimum = 1;
    else
        i_pitch_minimum = minloc_p(1);
    end
end

if length(array_value)-i_mid<3 % findpeaks is not useful
    [~,i_roll_minimum_m] = min(array_value(i_mid+1:end));
    i_roll_minimum = i_roll_minimum_m + i_mid;
else
    [~,minloc_r] = findpeaks(-array_value(i_mid+1:end));
    if array_value(end)<array_value(end-1) % last point is roll_minimum
        i_roll_minimum = length(array_value);
    elseif isempty(minloc_r)
        i_roll_minimum = length(array_value);
    else
        i_roll_minimum = minloc_r(end)+i_mid;
    end
end
[~,i_saddle_p] = max(array_value(i_pitch_minimum:i_roll_minimum)) ;
i_saddle = i_saddle_p+i_pitch_minimum-1;

if to_check == 1
    figure(2)
    plot(array_value);
    hold on;
    plot(i_pitch_minimum,array_value(i_pitch_minimum),'o','Color','b');
    plot(i_roll_minimum,array_value(i_roll_minimum),'o','Color','r');
    plot(i_saddle,array_value(i_saddle),'o','Color',[0.9294,0.6902,0.1294]);
    
    hold off;
    figure(3)
    surf(landscape(:,3:end))
end

output = struct();
output.saddle.x = array_x(i_saddle);
output.saddle.y = array_y(i_saddle);
output.saddle.value = array_value(i_saddle);
output.roll_minimum.x = array_x(i_roll_minimum);
output.roll_minimum.y = array_y(i_roll_minimum);
output.roll_minimum.value = array_value(i_roll_minimum);
output.pitch_minimum.x = array_x(i_pitch_minimum);
output.pitch_minimum.y = array_y(i_pitch_minimum);
output.pitch_minimum.value = array_value(i_pitch_minimum);
output.path.x = array_x(i_pitch_minimum:i_roll_minimum);
output.path.y = array_y(i_pitch_minimum:i_roll_minimum);
end




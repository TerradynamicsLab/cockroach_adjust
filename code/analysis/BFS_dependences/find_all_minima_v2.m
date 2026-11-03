% Find_all_minima
% Given a landscape, find all local “minima” 
% landscape(y,x)
%
% v1: if the nearest 4 points are high
% v2: if increasing at 2 points in 4 directions


function [Xs,Ys,Zs] = find_all_minima_v2(landscape,is_X_loop,is_Y_loop)

% Size of the landscape
Y_length = size(landscape,1);
X_length = size(landscape,2);

% search direction
vector_x = [-1,1,0,0];
vector_y = [0,0,1,-1];

% Hash
is_minima_landscape = landscape*0+1;

% search each point
for x_i = 1:X_length
    for y_i = 1:Y_length
        % loop near 4 points
        for p_i = 1:4
            % check
            if is_minima_landscape(y_i,x_i) == 0
                continue;
            end
            % get next point coordinate and kill the one outside
            next_x = x_i + vector_x(p_i);
            next_y = y_i + vector_y(p_i);
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
            % hash 
            A = [landscape(y_i,x_i),y_i,x_i];
            B = [landscape(next_y,next_x),next_y,next_x];
            if compare_points(A,B) == 1
                is_minima_landscape(y_i,x_i) = 0;
%             elseif landscape(y_i,x_i)<landscape(next_y,next_x)
%                 is_minima_landscape(next_y,next_x) = 0;
            end
        end
        
        % out reach one more
        for p_i = 1:4
            % check
            if is_minima_landscape(y_i,x_i) == 0
                continue;
            end
            % get next point coordinate and kill the one outside
            next_x1 = x_i + vector_x(p_i);
            next_y1 = y_i + vector_y(p_i);
            next_x2 = x_i + vector_x(p_i)*2;
            next_y2 = y_i + vector_y(p_i)*2;
            if is_X_loop == 1
                next_x1 = mod(next_x1-1,X_length)+1;
                next_x2 = mod(next_x2-1,X_length)+1;
            elseif next_x2<1 || next_x2>X_length
                continue;
            end
            if is_Y_loop == 1
                next_y1 = mod(next_y1-1,Y_length)+1;
                next_y2 = mod(next_y2-1,Y_length)+1;
            elseif next_y2<1 || next_y2>Y_length
                continue;
            end
            % hash 
            A = landscape(next_y1,next_x1);
            B = landscape(next_y2,next_x2);
            if compare_points(A,B) == 1
                is_minima_landscape(y_i,x_i) = 0;
%             elseif landscape(y_i,x_i)<landscape(next_y,next_x)
%                 is_minima_landscape(next_y,next_x) = 0;
            end
        end
    end
end

% search for result
Xs = [];
Ys = [];
Zs = [];
for x_i = 1:X_length
    for y_i = 1:Y_length
        if is_minima_landscape(y_i,x_i) == 1
            Xs = [Xs,x_i];
            Ys = [Ys,y_i];
            Zs = [Zs,landscape(y_i,x_i)];
        end
    end
end

% sort according to Zs
[~, order] = sort(Zs);
Xs = Xs(:,order);
Ys = Ys(:,order);
Zs = Zs(:,order);

end
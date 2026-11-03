% select_minima_coarse.m
% Yaqing created this on 11/5/2020
% input:
%   landscape(y,x)  n*m
% output:
%   xPitch          1*1
%   yPitch          1*1
%   xRoll           1*1
%   yRoll           1*1

function [xPitch1,yPitch1,xPitch2,yPitch2,xRoll,yRoll] = select_minima_coarse(landscape)
% Size of the landscape
Y_length = size(landscape,1);
X_length = size(landscape,2);

yPitch0 = 90/180*(Y_length-1)+1;
xroll90 = (90+180)/360*(X_length-1)+1;
xroll0 = 180/360*(X_length-1)+1;

% find all minima
[mini_Xs,mini_Ys,~] = find_all_minima(landscape,1,1);
mini_num = length(mini_Xs);

% find pitch minimum
xPitch1 = xroll0;
yPitch1 = 1;
for i = 1:mini_num
    if mini_Xs(i) ~= xroll0
        continue;
    end
    if mini_Ys(i) > yPitch0
        continue;
    end
    if mini_Ys(i) > yPitch1
        yPitch1 = mini_Ys(i);
    end
end

% find pitch minimum
xPitch2 = xroll0;
for yPitch2 = yPitch0-5:-1:2
    if landscape(yPitch2-1,xPitch2) > landscape(yPitch2,xPitch2)
        break;
    end
end

% find roll minimum
xRoll = xroll90;
yRoll = yPitch0;
thr = 50;
v = landscape(yRoll,xRoll);
for i = 1:mini_num
    th = (mini_Xs(i) - xroll90)^2 + (mini_Ys(i) - yPitch0)^2;
    if th < thr
        value = landscape(mini_Ys(i),mini_Xs(i));
        if value < v
            xRoll = mini_Xs(i);
            yRoll = mini_Ys(i);
            v = value;
            
        end
%         disp(value)
    end
%     disp(th)
end
end
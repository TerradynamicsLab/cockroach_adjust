function [Px,Py,Rx,Ry,routeXYZ,i_S] = route2P_R_S(routeXYZ)
routeX = routeXYZ(1,:);
routeZ = routeXYZ(3,:);
% find saddle
[~,i_S] = max(routeZ);
% find pitch minimum
i_P = 1;
for index = 1:i_S-1
    if routeZ(index) < routeZ(index+1)
        i_P = index;
        break;
    elseif routeX(index) ~= routeX(index+1)
        break;
    end
end
Px = routeXYZ(1,i_P);
Py = routeXYZ(2,i_P);

% find roll minimum
i_R = length(routeZ);
for index = length(routeZ):-1:i_S+1
    if routeZ(index) < routeZ(index-1)
        i_R = index;
        break;
    end
end

Rx = routeXYZ(1,i_R);
Ry = routeXYZ(2,i_R);

routeXYZ = routeXYZ(:,i_P:i_R);
i_S = i_S-i_P+1;
end
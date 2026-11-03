% Yaqing created this on 09/17/2019 to calculate dlt.
% The stucture of input is as follows:
% input:
% x 1*1
% y 1*1
% z 1*1
% L 1*11 or 11*1
% output:
% u 1*1
% v 1*1
function [u,v] = dlt_xyz2uv(x,y,z,L)
if length(L)==11
    u = (L(1)*x+L(2)*y+L(3)*z+L(4))/(L(9)*x+L(10)*y+L(11)*z+1);
    v = (L(5)*x+L(6)*y+L(7)*z+L(8))/(L(9)*x+L(10)*y+L(11)*z+1);
else
    error("L should be 11-D");
end
end
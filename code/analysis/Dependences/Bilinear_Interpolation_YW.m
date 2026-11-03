% Yaqing created this to do Bilinear_Interpolation in a landscape
% input:
% f  2*2 f00 f10
%        f01 f11
% x  1*1 0<=x<=1
% y  1*1 0<=y<=1
% output:
% z 1*1


function z = Bilinear_Interpolation_YW(f,x,y)
f = reshape(f,[4,1]);
A = [1-x-y+x*y,y*(1-x),x*(1-y),x*y];
z = A*f;
end
% Yaqing created this to do Bilinear_Interpolation in a landscape
% input:
% f  m*n
% x  1*1 0<=x<=n
% output:
% z 1*1

function z = Bilinear_Interpolation_whole_landscape_2D_line_YW(f,x)
m = size(f,1);
n = size(f,2);
if n<x || x<0
    z = NaN(m,1);
    return;
end
% check if x is a whole number
if rem(x,1)==0
    z = f(:,x);
else
    x_h = ceil(x);
    x_l = floor(x);
    z = f(:,x_h)*(x-x_l)+f(:,x_l)*(x_h-x);
end

end

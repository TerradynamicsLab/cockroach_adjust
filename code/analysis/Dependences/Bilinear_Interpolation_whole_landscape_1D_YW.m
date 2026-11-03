% Yaqing created this to do Bilinear_Interpolation in a landscape
% input:
% f  1*n or n*1
% x  1*1 0<=x<=n
% output:
% z 1*1

function z = Bilinear_Interpolation_whole_landscape_1D_YW(f,x)
n = length(f);
if n<x || x<0
    z = NaN;
    return;
end
% check if x is a whole number
if rem(x,1)==0
    z = f(x);
else
    x_h = ceil(x);
    x_l = floor(x);
    z = f(x_h)*(x-x_l)+f(x_l)*(x_h-x);
end

end

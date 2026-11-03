% Yaqing created this to do Bilinear_Interpolation in a landscape
% input:
% f  m*n f00 f10
%        f01 f11
% x  1*1 0<=x<=n
% y  1*1 0<=y<=m
% output:
% z 1*1

function z = Bilinear_Interpolation_whole_landscape_YW(f,x,y)
size_f = size(f);
if size_f(2)<x || x<0 || size_f(1)<y || y<0
    z = NaN;
    return;
end
% check if x is a whole number
if rem(x,1)==0
    % check if y is a whole number
    if rem(y,1)==0
        % both x and y are whole numbers
        z = f(y,x);
    else 
        % only x is whole number
        y_h = ceil(y);
        y_l = floor(y);
        z = f(y_h,x)*(y-y_l)+f(y_l,x)*(y_h-y);
    end
else
    % check if y is a whole number
    if rem(y,1)==0
        % only y is whole number
        x_h = ceil(x);
        x_l = floor(x);
        z = f(y,x_h)*(x-x_l)+f(y,x_l)*(x_h-x);
    else
        % none of x or y is a whole number
        x_h = ceil(x);
        x_l = floor(x);
        y_h = ceil(y);
        y_l = floor(y);
        z = Bilinear_Interpolation_YW(f(y_l:y_h,x_l:x_h),x-x_l,y-y_l);
    end
end
end

% Yaqing created this to calculate screw

function [theta,omega,q,h] = calculate_screw(GorR,varargin)
% check input as a G(4*4) or a R(3*3) + P(3*1)
if size(GorR) == [4,4]
    R = GorR(1:3,1:3);
    P = GorR(1:3,4);
else
    R = GorR;
    P = varargin{1};
end

% calculate theta and omega using R
theta = acos((trace(R)-1)/2);
omega = [R(3,2)-R(2,3);R(1,3)-R(3,1);R(2,1)-R(1,2)]/(2*sin(theta));

% calculate vector_v using P
omega_hat = [cross(omega,[1;0;0]),cross(omega,[0;1;0]),cross(omega,[0;0;1])];
temp_coif = diag([1,1,1])*theta + (1-cos(theta))*omega_hat + (theta-sin(theta))*(omega_hat*omega_hat);
vector_v = temp_coif\P;

% calculate h, q0, q
h = omega'*vector_v;
q0 = cross(omega,vector_v);
q = q0+omega*((0-q0(2))/omega(2));

end
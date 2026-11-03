% Yaqing adapted a former code from Ratan to create this.
% input:
% ellip
%     dia 1*3
%     com 1*3
%     eul 1*3
% output:
% possible_angles_left 1*202
% possible_angles_right 1*202

function [possible_angles_left,possible_angles_right] = calculate_ellip_tangent_angle(ellip)
ellip.R = eul2rotm(ellip.eul);
ellip.A = diag(1./ellip.dia).*diag(1./ellip.dia);
ellip.M = ellip.R*ellip.A*ellip.R';
beam_width = 10;
beam_gap = 10;

%% left beam
y_sec = (0:0.1:beam_width)+beam_gap/2;

% stage 1 assigments
stg1.v = ellip.com' - [zeros(size(y_sec)); y_sec; zeros(size(y_sec));  ] ;
stg1.M = ellip.M;
stg1.a = stg1.M(1,1);
stg1.b = stg1.M(3,3);
stg1.c = 2*stg1.M(1,3);
stg1.d = -2*stg1.M(1,:)*stg1.v;
stg1.e = -2*stg1.M(3,:)*stg1.v;
stg1.f = dot(stg1.v,ellip.M*stg1.v) - 1;

% stage 2 assigments -- find the tangent slopes for the section
a =   stg1.e.*stg1.e - 4*stg1.f*stg1.b;
b = 2*stg1.e.*stg1.d - 4*stg1.f*stg1.c;
c =   stg1.d.*stg1.d - 4*stg1.f*stg1.a;

% solve quadratic for slope
m1 = (-b + sqrt(b.*b-4*a.*c))./(2*a);
m2 = (-b - sqrt(b.*b-4*a.*c))./(2*a);
m1(imag(m1) ~=0) = nan;
m2(imag(m2) ~=0) = nan;

% find the contact point
p1 = stg1.b.*m1.*m1 + stg1.c.*m1 + stg1.a;
q1 = m1.*stg1.e + stg1.d;
x1 = -q1./(2*p1);
p2 = stg1.b.*m2.*m2 + stg1.c.*m2 + stg1.a;
q2 = m2.*stg1.e + stg1.d;
x2 = -q2./(2*p2);
x = [x1 x2];
y = [x1.*m1 x2.*m2];

% find the angles
possible_angles_left = atan2(x,y);


%% right beam
y_sec = (0:-0.1:-beam_width)-beam_gap/2;

% stage 1 assigments
stg1.v = ellip.com' - [zeros(size(y_sec)); y_sec; zeros(size(y_sec));  ] ;
stg1.M = ellip.M;
stg1.a = stg1.M(1,1);
stg1.b = stg1.M(3,3);
stg1.c = 2*stg1.M(1,3);
stg1.d = -2*stg1.M(1,:)*stg1.v;
stg1.e = -2*stg1.M(3,:)*stg1.v;
stg1.f = dot(stg1.v,ellip.M*stg1.v) - 1;

% stage 2 assigments -- find the tangent slopes for the section
a =   stg1.e.*stg1.e - 4*stg1.f*stg1.b;
b = 2*stg1.e.*stg1.d - 4*stg1.f*stg1.c;
c =   stg1.d.*stg1.d - 4*stg1.f*stg1.a;

% solve quadratic for slope
m1 = (-b + sqrt(b.*b-4*a.*c))./(2*a);
m2 = (-b - sqrt(b.*b-4*a.*c))./(2*a);
m1(imag(m1) ~=0) = nan;
m2(imag(m2) ~=0) = nan;

% find the contact point
p1 = stg1.b.*m1.*m1 + stg1.c.*m1 + stg1.a;
q1 = m1.*stg1.e + stg1.d;
x1 = -q1./(2*p1);
p2 = stg1.b.*m2.*m2 + stg1.c.*m2 + stg1.a;
q2 = m2.*stg1.e + stg1.d;
x2 = -q2./(2*p2);
x = [x1 x2];
y = [x1.*m1 x2.*m2];

% find the angles
possible_angles_right = atan2(x,y);
end
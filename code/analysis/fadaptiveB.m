function [out1,out2,out3]=fadaptiveB(in,fs,f1,f2,iter)
% out1: filtered signal
% out2: estimated velocity
% out3: estimated acceleration
% in: signal to be filtered (row vector)
% fs: sampling frequency (Hz)
% f1: lower cut-off frequency (Hz)
% f1+f2: upper cut-off frequency (Hz)
% iter: # of iterations
[padded,half]=pad(in); % padding
y=regular(padded,fs,(f1+f2)); % prefiltering
for k=1:iter
    [vel,acc]=differ(y,fs); % differentiation
    vel=abs(vel/max(abs(vel(half+1:half+length(in)))));
    acc=abs(acc/max(abs(acc(half+1:half+length(in)))));
    cri=vel+acc; cri=cri/max(cri); % criterion
    fc=f1+cri*f2; % cut-off frequencies
    ffc=adaptive(fc,fs,fc); % adaptive filtering of cut-off frequencies
    y=adaptive(padded,fs,ffc); % adaptive filtering
    y=regular(y,fs,max(ffc)); % postfiltering
end
[yy,yyy]=differ(y,fs); % differentiation
out1=y(half+1:half+length(in)); % extraction of region of interest
out2=yy(half+1:half+length(in)); % extraction of region of interest
out3=yyy(half+1:half+length(in)); % extraction of region of interest
% subfunctions_____________________________________________________________
function [out1,out2]=pad(in)
lng=length(in);
a=in(1:floor(lng/2)); % split into two
b=in(floor(lng/2)+1:lng);
a=-a(length(a):-1:1)+2*in(1); % reflect & invert
b=-b(length(b):-1:1)+2*in(lng);
out1=[a(1:end-1);in;b(2:end)];
out2=length(a(1:end-1));
function out=regular(in,fs,fc)
lng=length(in);
f=fc/((2^(1/2)-1)^0.25);
w=tan(pi*f/fs);
K1=2^0.5*w;
K2=w^2;
a=K2/(1+K1+K2);
b1=2*a*(1/K2-1);
b2=1-(4*a+b1);
x=zeros(1,lng); x(1)=in(1); x(2)=in(2);
for k=3:lng
    x(k)=a*(in(k)+2*in(k-1)+in(k-2))+b1*x(k-1)+b2*x(k-2);
end
y=zeros(1,lng); y(lng)=x(lng); y(lng-1)=x(lng-1);
for k=lng-2:-1:1
    y(k)=a*(x(k)+2*x(k+1)+x(k+2))+b1*y(k+1)+b2*y(k+2);
end
out=y;
function out=adaptive(in,fs,fc)
lng=length(in);
f=zeros(1,lng); w=zeros(1,lng); K1=zeros(1,lng); K2=zeros(1,lng);
a=zeros(1,lng); b1=zeros(1,lng); b2=zeros(1,lng);
for i=1:lng
    f(i)=fc(i)/((2^(1/2)-1)^0.25);
    w(i)=tan(pi*f(i)/fs);
    K1(i)=2^0.5*w(i);
    K2(i)=w(i)^2;
    a(i)=K2(i)/(1+K1(i)+K2(i));
    b1(i)=2*a(i)*(1/K2(i)-1);
    b2(i)=1-(4*a(i)+b1(i));
end
x=zeros(1,lng); x(1)=in(1); x(2)=in(2);
for k=3:lng
    x(k)=a(k)*(in(k)+2*in(k-1)+in(k-2))+b1(k)*x(k-1)+b2(k)*x(k-2);
end
y=zeros(1,lng); y(lng)=x(lng); y(lng-1)=x(lng-1);
for k=lng-2:-1:1
    y(k)=a(k)*(x(k)+2*x(k+1)+x(k+2))+b1(k)*y(k+1)+b2(k)*y(k+2);
end
out=y;
function [out1,out2]=differ(in,fs)
lng=length(in);
out1=zeros(1,lng); out2=zeros(1,lng);
for i=3:lng-2
    out1(i)=(-in(i+2)+8*in(i+1)-8*in(i-1)+in(i-2))/(12/fs);
    out2(i)=(-in(i+2)+16*in(i+1)-30*in(i)+16*in(i-1)-in(i-2))/(12/fs^2);
end
% Yaqing created this on 11/05/2018 to do reconstruction on tracking
% points

function [x,y,z,res] = fReconstruction(Cal,Us,Vs)
    CamNum = length(Us);
    if length(Vs)~=CamNum
        error('u and v should be in the same length!');
    end
    if length(Cal(1,:))~=CamNum
        error('Calibration File Wrong in length!');
    end
    ValidNum = 0;
    A=[];%Matrix
    B=[];%Matrix
    for i = 1:CamNum
        if isnan(Us(i))
            continue;
        end
        if isnan(Vs(i))
            continue;
        end
        ValidNum = ValidNum+1;
        A=[A; Cal(9,i)*Us(i)-Cal(1,i), Cal(10,i)*Us(i)-Cal(2,i), Cal(11,i)*Us(i)-Cal(3,i)];
        B=[B; Cal(4,i)-Us(i)];
        A=[A; Cal(9,i)*Vs(i)-Cal(5,i), Cal(10,i)*Vs(i)-Cal(6,i), Cal(11,i)*Vs(i)-Cal(7,i)];
        B=[B; Cal(8,i)-Vs(i)];
    end
    if  ValidNum<=1
        x=NaN;
        y=NaN;
        z=NaN;
    else
        ans = pinv(A)*B;
        x = ans(1);
        y = ans(2);
        z = ans(3);
    end
    s = 0;
    num = 0;
    
    for i = 1:CamNum
        if isnan(Us(i))
            continue;
        end
        if isnan(Vs(i))
            continue;
        end
        UV = fDLT3D22D(Cal(:,i),[x;y;z]);
        s = s+((UV(1)-Us(i))^2+(UV(2)-Vs(i))^2);
        num = num+1;
    end
    res = sqrt(s/(num*2-3));
end
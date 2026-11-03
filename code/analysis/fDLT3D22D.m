%%% convert 3D to 2D using DLT method
function UV = fDLT3D22D(Cal,XYZ)
    L1 = Cal(1);
    L2 = Cal(2);
    L3 = Cal(3);
    L4 = Cal(4);
    L5 = Cal(5);
    L6 = Cal(6);
    L7 = Cal(7);
    L8 = Cal(8);
    L9 = Cal(9);
    L10 = Cal(10);
    L11 = Cal(11);
    x = XYZ(1);
    y = XYZ(2);
    z = XYZ(3);
    u = (L1*x+L2*y+L3*z+L4)/(L9*x+L10*y+L11*z+1);
    v = (L5*x+L6*y+L7*z+L8)/(L9*x+L10*y+L11*z+1);
    UV = [u,v];
end
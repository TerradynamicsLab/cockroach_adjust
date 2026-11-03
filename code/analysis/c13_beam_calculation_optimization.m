% Yaqing have this on 7/14/2020 to see best beam angle
clear; close; clc;


x0 = [1,1,1,1,1,1,1,1,1];
x_l = x0*0.8;
x_u = x0*1.2;
% enter the trial NO
Trial_series = 2%1:36;


% x1  =  [0.9657,0.9079,0.8231,0.7935,1.8605,0.2789,1.1330,0.5832,0.6833];
% x1 = [1.0173,1.0481,0.7145,0.7103,1.2686,1.2967,1.0916,0.7001,0.7357];
options = optimset('PlotFcns',@optimplotfval);

for Trial_NO = Trial_series

x1 = fminsearch(@(x)c13_beam_calculation_optimization_function(Trial_NO,x),x0,options);
% x1 = fminsearchbnd(@(x)c13_beam_calculation_optimization_function(Trial_NO,x),x0,x_l,x_u);
disp(Trial_NO);
disp(x1);
disp(c13_beam_calculation_optimization_function(Trial_NO,x1));

end


%% result
% Trial 1: 1.0330,0.9935,0.7494,0.7210,1.0968,1.0527,0.8765,0.6720,1.3574





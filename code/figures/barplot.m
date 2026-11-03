%%% Yaqing created this function to create bar plot
% 4/23/2021
% hey, it has been two years
% be strong and couraged

clear; close all; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% load superbar function
addpath(genpath([REPO,'/code/analysis/Dependences/scottclowe-superbar-ce333a9']));

% load database
load([REPO,'/data/kinematics/DataBase.mat']);


TrialNum = 36;

% calculate leg sprawl
for trial_i = 1:TrialNum
    for frame_i = 1:DataBase.Trial(trial_i).Info.FrameNum
        a = [DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,1:2),0];
        b = [DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,1:2),0];
        LegSprawl(trial_i).data(frame_i) = atan2(norm(cross(a,b)), dot(a,b));
    end
end

% datas
for trial_i = 1:TrialNum
    % frames
    frame_app = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame;
    frame_expPit = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;
    frame_rol = DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.RollMaxFrame;
    frame_dep = DataBase.Trial(trial_i).Info.LandFrame:DataBase.Trial(trial_i).Info.LeaveFrame;
    
    % data - approach
    data_BR_app = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_app,3)*180/pi;
    data_BP_app = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_app,2)*180/pi;
    data_HF_app = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_app,2)*180/pi;
    data_AF_app = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_app,2)*180/pi;
    data_LH_app = -DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_app,3)+DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_app,3);
    data_LS_app = LegSprawl(trial_i).data(frame_app)*180/pi;
    
    % data - explore + pitch
    data_BR_expPit = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_expPit,3)*180/pi;
    data_BP_expPit = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_expPit,2)*180/pi;
    data_HF_expPit = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_expPit,2)*180/pi;
    data_AF_expPit = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_expPit,2)*180/pi;
    data_LH_expPit = -DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_expPit,3)+DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_expPit,3);
    data_LS_expPit = LegSprawl(trial_i).data(frame_expPit)*180/pi;
    
    % data - roll
    data_BR_rol = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_rol,3)*180/pi;
    data_BP_rol = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_rol,2)*180/pi;
    data_HF_rol = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_rol,2)*180/pi;
    data_AF_rol = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_rol,2)*180/pi;
    data_LH_rol = -DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_rol,3)+DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_rol,3);
    data_LS_rol = LegSprawl(trial_i).data(frame_rol)*180/pi;
    
    % data - depart
    data_BR_dep = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_dep,3)*180/pi;
    data_BP_dep = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_dep,2)*180/pi;
    data_HF_dep = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_dep,2)*180/pi;
    data_AF_dep = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_dep,2)*180/pi;
    data_LH_dep = -DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_dep,3)+DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_dep,3);
    data_LS_dep = LegSprawl(trial_i).data(frame_dep)*180/pi;
    
    % save interested variables
    mean_BR_app(trial_i) = nanmean(data_BR_app);
    mean_BP_app(trial_i) = nanmean(data_BP_app);
    mean_HF_app(trial_i) = nanmean(data_HF_app);
    mean_AF_app(trial_i) = nanmean(data_AF_app);
    mean_LH_app(trial_i) = nanmean(data_LH_app);
    mean_LS_app(trial_i) = nanmean(data_LS_app);
    mean_BR_expPit(trial_i) = nanmean(data_BR_expPit);
    mean_BP_expPit(trial_i) = nanmean(data_BP_expPit);
    mean_HF_expPit(trial_i) = nanmean(data_HF_expPit);
    mean_AF_expPit(trial_i) = nanmean(data_AF_expPit);
    mean_LH_expPit(trial_i) = nanmean(data_LH_expPit);
    mean_LS_expPit(trial_i) = nanmean(data_LS_expPit);
    mean_BR_rol(trial_i) = nanmean(data_BR_rol);
    mean_BP_rol(trial_i) = nanmean(data_BP_rol);
    mean_HF_rol(trial_i) = nanmean(data_HF_rol);
    mean_AF_rol(trial_i) = nanmean(data_AF_rol);
    mean_LH_rol(trial_i) = nanmean(data_LH_rol);
    mean_LS_rol(trial_i) = nanmean(data_LS_rol);
    mean_BR_dep(trial_i) = nanmean(data_BR_dep);
    mean_BP_dep(trial_i) = nanmean(data_BP_dep);
    mean_HF_dep(trial_i) = nanmean(data_HF_dep);
    mean_AF_dep(trial_i) = nanmean(data_AF_dep);
    mean_LH_dep(trial_i) = nanmean(data_LH_dep);
    mean_LS_dep(trial_i) = nanmean(data_LS_dep);
    
    std_HF_app(trial_i) = nanstd(data_HF_app);
    std_HF_expPit(trial_i) = nanstd(data_HF_expPit);
    std_HF_rol(trial_i) = nanstd(data_HF_rol);
    std_HF_dep(trial_i) = nanstd(data_HF_dep);

    std_AF_app(trial_i) = nanstd(data_AF_app);
    std_AF_expPit(trial_i) = nanstd(data_AF_expPit);
    std_AF_rol(trial_i) = nanstd(data_AF_rol);
    std_AF_dep(trial_i) = nanstd(data_AF_dep);
end

% statistics data prepare
for trial_i = 1:TrialNum
    animal(trial_i) = DataBase.Trial(trial_i).Info.AnimalNum;
end
stat_data = [(1:36)',animal',...
    mean_BR_app', mean_BR_expPit', mean_BR_rol', mean_BR_dep',...
    mean_BP_app', mean_BP_expPit', mean_BP_rol', mean_BP_dep',...
    std_HF_app', std_HF_expPit', std_HF_rol', std_HF_dep',...
    std_AF_app', std_AF_expPit', std_AF_rol', std_AF_dep',...%     mean_AF_app', mean_AF_expPit', mean_AF_rol', mean_AF_dep',...
    mean_LH_app', mean_LH_expPit', mean_LH_rol', mean_LH_dep',...
    mean_LS_app', mean_LS_expPit', mean_LS_rol', mean_LS_dep'];
writematrix(stat_data,'stat_data.csv');

% bar plot data prepare
BR.av = nanmean([mean_BR_app', mean_BR_expPit', mean_BR_rol', mean_BR_dep']);
BP.av = nanmean([mean_BP_app', mean_BP_expPit', mean_BP_rol', mean_BP_dep']);
HF.av = nanmean([std_HF_app', std_HF_expPit', std_HF_rol', std_HF_dep']);
AF.av = nanmean([std_AF_app', std_AF_expPit', std_AF_rol', std_AF_dep']);
% AF.av = nanmean([mean_AF_app', mean_AF_expPit', mean_AF_rol', mean_AF_dep']);
LH.av = nanmean([mean_LH_app', mean_LH_expPit', mean_LH_rol', mean_LH_dep']);
LS.av = nanmean([mean_LS_app', mean_LS_expPit', mean_LS_rol', mean_LS_dep']);

BR.sd = nanstd([mean_BR_app', mean_BR_expPit', mean_BR_rol', mean_BR_dep']);
BP.sd = nanstd([mean_BP_app', mean_BP_expPit', mean_BP_rol', mean_BP_dep']);
HF.sd = nanstd([std_HF_app', std_HF_expPit', std_HF_rol', std_HF_dep']);
AF.sd = nanstd([std_AF_app', std_AF_expPit', std_AF_rol', std_AF_dep']);
% AF.sd = nanstd([mean_AF_app', mean_AF_expPit', mean_AF_rol', mean_AF_dep']);
LH.sd = nanstd([mean_LH_app', mean_LH_expPit', mean_LH_rol', mean_LH_dep']);
LS.sd = nanstd([mean_LS_app', mean_LS_expPit', mean_LS_rol', mean_LS_dep']);

% plot
C = [0.6510    0.6510    0.6510;
    0,0,1;
    1,0,0;
    0.49,0.18,0.56];

C(1,:) = [0.1490    0.6588    0.0196];

%%% BR
Y = BR.av; %
E = BR.sd; %
f = figure(7); %
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22);
superbar(Y, 'E', E, 'BarEdgeColor', permute(C, [1 2 3]), 'BarFaceColor', 'none','ErrorbarLineWidth',1,'ErrorbarRelativeWidth',0.3);
set( gca, 'XTickLabel', {''} )
xlim([0.5 4.5])
ylim([-20 80]); %
box on;

%%% BP
Y = BP.av; %
E = BP.sd; %
f = figure(8); %
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22);
superbar(Y, 'E', E, 'BarEdgeColor', permute(C, [1 2 3]), 'BarFaceColor', 'none','ErrorbarLineWidth',1,'ErrorbarRelativeWidth',0.3);
set( gca, 'XTickLabel', {''} )
xlim([0.5 4.5])
ylim([-5 30]); %
box on;

%%% HF
Y = HF.av; %
E = HF.sd; %
f = figure(9); %
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22);
superbar(Y, 'E', E, 'BarEdgeColor', permute(C, [1 2 3]), 'BarFaceColor', 'none','ErrorbarLineWidth',1,'ErrorbarRelativeWidth',0.3);
set( gca, 'XTickLabel', {''} )
xlim([0.5 4.5])
ylim([-2 15]); %
box on;

%%% AF
Y = AF.av; %
E = AF.sd; %
f = figure(10); %
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22);
superbar(Y, 'E', E, 'BarEdgeColor', permute(C, [1 2 3]), 'BarFaceColor', 'none','ErrorbarLineWidth',1,'ErrorbarRelativeWidth',0.3);
set( gca, 'XTickLabel', {''} )
xlim([0.5 4.5])
ylim([-1 11]); % ylim([-2 30]); 
box on;

%%% LS
Y = LS.av; %
E = LS.sd; %
f = figure(11); %
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22);
superbar(Y, 'E', E, 'BarEdgeColor', permute(C, [1 2 3]), 'BarFaceColor', 'none','ErrorbarLineWidth',1,'ErrorbarRelativeWidth',0.3);
set( gca, 'XTickLabel', {''} )
xlim([0.5 4.5])
ylim([60 160]); %
box on;

%%% LH
Y = LH.av; %
E = LH.sd; %
f = figure(12); %
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22);
superbar(Y, 'E', E, 'BarEdgeColor', permute(C, [1 2 3]), 'BarFaceColor', 'none','ErrorbarLineWidth',1,'ErrorbarRelativeWidth',0.3);
set( gca, 'XTickLabel', {''} )
xlim([0.5 4.5])
ylim([-5 20]); %
box on;


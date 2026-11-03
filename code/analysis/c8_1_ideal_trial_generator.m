% Yaqing created this on 9/27/2020 to create trial 37, the idea trial
% head and abdomen fixed
% x = -16:0.2:43
% head angle = 15°
% abdomen angle = -7°

clear;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
clc;
is_re = 0;

if is_re == 1
    save_file = [REPO,'/data/kinematics/DataBase_re.mat'];
else
    save_file = [REPO,'/data/kinematics/DataBase.mat'];
end

load(save_file);

% Info
DataBase.Trial(37).Info.NameSuffix = '';
DataBase.Trial(37).Info.AnimalNum = 2;
DataBase.Trial(37).Info.FrameNum = 296;
DataBase.Trial(37).Info.RollDirection = 1;
DataBase.Trial(37).Info.Gap = 1;
DataBase.Trial(37).Info.EnterFrame = 1;
DataBase.Trial(37).Info.TouchFrame = 10;
DataBase.Trial(37).Info.LeaveFrame = 296;
DataBase.Trial(37).Info.LandFrame = 296;
DataBase.Trial(37).Info.RollStartFrame = 296;
DataBase.Trial(37).Info.RollMaxFrame = 296;
DataBase.Trial(37).Info.RollEndFrame = 296;
DataBase.Trial(37).Info.Roll60inFrame = 296;
DataBase.Trial(37).Info.Roll60outFrame = 296;

% raw
DataBase.Trial(37).raw = struct();

% modified
DataBase.Trial(37).modified.Cockroach.Body.com = ones(DataBase.Trial(37).Info.FrameNum,3).*[0,0,4];
DataBase.Trial(37).modified.Cockroach.Body.com(:,1) = (-26:0.2:33)';
DataBase.Trial(37).modified.Cockroach.Body.eul = zeros(DataBase.Trial(37).Info.FrameNum,3);
DataBase.Trial(37).modified.Cockroach.Head.com = DataBase.Trial(37).modified.Cockroach.Body.com;
DataBase.Trial(37).modified.Cockroach.Head.eul = ones(DataBase.Trial(37).Info.FrameNum,3).*[0,45*pi/180,0];
DataBase.Trial(37).modified.Cockroach.Head.eul_b = DataBase.Trial(37).modified.Cockroach.Head.eul;
DataBase.Trial(37).modified.Cockroach.Abdomen_Up.eul = ones(DataBase.Trial(37).Info.FrameNum,3).*[0,-7*pi/180,0];
DataBase.Trial(37).modified.Cockroach.Abdomen_Up.eul_b = DataBase.Trial(37).modified.Cockroach.Abdomen_Up.eul;
DataBase.Trial(37).modified.Cockroach.Abdomen_Down.eul = zeros(DataBase.Trial(37).Info.FrameNum,3);
DataBase.Trial(37).modified.Cockroach.Abdomen_Down.eul_u = zeros(DataBase.Trial(37).Info.FrameNum,3);
DataBase.Trial(37).modified.Cockroach.Beam.left_pitch = zeros(DataBase.Trial(37).Info.FrameNum,1);
DataBase.Trial(37).modified.Cockroach.Beam.right_pitch = zeros(DataBase.Trial(37).Info.FrameNum,1);

% save
save(save_file,'DataBase');

REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
% The basic idea is, based on the body.STL, which is the model of the
% average cockroach, and head.STL, which belongs the average cockroach too, generate
% different stl.m according to the different body diameter.
cd([REPO,'/data/cockroach_model/f2_SW_model_V1_re/']);

load([REPO,'/data/kinematics/DataBase.mat']);

% addpath('D:\YW_cockroach_adjustment\cockroach_adjustment\Dependences');
load([REPO,'/data/kinematics/DataBase.mat']);
model_path = [REPO,'/data/cockroach_model/f2_SW_model_V1_re/'];

cockroach_number = [2,3,4];

neck_point = [16,0,0.5]';
waist_point = [0,0,0]';

% load body_stl and head_stl for the 1st cockroach
load([model_path,'body.mat']);
load([model_path,'head.mat']);
load([model_path,'abdomen.mat']);

% % calculate cockroach's diameters
% cockroach_dia = struct();
Info_file = [REPO,'/data/info/Info.xlsx'];
[Info_Num,InfoText] = xlsread(Info_file,'Animal');

for cockroach_i = cockroach_number
    cockroach_dia(cockroach_i).total.mass = Info_Num(cockroach_i,2);
    InfoNum(cockroach_i,1:9) = Info_Num(cockroach_i,3:11);
    cockroach_dia(cockroach_i).total.length = InfoNum(cockroach_i,4);
    cockroach_dia(cockroach_i).total.thickness = InfoNum(cockroach_i,7);
    cockroach_dia(cockroach_i).body.length = InfoNum(cockroach_i,3);
    cockroach_dia(cockroach_i).body.width = InfoNum(cockroach_i,2);
    cockroach_dia(cockroach_i).head.length = InfoNum(cockroach_i,5);
    cockroach_dia(cockroach_i).head.width = InfoNum(cockroach_i,6);
    cockroach_dia(cockroach_i).head.thickness = InfoNum(cockroach_i,8);
    cockroach_dia(cockroach_i).abdomen.length = InfoNum(cockroach_i,4) - InfoNum(cockroach_i,5) - InfoNum(cockroach_i,3);
    cockroach_dia(cockroach_i).abdomen.width = InfoNum(cockroach_i,1);
end

% load standard cockroach dia
total_length = 10.17+14.5+27.5;
total_thickness = 7.2;
body_length = 14.5;
body_width = 27.48;
head_length = 10.17;
head_width = 16;
head_thinkness = 6.6;
abdomen_length = 27.5;
abdomen_width = 20.61;
mass_bias_b = 0;

% generate .stl using body length and wing width (for now)
cockroach_model = struct();
for cockroach_i = cockroach_number
    %%% dia (numbers)
    cockroach_model.dia(cockroach_i) = cockroach_dia(cockroach_i);
    cockroach_model.dia(cockroach_i).total.neck_point = neck_point.*cockroach_dia(cockroach_i).total.length./total_length;
    cockroach_model.dia(cockroach_i).total.waist_point = waist_point.*cockroach_dia(cockroach_i).total.length./total_length;
    cockroach_model.dia(cockroach_i).total.mass_bias_b = mass_bias_b.*cockroach_dia(cockroach_i).total.length./total_length;
    
    %%% body
    cockroach_model.body(cockroach_i).faces = body.faces;
    cockroach_model.body(cockroach_i).num_vertice = body.num_vertice;
    cockroach_model.body(cockroach_i).vertice_serial = body.vertice_serial;
    cockroach_model.body(cockroach_i).vertice_position = body.vertice_position ...
        .* [cockroach_dia(cockroach_i).body.length,cockroach_dia(cockroach_i).body.width,cockroach_dia(cockroach_i).total.thickness]...
        ./ [body_length,body_width,total_thickness];
    %%% head
    cockroach_model.head(cockroach_i).faces = head.faces;
    cockroach_model.head(cockroach_i).num_vertice = head.num_vertice;
    cockroach_model.head(cockroach_i).vertice_serial = head.vertice_serial;
    cockroach_model.head(cockroach_i).vertice_position = head.vertice_position ...
        .* [cockroach_dia(cockroach_i).head.length,cockroach_dia(cockroach_i).head.width,cockroach_dia(cockroach_i).head.thickness]...
        ./ [head_length,head_width,head_thinkness];
    %%% abdomen
    cockroach_model.abdomen(cockroach_i).faces = abdomen.faces;
    cockroach_model.abdomen(cockroach_i).num_vertice = abdomen.num_vertice;
    cockroach_model.abdomen(cockroach_i).vertice_serial = abdomen.vertice_serial;
    cockroach_model.abdomen(cockroach_i).vertice_position = abdomen.vertice_position ...
        .* [cockroach_dia(cockroach_i).abdomen.length,cockroach_dia(cockroach_i).abdomen.width,cockroach_dia(cockroach_i).total.thickness]...
        ./ [abdomen_length,abdomen_width,total_thickness];
    
end
save([model_path,'cockroach_model.mat'],'cockroach_model');
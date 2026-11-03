close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% set project name and folder
project = struct();
project.name = 'barrier_4';

% folders
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% trial
trial_i = 37;
disp(['Trial: ',num2str(trial_i)]);

% figure
figure(1);
hold on;
X = -24.2:0.2:33; 
colors = fire(40);

record = [];

for head_angle = 65:-5:-25 
    disp(['Head angle: ',num2str(head_angle)]);
    file_name = [project.folder,'basin_trial_',num2str(trial_i),'_head_angle_',num2str(head_angle),'.mat'];
    if isfile(file_name)
        load([project.folder,'basin_trial_',num2str(trial_i),'_head_angle_',num2str(head_angle),'.mat']);
        color_temp = colors(round((head_angle-(-25))/(65+25)*20)+10,:);
        plot(X,BFS_result.energy_barrier,'Color',color_temp,'LineWidth',1);
        record = [record;BFS_result.energy_barrier];
    end
    
end

grid on;
box on;
l = legend({'65°','60°','55°','50°','45°','40°','35°','30°','25°','20°','15°','10°','5°','0°','-5°','-10°','-15°','-20°','-25°'},'Location','eastoutside');

ref = record(10,:);
max_energy_saved = nan*ref;
for i_X = 1:287
    temp_max_reduction = -1;
    for i_head_angles = 1:18
        reduction = ref(i_X)-record(i_head_angles,i_X);
        if reduction>temp_max_reduction
            temp_max_reduction = reduction;
        end
    end
    max_energy_saved(i_X) = temp_max_reduction;
end

max_saved_ratio = max_energy_saved./ref;

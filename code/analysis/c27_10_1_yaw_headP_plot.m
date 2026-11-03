close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

project = struct();
project.name = 'barrier_5';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];


load([project.folder,'PE_c27_10.mat']);

head_angle_range = -25:5:65;
yaw_range = -90:5:90;
X_range = -24.2:0.2:33;

figure(1);
PE_sec = potential_energy(:,:,1);
colormap(fire)
[X,Y] = meshgrid(yaw_range,head_angle_range);
sh = surf(X,Y,PE_sec,'EdgeAlpha',0);
zlim([0,1.5]);
% caxis([0,1.5]);
view(-30,80);
% view(0,90);

for i_X = 1:287%1:length(X_range)
   PE_sec = potential_energy(:,:,i_X);
   sh.ZData = PE_sec;
   disp(X_range(i_X))
   saveas(gcf,[[REPO,'/output/Desktop/head_yaw_landscape/'],num2str(X_range(i_X),'%03.1f'),'.jpg'])
end

HA_Barrier = nan(length(X_range));
PE_Barrier_MAX = nan(length(X_range));
PE_Barrier_5 = nan(length(X_range));
PE_Barrier_30 = nan(length(X_range));
PE_Barrier_all= nan(length(X_range),length(head_angle_range));
for i_X = 1:length(X_range)
    max_barrier = 0;
    for i_HA = 1:length(head_angle_range)
        PE_profile_left = potential_energy(i_HA,1:((length(yaw_range)+1)/2),i_X);
        PE_Barrier_t = max(PE_profile_left);
        if PE_Barrier_t > max_barrier
            max_barrier = PE_Barrier_t;
            i_HA_Barrier = i_HA;
        end
        if head_angle_range(i_HA)==5
            PE_Barrier_5(i_X) = PE_Barrier_t;
        end
        if head_angle_range(i_HA)==40
            PE_Barrier_30(i_X) = PE_Barrier_t;
        end
        PE_Barrier_all(i_X,i_HA) = PE_Barrier_t;
    end
    PE_Barrier_MAX(i_X) = max_barrier;
    HA_Barrier(i_X) = head_angle_range(i_HA_Barrier);
end

figure(2);
hold on;
% plot(X_range,PE_Barrier_5-min(PE_Barrier_5),'b')
% plot(X_range,PE_Barrier_MAX-min(PE_Barrier_5),'r')
% plot(X_range,PE_Barrier_30-min(PE_Barrier_5),'Color',[0.9294    0.6941    0.1255])
% figure(3);
% plot(X_range,HA_Barrier,'b')

colors = load([REPO,'/code/figures/colormap_DIY.mat']);
for i_HA = length(head_angle_range):-1:1
    plot(X_range,PE_Barrier_all(:,i_HA),'Color',colors.colors(i_HA,:));
end

box on;
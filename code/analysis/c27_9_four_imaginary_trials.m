% function c27_9_four_imaginary_trials

% interactive code database collection code
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% is Chen's pc or not
is_Chen = 0;

% set project name and folder
project = struct();
project.name = 'barrier_5';
if is_Chen
    project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
else
    project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
end

video_folder = [REPO,'/output/Yaqing_landscape/video_20210712/'];

global ff steps potential_energy head_angle 
head_angle = 5;
load([project.folder,'interact_data.mat']);

% setup figures
ff.fh = figure(1);
set(gcf,'Position',[1 41 1680 800])
clf;

% sp 1, pitch vs roll, 
ff.sp(1) = subplot(3,4,1);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.pitch_steps(19:47));
ff.sh(1) = surf(X,Y,squeeze(potential_energy(1,1,1,(19:47),(37:73))), 'edgealpha',0);
view(0,90)
xlim([0,180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-90,50]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
xlabel('roll (°)');
ylabel('pitch (°)');
set(get(gca,'yaxis'),'direction','reverse');

% sp 2, pitch vs roll, 
ff.sp(2) = subplot(3,4,2);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.pitch_steps(19:47));
ff.sh(2) = surf(X,Y,squeeze(potential_energy(1,1,1,(19:47),(37:73))), 'edgealpha',0);
view(0,90)
xlim([0,180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-90,50]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
xlabel('roll (°)');
ylabel('pitch (°)');
set(get(gca,'yaxis'),'direction','reverse');

% sp 3, pitch vs roll, 
ff.sp(3) = subplot(3,4,3);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.pitch_steps(19:47));
ff.sh(3) = surf(X,Y,squeeze(potential_energy(1,1,1,(19:47),(37:73))), 'edgealpha',0);
view(0,90)
xlim([0,180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-90,50]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
xlabel('roll (°)');
ylabel('pitch (°)');
set(get(gca,'yaxis'),'direction','reverse');

% sp 4, pitch vs roll, 
ff.sp(4) = subplot(3,4,4);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.pitch_steps(19:47));
ff.sh(4) = surf(X,Y,squeeze(potential_energy(1,1,1,(19:47),(37:73))), 'edgealpha',0);
view(0,90)
xlim([0,180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-90,50]);       yticks([-4,-3,-2,-1,0,1,2,3,4]*45); yticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
xlabel('roll (°)');
ylabel('pitch (°)');
set(get(gca,'yaxis'),'direction','reverse');

% sp 5, yaw vs roll, 
ff.sp(5) = subplot(3,4,5);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.yaw_steps);
ff.sh(5) = surf(X,Y,squeeze(potential_energy(1,1,:,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-30, 30]);       yticks([-3,-2,-1,0,1,2,3,4]*15); yticklabels({[char(8211) '45'],[char(8211) '30'],[char(8211) '15'],'0','15','30','45','60'})
xlabel('roll (°)');
ylabel('yaw (°)');

% sp 6, yaw vs roll, 
ff.sp(6) = subplot(3,4,6);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.yaw_steps);
ff.sh(6) = surf(X,Y,squeeze(potential_energy(1,1,:,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-30, 30]);       yticks([-3,-2,-1,0,1,2,3,4]*15); yticklabels({[char(8211) '45'],[char(8211) '30'],[char(8211) '15'],'0','15','30','45','60'})
xlabel('roll (°)');
ylabel('yaw (°)');

% sp 7, yaw vs roll, 
ff.sp(7) = subplot(3,4,7);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.yaw_steps);
ff.sh(7) = surf(X,Y,squeeze(potential_energy(1,1,:,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-30, 30]);       yticks([-3,-2,-1,0,1,2,3,4]*15); yticklabels({[char(8211) '45'],[char(8211) '30'],[char(8211) '15'],'0','15','30','45','60'})
xlabel('roll (°)');
ylabel('yaw (°)');

% sp 8, yaw vs roll, 
ff.sp(8) = subplot(3,4,8);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.yaw_steps);
ff.sh(8) = surf(X,Y,squeeze(potential_energy(1,1,:,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-30, 30]);       yticks([-3,-2,-1,0,1,2,3,4]*15); yticklabels({[char(8211) '45'],[char(8211) '30'],[char(8211) '15'],'0','15','30','45','60'})
xlabel('roll (°)');
ylabel('yaw (°)');

% sp 9, y vs roll, 
ff.sp(9) = subplot(3,4,9);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.y_steps);
ff.sh(9) = surf(X,Y,squeeze(potential_energy(1,:,1,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-3, 3]);       yticks([-3,-2,-1,0,1,2,3,4]); yticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3','4'})
xlabel('roll (°)');
ylabel('y (mm)');

% sp 10, y vs roll, 
ff.sp(10) = subplot(3,4,10);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.y_steps);
ff.sh(10) = surf(X,Y,squeeze(potential_energy(1,:,1,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-3, 3]);       yticks([-3,-2,-1,0,1,2,3,4]); yticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3','4'})
xlabel('roll (°)');
ylabel('y (mm)');

% sp 11, y vs roll, 
ff.sp(11) = subplot(3,4,11);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.y_steps);
ff.sh(11) = surf(X,Y,squeeze(potential_energy(1,:,1,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-3, 3]);       yticks([-3,-2,-1,0,1,2,3,4]); yticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3','4'})
xlabel('roll (°)');
ylabel('y (mm)');

% sp 12, y vs roll, 
ff.sp(12) = subplot(3,4,12);
hold on; box on; set(gca,'fontsize',15,'boxstyle','full')
colormap(fire)
[X,Y] = meshgrid(steps.roll_steps(37:73), steps.y_steps);
ff.sh(12) = surf(X,Y,squeeze(potential_energy(1,:,1,1,(37:73))), 'edgealpha',0);
view(0,90)
xlim([0, 180]);       xticks([-4,-3,-2,-1,0,1,2,3,4]*45); xticklabels({[char(8211) '180'],[char(8211) '135'],[char(8211) '90'],[char(8211) '45'],'0','45','90','135','180'})
ylim([-3, 3]);       yticks([-3,-2,-1,0,1,2,3,4]); yticklabels({[char(8211) '3'],[char(8211) '2'],[char(8211) '1'],'0','1','2','3','4'})
xlabel('roll (°)');
ylabel('y (mm)');

txt = {'X = + 0.0'};
ff.sgt = sgtitle(txt);

for i_x_step = 99:142
    % title to show X
    X = steps.x_steps(i_x_step);
    if X < 0
        txt = ['X = ',char(8211), num2str(-X,'%.1f')];
    else
        txt = ['X = ','+', num2str(X,'%.1f')];
    end
    ff.sgt.String = txt;
    
    % first trial: Always y = 0, yaw = 0
    ff.sh(1).ZData = squeeze(potential_energy(i_x_step,4,4,(19:47),(37:73)));
    ff.sh(5).ZData = squeeze(potential_energy(i_x_step,4,:,37,(37:73)));
    ff.sh(9).ZData = squeeze(potential_energy(i_x_step,:,4,37,(37:73)));
    % second trial: Always y = -2, yaw = 0
    ff.sh(2).ZData = squeeze(potential_energy(i_x_step,2,4,(19:47),(37:73)));
    ff.sh(6).ZData = squeeze(potential_energy(i_x_step,2,:,37,(37:73)));
    ff.sh(10).ZData = squeeze(potential_energy(i_x_step,:,4,37,(37:73)));
    % third trial: Always y = 2, yaw = -20
    ff.sh(3).ZData = squeeze(potential_energy(i_x_step,6,2,(19:47),(37:73)));
    ff.sh(7).ZData = squeeze(potential_energy(i_x_step,6,:,37,(37:73)));
    ff.sh(11).ZData = squeeze(potential_energy(i_x_step,:,2,37,(37:73)));
    
    % forth trial: From y = 2, yaw = -20 to y = -2, yaw = 0
    %%% where is the y and yaw now
    process_percentage = (X+4.6)/8.6;
    y_now = -4*process_percentage + 2;
    yaw_now = 20*process_percentage - 20;
    i_y_now = -4*process_percentage + 6;
    i_yaw_now = 2*process_percentage + 2;
    % find a large and a small step
    i_y_low = floor(i_y_now);
    if rem(i_y_now,1)==0
        i_y_high = i_y_now + 1;
    else
        i_y_high = ceil(i_y_now);
    end
    i_yaw_low = floor(i_yaw_now);
    if rem(i_yaw_now,1)==0
        i_yaw_high = i_yaw_now + 1;
    else
        i_yaw_high = ceil(i_yaw_now);
    end
    % calculate pitch - roll section
    PE_L_L = squeeze(potential_energy(i_x_step,i_y_low,i_yaw_low,(19:47),(37:73)));
    PE_L_H = squeeze(potential_energy(i_x_step,i_y_low,i_yaw_high,(19:47),(37:73)));
    PE_H_L = squeeze(potential_energy(i_x_step,i_y_high,i_yaw_low,(19:47),(37:73)));
    PE_H_H = squeeze(potential_energy(i_x_step,i_y_high,i_yaw_high,(19:47),(37:73)));
    ff.sh(4).ZData = PE_H_H *(i_y_now-i_y_low) * (i_yaw_now-i_yaw_low) ...
        + PE_L_H *(i_y_high-i_y_now) * (i_yaw_now-i_yaw_low) ...
        + PE_H_L *(i_y_now-i_y_low) * (i_yaw_high-i_yaw_now) ...
        + PE_L_L *(i_y_high-i_y_now) * (i_yaw_high-i_yaw_now);
    % calculate yaw - roll section
    PE_L = squeeze(potential_energy(i_x_step,i_y_low,:,37,(37:73)));
    PE_H = squeeze(potential_energy(i_x_step,i_y_high,:,37,(37:73)));
    ff.sh(8).ZData = PE_H *(i_y_now-i_y_low) + PE_L *(i_y_high-i_y_now);
    % calculate y - roll section
    PE_L = squeeze(potential_energy(i_x_step,:,i_yaw_low,37,(37:73)));
    PE_H = squeeze(potential_energy(i_x_step,:,i_yaw_high,37,(37:73)));
    ff.sh(12).ZData = PE_H *(i_yaw_now-i_yaw_low) + PE_L *(i_yaw_high-i_yaw_now);
    
    % calculate the color scale extreme
    min_bound = 100;
    max_bound = -1;
    for i_sp = 1:12
        max_temp = max(max(ff.sh(i_sp).ZData));
        min_temp = min(min(ff.sh(i_sp).ZData));
        if max_temp > max_bound
            max_bound = max_temp;
        end
        if min_temp < min_bound
            min_bound = min_temp;
        end
    end
    % load in color scare
    for i_sp = 1:12
        ff.sh(i_sp);
        caxis([min_bound,max_bound]);
    end
    
    savefig(gcf,[video_folder,'f',num2str(i_x_step-98,'%02.f'),'.fig']);
    saveas(gcf,[video_folder,'f',num2str(i_x_step-98,'%02.f'),'.jpg']);
end

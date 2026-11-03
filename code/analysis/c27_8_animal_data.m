% interactive code database collection code
close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

% set project name and folder
project = struct();
project.name = 'barrier_5';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];

% load data
addpath([REPO,'/code/model_construction/Dependences_stl']);
load([REPO,'/data/kinematics/DataBase.mat']);

figure(1)
hold on;
for i_trial = 1:36
plot(DataBase.Trial(i_trial).modified.Cockroach.Body.com(:,1),DataBase.Trial(i_trial).modified.Cockroach.Body.com(:,2))
end
xlim([-40,40])
ylim([-10,10])

figure(2)
hold on;
for i_trial = 1:36
plot(DataBase.Trial(i_trial).modified.Cockroach.Body.com(:,1),DataBase.Trial(i_trial).modified.Cockroach.Body.eul(:,1)*180/pi)
end
xlim([-40,40])
ylim([-90,90])

% set grid size
x_grid_length = 0.5;
x_grid_range = [-40, 40];
x_grid_steps = x_grid_range(1):x_grid_length:x_grid_range(2);
x_grid_steps_len = length(x_grid_steps);

y_grid_length = 0.5;
y_grid_range = [-10,10];
y_grid_steps = y_grid_range(1):y_grid_length:y_grid_range(2);
y_grid_steps_len = length(y_grid_steps)-1;

yaw_grid_length = 5;
yaw_grid_range = [-90,90];
yaw_grid_steps = yaw_grid_range(1):yaw_grid_length:yaw_grid_range(2);
yaw_grid_steps_len = length(yaw_grid_steps)-1;

x_y_grid = zeros(y_grid_steps_len,x_grid_steps_len);
x_yaw_grid = zeros(yaw_grid_steps_len,x_grid_steps_len);

% look at each trial
for i_trial = 1:36
    % look at each frame and the previous frame
    frame_num = DataBase.Trial(i_trial).Info.FrameNum;
    for i_frame = 2:frame_num
        % skip nans
        x_pre = DataBase.Trial(i_trial).modified.Cockroach.Body.com(i_frame-1,1);
        if isnan(x_pre)
            continue;
        end
        x_now = DataBase.Trial(i_trial).modified.Cockroach.Body.com(i_frame,1);
        if isnan(x_now)
            continue;
        end
        
        % check the x steps within
        x_big = max(x_pre,x_now);
        x_small = min(x_pre,x_now);
        for i_x_step = 1:x_grid_steps_len
            x_step = x_grid_steps(i_x_step);
            if x_step >= x_small && x_step < x_big
                % for each x steps within, check the y steps within
                y_pre = DataBase.Trial(i_trial).modified.Cockroach.Body.com(i_frame-1,2);
                y_now = DataBase.Trial(i_trial).modified.Cockroach.Body.com(i_frame,2);
                y_step = y_pre + (y_now-y_pre)/(x_now-x_pre)*(x_step-x_pre);
                
                for i_y_step = 1:y_grid_steps_len
                    if y_step >= y_grid_steps(i_y_step) && y_step < y_grid_steps(i_y_step+1)
                        % record one
                        x_y_grid(i_y_step,i_x_step) = x_y_grid(i_y_step,i_x_step)+1;
                        break;
                    end
                end
                
                % for each x steps within, check the yaw steps within
                yaw_pre = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(i_frame-1,1)*180/pi;
                yaw_now = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(i_frame,1)*180/pi;
                yaw_step = yaw_pre + (yaw_now-yaw_pre)/(x_now-x_pre)*(x_step-x_pre);
                
                for i_yaw_step = 1:yaw_grid_steps_len
                    if yaw_step >= yaw_grid_steps(i_yaw_step) && yaw_step < yaw_grid_steps(i_yaw_step+1)
                        % record one
                        x_yaw_grid(i_yaw_step,i_x_step) = x_yaw_grid(i_yaw_step,i_x_step)+1;
                        break;
                    end
                end
            end
        end
    end
end



% collect means and stds
for i_x_step = 1:x_grid_steps_len
    temp_array = [];
    for i_y_step = 1: y_grid_steps_len
        temp_array = [temp_array,ones(1,x_y_grid(i_y_step,i_x_step))*y_grid_steps(i_y_step)];
    end
    y_means(i_x_step) = mean(temp_array);
    y_std(i_x_step) = std(temp_array);
    
    temp_array = [];
    for i_yaw_step = 1: yaw_grid_steps_len
        temp_array = [temp_array,ones(1,x_yaw_grid(i_yaw_step,i_x_step))*yaw_grid_steps(i_yaw_step)];
    end
    yaw_means(i_x_step) = mean(temp_array);
    yaw_std(i_x_step) = std(temp_array);
end

% normolization
for i_x_step = 1:x_grid_steps_len
    x_y_grid(:,i_x_step) = x_y_grid(:,i_x_step)/norm(x_y_grid(:,i_x_step));
    x_yaw_grid(:,i_x_step) = x_yaw_grid(:,i_x_step)/norm(x_yaw_grid(:,i_x_step));
end

% do the histo
figure(3)
set(gcf,'Position',[720,600,800,420])
hold on;
[Y,X] = meshgrid(x_grid_steps,y_grid_steps(1:end-1));
colormap(fire)
surf(X,Y,x_y_grid,'EdgeAlpha',0)
view(90,-90)
set(gca,'FontSize',20)
plot(y_means, x_grid_steps, 'LineWidth',3,'Color','g')
plot(y_means + y_std, x_grid_steps, 'LineStyle',':','LineWidth',3,'Color','g')
plot(y_means - y_std, x_grid_steps, 'LineStyle',':','LineWidth',3,'Color','g')

figure(4)
set(gcf,'Position',[60,60,800,420])
hold on;
[Y,X] = meshgrid(x_grid_steps,yaw_grid_steps(1:end-1));
colormap(fire)
surf(X,Y,x_yaw_grid,'EdgeAlpha',0)
view(90,-90)
set(gca,'FontSize',20)
plot(yaw_means, x_grid_steps, 'LineWidth',3,'Color','g')
plot(yaw_means + yaw_std, x_grid_steps, 'LineStyle',':','LineWidth',3,'Color','g')
plot(yaw_means - yaw_std, x_grid_steps, 'LineStyle',':','LineWidth',3,'Color','g')





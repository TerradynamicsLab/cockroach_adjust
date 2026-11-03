% body yaw, head pitch

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
set(gca,'FontSize',20)
hold on;
figure(2)
set(gca,'FontSize',20)
hold on;
figure(3)
set(gca,'FontSize',20)
hold on;

% set grid size
x_grid_length = 0.5;
x_grid_range = [-40, 40];
x_grid_steps = x_grid_range(1):x_grid_length:x_grid_range(2);
x_grid_steps_len = length(x_grid_steps);

HP_grid_length = 5;
HP_grid_range = [-90,90];
HP_grid_steps = HP_grid_range(1):HP_grid_length:HP_grid_range(2);
HP_grid_steps_len = length(HP_grid_steps)-1;

yaw_grid_length = 5;
yaw_grid_range = [-90,90];
yaw_grid_steps = yaw_grid_range(1):yaw_grid_length:yaw_grid_range(2);
yaw_grid_steps_len = length(yaw_grid_steps)-1;

x_HP_grid = zeros(HP_grid_steps_len,x_grid_steps_len);
x_yaw_grid = zeros(yaw_grid_steps_len,x_grid_steps_len);

% holders
stat_temp_X = [];
stat_temp_Y = [];

% look at each trial
for i_trial = [2,3,4,5,8,9,10,16,23,24,25,30,31,36] % 1:36
    % check each phase
    for i_phase = 1:5
        switch i_phase
            case 1 % approach phase
                frames = DataBase.Trial(i_trial).Info.EnterFrame:DataBase.Trial(i_trial).Info.TouchFrame;
                plot_color = [0.4, 0.4, 0.4];
            case 2 % explore + pitch phase
                frames = DataBase.Trial(i_trial).Info.TouchFrame:DataBase.Trial(i_trial).Info.RollStartFrame;
                plot_color = [0, 0, 1];
            case 3 % roll phase
                frames = DataBase.Trial(i_trial).Info.RollStartFrame:DataBase.Trial(i_trial).Info.RollMaxFrame;
                plot_color = [1, 0, 0];
            case 4 % land phase
                frames = DataBase.Trial(i_trial).Info.RollMaxFrame:DataBase.Trial(i_trial).Info.LandFrame;
                plot_color = [1, 0.6, 0.2];
            case 5 % depart phase
                frames = DataBase.Trial(i_trial).Info.LandFrame:DataBase.Trial(i_trial).Info.LeaveFrame;
                plot_color = [0.49,0.18,0.56];
        end
        
        x_temp = [];
        HP_temp = [];
        yaw_temp = [];
        
        for i_frame = frames
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
                    x_temp = [x_temp, x_step];
                    
                    % for each x steps within, check the HP steps within
                    HP_pre = DataBase.Trial(i_trial).modified.Cockroach.Head.eul_b(i_frame-1,2)*180/pi;
                    HP_now = DataBase.Trial(i_trial).modified.Cockroach.Head.eul_b(i_frame,2)*180/pi;
                    HP_step = HP_pre + (HP_now-HP_pre)/(x_now-x_pre)*(x_step-x_pre);
                    HP_temp = [HP_temp, HP_step];
                    
                    % for each x steps within, check the yaw steps within
                    yaw_pre = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(i_frame-1,1)*180/pi;
                    yaw_now = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(i_frame,1)*180/pi;
                    yaw_step = yaw_pre + (yaw_now-yaw_pre)/(x_now-x_pre)*(x_step-x_pre);
                    yaw_temp = [yaw_temp, yaw_step];
                    
                end
            end
        end
        
        
        
        % plot
        figure(1);
        plot(x_temp,HP_temp,'Color',plot_color);
        figure(2);
        plot(x_temp,yaw_temp,'Color',plot_color);
        
        figure(3);
        switch i_phase
            case {3}%{1,2,3,4,5}
                plot(yaw_temp,HP_temp,'*','Color',plot_color);
                stat_temp_X = [stat_temp_X, yaw_temp];
                stat_temp_Y = [stat_temp_Y, HP_temp];
            case {1,2,4,5} % approach phase
                do_nothing = 1;    
        end
    end
    
end



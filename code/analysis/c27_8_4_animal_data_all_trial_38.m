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

% trial_38
DataBase.Trial(38) = DataBase.Trial(37);

% y, z, yaw, pitch, roll, head_pitch_b, abdomen_pitch_b
for var_i = 1:7
    
    % set grid size
    x_grid_length = 0.2;
    x_grid_range = [-26, 33];
    x_grid_steps = x_grid_range(1):x_grid_length:x_grid_range(2);
    x_grid_steps_len = length(x_grid_steps);
    
    if var_i == 1 % y
        var_grid_length = 0.5;
        var_grid_range = [-15,15];
    elseif var_i == 2 % z
        var_grid_length = 0.5;
        var_grid_range = [0,25];
    elseif var_i == 3 % yaw
        var_grid_length = 5;
        var_grid_range = [-90,90];
    elseif var_i == 4 % pitch
        var_grid_length = 5;
        var_grid_range = [-50,30];
    elseif var_i == 5 % roll
        var_grid_length = 5;
        var_grid_range = [-50,100];
    elseif var_i == 6 % head_pitch_b
        var_grid_length = 2;
        var_grid_range = [-20,65];
    elseif var_i == 7 % abdomen_pitch_b
        var_grid_length = 2;
        var_grid_range = [-45,10];
    end
    
    var_grid_steps = var_grid_range(1):var_grid_length:var_grid_range(2);
    var_grid_steps_len = length(var_grid_steps)-1;
    x_var_grid = zeros(var_grid_steps_len,x_grid_steps_len);
    
    % look at each trial
    for i_trial = 1:36
        % look at each frame and the previous frame
        frame_num = DataBase.Trial(i_trial).Info.FrameNum;
        
        % vars
        Xs = DataBase.Trial(i_trial).modified.Cockroach.Body.com(:,1);
        if var_i == 1 % y
            vars = DataBase.Trial(i_trial).modified.Cockroach.Body.com(:,2);
        elseif var_i == 2 % z
            vars = DataBase.Trial(i_trial).modified.Cockroach.Body.com(:,3);
        elseif var_i == 3 % yaw
            vars = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(:,1)*180/pi;
        elseif var_i == 4 % pitch
            vars = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(:,2)*180/pi;
        elseif var_i == 5 % roll
            vars = DataBase.Trial(i_trial).modified.Cockroach.Body.eul(:,3)*180/pi;
        elseif var_i == 6 % head_pitch_b
            vars = DataBase.Trial(i_trial).modified.Cockroach.Head.eul_b(:,2)*180/pi;
        elseif var_i == 7 % abdomen_pitch_b
            vars = DataBase.Trial(i_trial).modified.Cockroach.Abdomen_Up.eul_b(:,2)*180/pi;
        end
        
        for i_frame = 2:frame_num
            % skip nans
            x_pre = Xs(i_frame-1);
            if isnan(x_pre)
                continue;
            end
            x_now = Xs(i_frame);
            if isnan(x_now)
                continue;
            end
            
            % check the x steps within
            x_big = max(x_pre,x_now);
            x_small = min(x_pre,x_now);
            for i_x_step = 1:x_grid_steps_len
                x_step = x_grid_steps(i_x_step);
                if x_step >= x_small && x_step < x_big
                    
                    % for each x steps within, check the var steps within
                    var_pre = vars(i_frame-1);
                    var_now = vars(i_frame);
                    var_step = var_pre + (var_now-var_pre)/(x_now-x_pre)*(x_step-x_pre);
                    
                    for i_var_step = 1:var_grid_steps_len
                        if var_step >= var_grid_steps(i_var_step) && var_step < var_grid_steps(i_var_step+1)
                            % record one
                            x_var_grid(i_var_step,i_x_step) = x_var_grid(i_var_step,i_x_step)+1;
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
        for i_var_step = 1: var_grid_steps_len
            temp_array = [temp_array,ones(1,x_var_grid(i_var_step,i_x_step))*var_grid_steps(i_var_step)];
        end
        var_means(i_x_step) = mean(temp_array);
        var_std(i_x_step) = std(temp_array);
    end
    
    % normolization
    for i_x_step = 1:x_grid_steps_len
        x_var_grid(:,i_x_step) = x_var_grid(:,i_x_step)/norm(x_var_grid(:,i_x_step));
    end
    
    % do the histo
    figure(var_i)
    set(gcf,'Position',[60,60,800,420])
    hold on;
    [Y,X] = meshgrid(x_grid_steps,var_grid_steps(1:end-1));
    colormap(fire)
    surf(X,Y,x_var_grid,'EdgeAlpha',0)
    view(90,-90)
    set(gca,'FontSize',20)
    plot(var_means, x_grid_steps, 'LineWidth',3,'Color','g')
    plot(var_means + var_std, x_grid_steps, 'LineStyle',':','LineWidth',3,'Color','g')
    plot(var_means - var_std, x_grid_steps, 'LineStyle',':','LineWidth',3,'Color','g')
    
    xlim(var_grid_range);
    ylim(x_grid_range);
    
    colorbar;
    
    % load in trial 38
    if var_i == 1 % y
        DataBase.Trial(38).modified.Cockroach.Body.com(:,2) = var_means';
    elseif var_i == 2 % z
        DataBase.Trial(38).modified.Cockroach.Body.com(:,3) = var_means';
    elseif var_i == 3 % yaw
        DataBase.Trial(38).modified.Cockroach.Body.eul(:,1) = var_means'*pi/180;
    elseif var_i == 4 % pitch
        DataBase.Trial(38).modified.Cockroach.Body.eul(:,2) = var_means'*pi/180;
    elseif var_i == 5 % roll
        DataBase.Trial(38).modified.Cockroach.Body.eul(:,3) = var_means'*pi/180;
    elseif var_i == 6 % head_pitch_b
        DataBase.Trial(38).modified.Cockroach.Head.eul_b(:,2) = var_means'*pi/180;
    elseif var_i == 7 % abdomen_pitch_b
        DataBase.Trial(38).modified.Cockroach.Abdomen_Up.eul_b(:,2) = var_means'*pi/180;
    end

end


% calculate trial 38 Head com, eul, Abdomen_Up com, eul
animal_dia = DataBase.cockroach_model.dia(DataBase.Trial(38).Info.AnimalNum);

for frame_i = 1:DataBase.Trial(38).Info.FrameNum
    input = struct;
    input.body.com = DataBase.Trial(38).modified.Cockroach.Body.com(frame_i,:);
    input.body.eul = DataBase.Trial(38).modified.Cockroach.Body.eul(frame_i,:);
    input.head.eul_b = DataBase.Trial(38).modified.Cockroach.Head.eul_b(frame_i,:);
    input.abdomen.eul_b = DataBase.Trial(38).modified.Cockroach.Abdomen_Up.eul_b(frame_i,:);
    input = calculate_head_abdomen(animal_dia,input);
    
    DataBase.Trial(38).modified.Cockroach.Head.com(frame_i,:) = input.head.com;
    DataBase.Trial(38).modified.Cockroach.Head.eul(frame_i,:) = input.head.eul;
    DataBase.Trial(38).modified.Cockroach.Abdomen_Up.com(frame_i,:) = input.abdomen.com;
    DataBase.Trial(38).modified.Cockroach.Abdomen_Up.eul(frame_i,:) = input.abdomen.eul;
end

save([REPO,'/data/kinematics/DataBase.mat'],'DataBase');

close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/BFS_dependences']));

is_re = 0;
beam_cal_re = 0;
is_fix = 0;

% video settings
is_video = 0;

% set project name and folder
project = struct();
project.name = 'barrier_3';

% folders
video_folder = [[REPO,'/output/'],project.name,'\'];
if ~exist(video_folder, 'dir')
    mkdir(video_folder)
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end

% load database and code
load([REPO,'/data/kinematics/DataBase.mat']);
addpath([REPO,'/code/model_construction/Dependences_stl']);

% loop trials
for trial_i = [37]
    disp(['Trial: ',num2str(trial_i)]);
    
    BFS_result.roll_PM = [];
    BFS_result.pitch_PM = [];
    BFS_result.energy_PM = [];
    BFS_result.roll_RM = [];
    BFS_result.pitch_RM = [];
    BFS_result.energy_RM = [];
    BFS_result.roll_S = [];
    BFS_result.pitch_S = [];
    BFS_result.energy_S = [];
    BFS_result.energy_barrier = [];
    
    if is_video
        % load video writer
        video_file = [video_folder,'basin_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.avi'];
        v = VideoWriter(video_file);
        close(v);
        open(v);
    end
    
    % load
    load([project.folder,'data_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
    p_r_mini = csvread([project.folder,'basin_select_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.csv']);
    
    
    % choose the data you want...
    frame_range = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.LandFrame;
    frame_num_selected = length(frame_range);
    
    % animal information
    animal_NO = DataBase.Trial(trial_i).Info.AnimalNum;
    animal_dia = DataBase.cockroach_model.dia(animal_NO);
    input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass * 1e-3;
    input.body.mass = input.total.mass;
    input.mass_bias_b = [DataBase.cockroach_model.dia(animal_NO).total.mass_bias_b;0;0];
    %%% model mat
    head_mat_origin = DataBase.cockroach_model.head(animal_NO);
    body_mat_origin = DataBase.cockroach_model.body(animal_NO);
    abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);
    %%% scalers
    scaler0 = [0.7,0.9,0.9,  1,1,0.9,  1,1,0.9];
    shift0 = [0,-1,-1]; % head, body, abdomen
    is_axis_shift = 1;
    is_ab_trans = 0;
    %%% changing in the model
    ratio = struct();
    ratio.head.length = scaler0(1);
    ratio.head.width = scaler0(2);
    ratio.head.thickness = scaler0(3);
    ratio.body.length = scaler0(4);
    ratio.body.width = scaler0(5);
    ratio.body.thickness = scaler0(6);
    ratio.abdomen.length = scaler0(7);
    ratio.abdomen.width = scaler0(8);
    ratio.abdomen.thickness = scaler0(9);
    %%%%%%%%%%% model modification %%%%%%%%%%%%%%%%%%
    head_mat= head_mat_origin;
    head_mat.vertice_position(:,1) = head_mat.vertice_position(:,1) * ratio.head.length;
    head_mat.vertice_position(:,2) = head_mat.vertice_position(:,2) * ratio.head.width;
    head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3) * ratio.head.thickness + shift0(1);
    body_mat= body_mat_origin;
    body_mat.vertice_position(:,1) = body_mat.vertice_position(:,1) * ratio.body.length;
    body_mat.vertice_position(:,2) = body_mat.vertice_position(:,2) * ratio.body.width;
    body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3) * ratio.body.thickness + shift0(2);
    abdomen_mat= abdomen_mat_origin;
    abdomen_mat.vertice_position(:,1) = abdomen_mat.vertice_position(:,1) * ratio.abdomen.length;
    abdomen_mat.vertice_position(:,2) = abdomen_mat.vertice_position(:,2) * ratio.abdomen.width;
    abdomen_mat.vertice_position(:,3) = abdomen_mat.vertice_position(:,3) * ratio.abdomen.thickness + shift0(3);
    if is_axis_shift
        animal_dia.total.neck_point = animal_dia.total.neck_point * ratio.body.length + [0,0,shift0(2)]';
        animal_dia.total.waist_point = animal_dia.total.waist_point * ratio.body.length + [0,0,shift0(2)]';
    else
        animal_dia.total.neck_point = animal_dia.total.neck_point;
        animal_dia.total.waist_point = animal_dia.total.waist_point;
    end
    
    % landscape
    sizes = [size(data.body_roll,2),size(data.body_roll,3)];
    X = reshape(data.body_roll(1,:,:),sizes)'*180/pi;
    Y = reshape(data.body_pitch(1,:,:),sizes)'*180/pi;
    
    for frame_i = 1:frame_num_selected
        f = frame_range(frame_i);
        
        disp(frame_i);
        
        % load landscape
        landscape = data.landscape_value(frame_i,:,:);
        landscape = reshape(landscape,[size(landscape,2),size(landscape,3)])';
        Z = landscape;
        
        % load configuration
        xPitch =  p_r_mini(1,frame_i);
        yPitch =  p_r_mini(2,frame_i);
        xRoll =  p_r_mini(3,frame_i);
        yRoll =  p_r_mini(4,frame_i);
        
        %%% set barrier to not go left
        BFS_landscape = landscape;
        BFS_landscape(:,xPitch-1) = BFS_landscape(:,xPitch-1)*0+1000;
        
        % BFS
        [saddleXYZ,routeXYZ,basin_landscape] = mini2mini(BFS_landscape,xPitch,yPitch,xRoll,yRoll,0,0);
        for i = 1:size(basin_landscape,2)
            for j = 1:size(basin_landscape,1)
                if basin_landscape(j,i) == 1
                    c(j,i,1:3) = [0.5,0.5,1];
                elseif basin_landscape(j,i) == 2
                    c(j,i,1:3) = [1,0.5,0.5];
                else
                    c(j,i,1:3) = [0,0,0];
                end
            end
        end
        
        roll_PM = X(yPitch,xPitch);
        pitch_PM = Y(yPitch,xPitch);
        energy_PM = Z(yPitch,xPitch);
        roll_RM = X(yRoll,xRoll);
        pitch_RM = Y(yRoll,xRoll);
        energy_RM = Z(yRoll,xRoll);
        roll_S = X(saddleXYZ(2),saddleXYZ(1));
        pitch_S = Y(saddleXYZ(2),saddleXYZ(1));
        energy_S = saddleXYZ(3);
        energy_barrier = energy_S-energy_PM;
        route_length = length(routeXYZ);
        roll_route = [];
        pitch_route = [];
        energy_route = [];
        for route_i = 1:route_length
            roll_route(route_i) = X(routeXYZ(2,route_i),routeXYZ(1,route_i));
            pitch_route(route_i) = Y(routeXYZ(2,route_i),routeXYZ(1,route_i));
            energy_route(route_i) = Z(routeXYZ(2,route_i),routeXYZ(1,route_i));
        end
        
        %%%%%%%% maybe record %%%%%%%%%
        BFS_result.roll_PM = [BFS_result.roll_PM, roll_PM];
        BFS_result.pitch_PM = [BFS_result.pitch_PM, pitch_PM];
        BFS_result.energy_PM = [BFS_result.energy_PM, energy_PM];
        BFS_result.roll_RM = [BFS_result.roll_RM, roll_RM];
        BFS_result.pitch_RM = [BFS_result.pitch_RM, pitch_RM];
        BFS_result.energy_RM = [BFS_result.energy_RM, energy_RM];
        BFS_result.roll_S = [BFS_result.roll_S, roll_S];
        BFS_result.pitch_S = [BFS_result.pitch_S, pitch_S];
        BFS_result.energy_S = [BFS_result.energy_S, energy_S];
        BFS_result.energy_barrier = [BFS_result.energy_barrier, energy_barrier];
        
        
        input.body.com = DataBase.Trial(trial_i).modified.Cockroach.Body.com(f,:);
        if is_fix == 1
            input.head.eul_b = [0,15,0] *pi/180;
        else
            input.head.eul_b = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(f,:);
        end
        input.abdomen.eul_b = [0,-7,0] *pi/180;
        input.beam_cal_re = 0;
        input.beam.ref_left_pitch = 0;
        input.beam.ref_right_pitch = 0;
        
        if frame_i == 1
            % plot
            figure(1);
            clf;
            
            % sp1
            sp1 = subplot(2,2,1);
            cla(sp1);
            ti1 = title(['Body Pitch: ',num2str(pitch_PM),'°; ','Body roll: ',num2str(roll_PM),'°']);
            input.body.eul = [0,pitch_PM,roll_PM]*pi/180;
            input = calculate_head_abdomen(animal_dia,input);
            input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
            
            % sp2
            sp2 = subplot(2,2,2);
            cla(sp2);
            ti2 = title(['Body Pitch: ',num2str(pitch_RM),'°; ','Body roll: ',num2str(roll_RM),'°']);
            input.body.eul = [0,pitch_RM,roll_RM]*pi/180;
            input = calculate_head_abdomen(animal_dia,input);
            input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
            
            % sp3
            sp3 = subplot(2,2,3);
            cla(sp3);
            hold on;
            ti3 = title(['Body X: ',num2str(input.body.com(1)),' mm']);
            
            s1 = surf(X,Y,Z,'EdgeAlpha',0);
            colormap(sp3,fire);
            axis equal;
            xlim([-180,180]);
            ylim([-180,180]);
            set(gca,'FontSize', 20);
            colorbar;
            view([0,-90]);
            l1 = plot(roll_route,pitch_route,'LineStyle','-','LineWidth',3,'Color','g');
            p11 = plot(roll_PM,pitch_PM,'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
            p12 = plot(roll_RM,pitch_RM,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
            p13 = plot(roll_S,pitch_S,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
            
            % sp4
            sp4 = subplot(2,2,4);
            cla(sp4);
            hold on;
            
            ti4 = title(['Body X: ',num2str(input.body.com(1)),' mm']);
            s2 = surf(X,Y,Z,c,'EdgeAlpha',0);
            colormap(sp3,fire);
            axis equal;
            xlim([-180,180]);
            ylim([-180,180]);
            set(gca,'FontSize', 20);
            view([0,-90]);
            l2 = plot(roll_route,pitch_route,'LineStyle','-','LineWidth',3,'Color','g');
            p21 = plot(roll_PM,pitch_PM,'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
            p22 = plot(roll_RM,pitch_RM,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
            p23 = plot(roll_S,pitch_S,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
            
        else
            % sp1
            axes(sp1);
            cla(sp1);
            
            ti1 = title(['Body Pitch: ',num2str(pitch_PM),'°; ','Body roll: ',num2str(roll_PM),'°']);
            input.body.eul = [0,pitch_PM,roll_PM]*pi/180;
            input = calculate_head_abdomen(animal_dia,input);
            input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
            
            % sp2
            axes(sp2);
            cla(sp2);
            
            ti2 = title(['Body Pitch: ',num2str(pitch_RM),'°; ','Body roll: ',num2str(roll_RM),'°']);
            input.body.eul = [0,pitch_RM,roll_RM]*pi/180;
            input = calculate_head_abdomen(animal_dia,input);
            input = calculate_state_stl_tribody_v2_noshift(input,body_mat,head_mat,abdomen_mat);
            
            %sp3
            
            ti3.String = ['Body X: ',num2str(input.body.com(1)),' mm'];
            s1.ZData = Z;
            l1.XData = roll_route;
            l1.YData = pitch_route;
            p11.XData = roll_PM;
            p11.YData = pitch_PM;
            p12.XData = roll_RM;
            p12.YData = pitch_RM;
            p13.XData = roll_S;
            p13.YData = pitch_S;
            
            %sp4
            ti4.String = ['Body X: ',num2str(input.body.com(1)),' mm'];
           
            s2.ZData = Z;
            s2.CData = c;
            l2.XData = roll_route;
            l2.YData = pitch_route;
            p21.XData = roll_PM;
            p21.YData = pitch_PM;
            p22.XData = roll_RM;
            p22.YData = pitch_RM;
            p23.XData = roll_S;
            p23.YData = pitch_S;
            
        end
        if is_video
            % get frame and write in video
            frame = getframe(gcf);
            writeVideo(v,frame);
        else
            pause(0.2);
        end
    end
    if is_video
        close(v);
    end
    save([project.folder,'BFS_result_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat'],'BFS_result')
end
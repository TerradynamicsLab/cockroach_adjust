% Yaqing created this to analysis the pandora space in a BFS way.
% modified from pandora_space_analysis_BFS_stl_animal_data_analysis.m


close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

is_re = 0;
beam_cal_re = 0;
is_fix = 0;

project = struct();
% video settings
is_video = 1;

if is_re == 1
    % set project name and folder
    project.name = 'barrier_1_re';
    % load database and code
    load([REPO,'/data/kinematics/DataBase_re.mat']);
    video_folder = [REPO,'/output/barrier_1_re/'];
else
    % set project name and folder
    project.name = 'barrier_3';
    % load database and code
    load([REPO,'/data/kinematics/DataBase.mat']);
    video_folder = [REPO,'/output/barrier_3/'];
end

project.folder = [[REPO,'/output/landscape/'],project.name,'\'];
if ~exist(project.folder, 'dir')
    mkdir(project.folder)
end
addpath([REPO,'/code/model_construction/Dependences_stl']);

% Mode: 1, measured head angle. 2. fixed head angle 3. fixed head and
% abdomen angle
mode = 1;

for mode = 1


% set your result name
for trial_i = 37
    % display the trial_i
    disp(['trial_i: ',num2str(trial_i)]);
    % create the holder
    barrier_BFS = struct;
    
    % variables you fond
    if is_re == 1
        load([project.folder,'data_trial_',num2str(trial_i),'_beam_cal_re_',num2str(beam_cal_re),'.mat']);
    else
        if mode == 1
            load([project.folder,'data_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
%             load([project.folder,'data_trial_',num2str(trial_i),'_groundtruth.mat']);
        elseif mode == 2
            load([project.folder,'data_trial_',num2str(trial_i),'_headfix.mat']);
        elseif mode == 3
            load([project.folder,'data_trial_',num2str(trial_i),'_HBfix.mat']);
        else
            error('Wrong mode');
        end
    end
    
    % real route
    R_route_length = length(data.R_body_roll);
    R_route_x = nan(1,R_route_length);
    R_route_y = nan(1,R_route_length);
    for index = 1:R_route_length
        R_route_x(index) = find_index_in_array(data.R_body_roll(index),reshape(data.body_roll(1,1,:),[1,size(data.landscape_value,3)])');
        R_route_y(index) = find_index_in_array(data.R_body_pitch(index),data.body_pitch(1,:,1)');
    end
    
    
    Frame_num = length(data.body_x);
    % for each frame
    for f = 1:Frame_num
        % display the frame
        disp(['Frame: ',num2str(f)]);
        
        %%% loading your landscape at this head_pitch_b, this frame
        roll_length = size(data.landscape_value,2);
        pitch_length = size(data.landscape_value,3);
        landscape = reshape(data.landscape_value(f,:,:),[roll_length,pitch_length])';
        body_roll = reshape(data.body_roll(f,:,:),[roll_length,pitch_length])';
        body_pitch = reshape(data.body_pitch(f,:,:),[roll_length,pitch_length])';
        body_roll = body_roll*180/pi;
        body_pitch = body_pitch*180/pi;
        
        % real route
        % calculate real route
        R_route_z = nan(1,R_route_length);
        
        min_R_x = 10000;
        
        for i = 1:R_route_length
            temp_x = R_route_x(i);
            min_R_x = min([min_R_x,temp_x]);
            temp_y = R_route_y(i);
            R_route_z(i) = Bilinear_Interpolation_whole_landscape_YW(landscape,temp_x,temp_y)+0.01;
        end
        
        % record route
        barrier_BFS.R_route(f).roll = data.R_body_roll*180/pi;
        barrier_BFS.R_route(f).pitch = data.R_body_pitch*180/pi;
        barrier_BFS.R_route(f).energy = R_route_z;
        
%         % critical points
%         if f == 1 % find a start point at the first time
            % go to the basin
            sign_go_down = 0;
            basin_energy = nan;
            basin_body_pitch = nan;
            for i_body_pitch = ceil(pitch_length/2):-1:1
                temp_energy = landscape(i_body_pitch,ceil(roll_length/2));
                if isnan(basin_energy)
                    basin_energy = temp_energy;
                    basin_body_pitch = i_body_pitch;
                elseif basin_energy >= temp_energy %% whether we should have =
                    basin_body_pitch = i_body_pitch;
                    basin_energy = temp_energy;
                    sign_go_down = 1;
                elseif sign_go_down == 1
                    break;
                end
            end
            
            %%% set origin point
            Ox = ceil(roll_length/2);
            Oy = basin_body_pitch;
%         else % use the previous pitch basin
% %             Ox = output.pitch_minimum.x;
%             Ox = ceil(roll_length/2);
%             Oy = output.pitch_minimum.y;
%         end
        
        % ban roll -
        old_landscape = landscape;
        landscape(1:pitch_length,1:2) = 1000*ones(pitch_length,2);
%         landscape(1:pitch_length,floor(min_R_x)-2:floor(min_R_x)-1) = 1000*ones(pitch_length,2);
        
        % calculate using BFS
        output = landscape_BFS_v4(landscape, Ox, Oy);
        landscape(1:pitch_length,floor(output.pitch_minimum.x)-2:floor(output.pitch_minimum.x)-1) = 1000*ones(pitch_length,2);
        output = landscape_BFS_v4(landscape, output.pitch_minimum.x, output.pitch_minimum.y);   
        
        % record barrier_BFS
        barrier_BFS.saddle.roll(f) = body_roll(output.saddle.y,output.saddle.x);
        barrier_BFS.saddle.pitch(f) = body_pitch(output.saddle.y,output.saddle.x);
        barrier_BFS.saddle.energy(f) = output.saddle.value;
        barrier_BFS.pitch_minimum.roll(f) = body_roll(output.pitch_minimum.y,output.pitch_minimum.x);
        barrier_BFS.pitch_minimum.pitch(f) = body_pitch(output.pitch_minimum.y,output.pitch_minimum.x);
        barrier_BFS.pitch_minimum.energy(f) = output.pitch_minimum.value;
        barrier_BFS.roll_minimum.roll(f) = body_roll(output.roll_minimum.y,output.roll_minimum.x);
        barrier_BFS.roll_minimum.pitch(f) = body_pitch(output.roll_minimum.y,output.roll_minimum.x);
        barrier_BFS.roll_minimum.energy(f) = output.roll_minimum.value;
        % A_stop_sign = 1;
        
        % create a fake route
        route_ix = output.path.x;
        route_iy = output.path.y;
        route_length = length(route_ix);
        route_x = nan(1,route_length);
        route_y = nan(1,route_length);
        route_z = nan(1,route_length);
        
        for i = 1:route_length
            temp_x = route_ix(i);
            temp_y = route_iy(i);
            route_x(i) = Bilinear_Interpolation_whole_landscape_YW(body_roll,temp_x,temp_y);
            route_y(i) = Bilinear_Interpolation_whole_landscape_YW(body_pitch,temp_x,temp_y);
            route_z(i) = Bilinear_Interpolation_whole_landscape_YW(landscape,temp_x,temp_y)+0.01;
        end
        
        % record route
        barrier_BFS.route(f).roll = route_x;
        barrier_BFS.route(f).pitch = route_y;
        barrier_BFS.route(f).energy = route_z;
        
        
        
    end
    
    % save barrier_BFS
    if is_re == 1
        save([project.folder,'barrier_BFS_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat'],'barrier_BFS');
    else
        if mode == 1
            save([project.folder,'barrier_BFS_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat'],'barrier_BFS');
%             save([project.folder,'barrier_BFS_',num2str(trial_i),'_groundtruth.mat'],'barrier_BFS');
        elseif mode == 2
            save([project.folder,'barrier_BFS_',num2str(trial_i),'_headfix.mat'],'barrier_BFS');
        elseif mode == 3
            save([project.folder,'barrier_BFS_',num2str(trial_i),'_HBfix.mat'],'barrier_BFS');
        else
            error('Wrong mode');
        end
    end
end

end
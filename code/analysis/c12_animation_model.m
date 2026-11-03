% Yaqing have this on 7/13/2020 to create animation of the model
clear; close; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath([REPO,'/code/model_construction/Dependences_stl']);



% enter reconstruction mode
% 1: model only, real tracking data, only relative pitch, with shifting, without beam calculation
% 2: model only (shape optimized), real tracking data, beam calculated, only relative pitch, with shifting,
% 3: model only (shape optimized), no head flexion, beam calculated, only relative pitch, with shifting,
% 4: plot the projection in the raw video, derived from Mode 2
mode = 4;

% enter the trial NO

Cam_NO = 1;
Trial_NO = 1;

% if it is mode 4, enter camera view number
Trials = 35%:4;%:2;
Cams = 1:8;%1:8;


% enter video name
is_video = 1;
% video_folder = 'D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\p5_PEL_model\f1_tracking_animation_model\';
% video_name = [video_folder,'Trial_',num2str(Trial_NO),'_animation'];
% video_name = [video_folder,'Trial_',num2str(Trial_NO),'_calculation'];
% video_name = [video_folder,'Trial_',num2str(Trial_NO),'_calculation_head_fix'];
% video_name = [video_folder,'Trial_',num2str(Trial_NO),'_calculation_modify_0.2'];
video_folder = [REPO,'/output/YW_video_temp_1/'];
video_name = [video_folder,'Trial_',num2str(Trial_NO),'_Cam_',num2str(Cam_NO),'_Mode_4.avi'];

% launch video
if is_video == 0%1
    v = VideoWriter(video_name);
    open(v);
end

% load database
load([REPO,'/data/kinematics/DataBase.mat']);
InfoFile = [REPO,'/data/info/Info.xlsx'];
[InfoNum,InfoTxt] = xlsread(InfoFile,'selected_36');
CalFolder = [REPO,'/data/calibration/'];
CalFile = [CalFolder,'cal_',char(InfoTxt(Trial_NO+1,8)),'DLTcoefs.csv'];
Cal = csvread(CalFile);

% 1: model only
if mode == 1
    
    % load in const data
    input = struct();
    animal_NO = DataBase.Trial(Trial_NO).Info.AnimalNum;
    animal_dia = DataBase.cockroach_model.dia(animal_NO);
    frame_num = DataBase.Trial(Trial_NO).Info.FrameNum;
    input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass;
    
    %%% calculation body_mat
    body_mat = load([REPO,'/code/model_construction/body.mat']);
    body_mat = body_mat.body;
    %%% calculation head_mat
    head_mat = load([REPO,'/code/model_construction/head.mat']);
    head_mat = head_mat.head;
    %%% calculation head_mat
    abdomen_mat = load([REPO,'/code/model_construction/abdomen.mat']);
    abdomen_mat = abdomen_mat.abdomen;
    
    % loop frame
    for frame_i = 1:frame_num
        % load body frame and head/abdomen relative eul angle
        input.body.com = DataBase.Trial(Trial_NO).modified.Cockroach.Body.com(frame_i,:);
        input.body.eul = DataBase.Trial(Trial_NO).modified.Cockroach.Body.eul(frame_i,:);
        input.head.eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Head.eul_b(frame_i,:).*[0,1,0];
        input.abdomen.eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Abdomen_Up.eul_b(frame_i,:).*[0,1,0];
        
        % calculate head and abdomen com and eul
        input = calculate_head_abdomen(animal_dia,input);
        
        % shift
        input = calculate_state_stl_tribody(input,body_mat,head_mat,abdomen_mat);
        
        % load beam
        input.beam.angle_left = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.left_pitch(frame_i);
        input.beam.angle_right = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.right_pitch(frame_i);
        
        body_mat_ = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
        head_mat_ = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
        abdomen_mat_ = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
        
        % reconstruct video
        reconstruction_visualization_stl_tribody(input,body_mat_,head_mat_,abdomen_mat_);
        
        % video recording
        if is_video == 1
            frame = getframe(gcf);
            writeVideo(v,frame);
        end
    end
end


% 2
if mode == 2
    scaler0 = [1,1,1,1,1,1,1,1,1];
    
    %     scaler0 = [1.0369    1.0917    0.9099    0.7781    2.5916    0.5903,0.9298    0.3301    0.5548]; % this is blind modification 150 steps
    scaler0 = [1.0330    0.9935    0.7494    0.7210    1.0968    1.0527    0.8765    0.6720    1.3574]; % this is bounded modification 20% limit
    
    
    % changing in the model
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
    
    
    % input holder
    input = struct();
    
    % information
    animal_NO = DataBase.Trial(Trial_NO).Info.AnimalNum;
    animal_dia = DataBase.cockroach_model.dia(animal_NO);
    frame_num = DataBase.Trial(Trial_NO).Info.FrameNum;
    input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass;
    
    % model mat
    head_mat_origin = DataBase.cockroach_model.head(animal_NO);
    body_mat_origin = DataBase.cockroach_model.body(animal_NO);
    abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);
    
    
    %%%%%%%%%%% model modification %%%%%%%%%%%%%%%%%%
    
    head_mat= head_mat_origin;
    head_mat.vertice_position(:,1) = head_mat.vertice_position(:,1) * ratio.head.length;
    head_mat.vertice_position(:,2) = head_mat.vertice_position(:,2) * ratio.head.width;
    head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3) * ratio.head.thickness;
    
    body_mat= body_mat_origin;
    body_mat.vertice_position(:,1) = body_mat.vertice_position(:,1) * ratio.body.length;
    body_mat.vertice_position(:,2) = body_mat.vertice_position(:,2) * ratio.body.width;
    body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3) * ratio.body.thickness;
    
    abdomen_mat= abdomen_mat_origin;
    abdomen_mat.vertice_position(:,1) = abdomen_mat.vertice_position(:,1) * ratio.abdomen.length;
    abdomen_mat.vertice_position(:,2) = abdomen_mat.vertice_position(:,2) * ratio.abdomen.width;
    abdomen_mat.vertice_position(:,3) = abdomen_mat.vertice_position(:,3) * ratio.abdomen.thickness;
    
    animal_dia.total.neck_point = animal_dia.total.neck_point * ratio.body.length;
    animal_dia.total.waist_point = animal_dia.total.waist_point * ratio.body.length;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % kinematics
    body_com = DataBase.Trial(Trial_NO).modified.Cockroach.Body.com;
    body_eul = DataBase.Trial(Trial_NO).modified.Cockroach.Body.eul;
    head_eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Head.eul_b.*[0,1,0];
    abdomen_eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Abdomen_Up.eul_b.*[0,1,0];
    beam_pitch_left = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.left_pitch';
    beam_pitch_right = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.right_pitch';
    
    % create beam angle holder
    beam_pitch_left_model = NaN(length(beam_pitch_left),1);
    beam_pitch_right_model = beam_pitch_left_model;
    
    % loop frame to calculate the model beam angle
    for frame_i = 1:frame_num
        
        %         disp(frame_i)
        
        % load body frame and head/abdomen relative eul angle
        input.body.com = body_com(frame_i,:);
        input.body.eul = body_eul(frame_i,:);
        input.head.eul_b = head_eul_b(frame_i,:);
        input.abdomen.eul_b = abdomen_eul_b(frame_i,:);
        input.beam.ref_left_pitch = beam_pitch_left(frame_i);
        input.beam.ref_right_pitch = beam_pitch_right(frame_i);
        
        % calculate head and abdomen com and eul
        input = calculate_head_abdomen(animal_dia,input);
        % calculate beam angle
        input = calculate_state_stl_tribody_v2(input,body_mat,head_mat,abdomen_mat);
        
        % load beam
        beam_pitch_left_model(frame_i) = input.beam.angle_left;
        beam_pitch_right_model(frame_i) = input.beam.angle_right;
        
        % reconstruct video
        body_mat_ = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
        head_mat_ = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
        abdomen_mat_ = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
        reconstruction_visualization_stl_tribody(input,body_mat_,head_mat_,abdomen_mat_);
        
        % video recording
        if is_video == 1
            frame = getframe(gcf);
            writeVideo(v,frame);
        end
    end
    
end

% 3
if mode == 3
    scaler0 = [1,1,1,1,1,1,1,1,1];
    
    % changing in the model
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
    
    
    % input holder
    input = struct();
    
    % information
    animal_NO = DataBase.Trial(Trial_NO).Info.AnimalNum;
    animal_dia = DataBase.cockroach_model.dia(animal_NO);
    frame_num = DataBase.Trial(Trial_NO).Info.FrameNum;
    input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass;
    
    % model mat
    head_mat_origin = DataBase.cockroach_model.head(animal_NO);
    body_mat_origin = DataBase.cockroach_model.body(animal_NO);
    abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);
    
    
    %%%%%%%%%%% model modification %%%%%%%%%%%%%%%%%%
    
    head_mat= head_mat_origin;
    head_mat.vertice_position(:,1) = head_mat.vertice_position(:,1) * ratio.head.length;
    head_mat.vertice_position(:,2) = head_mat.vertice_position(:,2) * ratio.head.width;
    head_mat.vertice_position(:,3) = head_mat.vertice_position(:,3) * ratio.head.thickness;
    
    body_mat= body_mat_origin;
    body_mat.vertice_position(:,1) = body_mat.vertice_position(:,1) * ratio.body.length;
    body_mat.vertice_position(:,2) = body_mat.vertice_position(:,2) * ratio.body.width;
    body_mat.vertice_position(:,3) = body_mat.vertice_position(:,3) * ratio.body.thickness;
    
    abdomen_mat= abdomen_mat_origin;
    abdomen_mat.vertice_position(:,1) = abdomen_mat.vertice_position(:,1) * ratio.abdomen.length;
    abdomen_mat.vertice_position(:,2) = abdomen_mat.vertice_position(:,2) * ratio.abdomen.width;
    abdomen_mat.vertice_position(:,3) = abdomen_mat.vertice_position(:,3) * ratio.abdomen.thickness;
    
    animal_dia.total.neck_point = animal_dia.total.neck_point * ratio.body.length;
    animal_dia.total.waist_point = animal_dia.total.waist_point * ratio.body.length;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % kinematics
    body_com = DataBase.Trial(Trial_NO).modified.Cockroach.Body.com;
    body_eul = DataBase.Trial(Trial_NO).modified.Cockroach.Body.eul;
    head_eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Head.eul_b.*[0,1,0];
    abdomen_eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Abdomen_Up.eul_b.*[0,1,0];
    beam_pitch_left = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.left_pitch';
    beam_pitch_right = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.right_pitch';
    
    % create beam angle holder
    beam_pitch_left_model = NaN(length(beam_pitch_left),1);
    beam_pitch_right_model = beam_pitch_left_model;
    
    % loop frame to calculate the model beam angle
    for frame_i = 1:frame_num
        
        %         disp(frame_i)
        
        % load body frame and head/abdomen relative eul angle
        input.body.com = body_com(frame_i,:);
        input.body.eul = body_eul(frame_i,:);
        input.head.eul_b = [0,16/180*pi,0];
        input.abdomen.eul_b = abdomen_eul_b(frame_i,:);
        input.beam.ref_left_pitch = beam_pitch_left(frame_i);
        input.beam.ref_right_pitch = beam_pitch_right(frame_i);
        
        % calculate head and abdomen com and eul
        input = calculate_head_abdomen(animal_dia,input);
        % calculate beam angle
        input = calculate_state_stl_tribody_v2(input,body_mat,head_mat,abdomen_mat);
        
        % load beam
        beam_pitch_left_model(frame_i) = input.beam.angle_left;
        beam_pitch_right_model(frame_i) = input.beam.angle_right;
        
        % reconstruct video
        body_mat_ = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
        head_mat_ = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
        abdomen_mat_ = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
        reconstruction_visualization_stl_tribody(input,body_mat_,head_mat_,abdomen_mat_);
        
        % video recording
        if is_video == 1
            frame = getframe(gcf);
            writeVideo(v,frame);
        end
    end
    
end




% 4: plot the projection in the raw video
if mode == 4
    for Trial_NO = Trials
        for Cam_NO = Cams
            video_name = [video_folder,'Trial_',num2str(Trial_NO),'_Cam_',num2str(Cam_NO),'_Mode_4.avi'];
            
            % launch video
            if is_video == 1
                v = VideoWriter(video_name);
                open(v);
            end
            % basics
            raw_video_folder = [REPO,'/raw_videos/f2_raw_videos_36/'];
            raw_video = [raw_video_folder,'Trial_',num2str(Trial_NO),'_Cam_',num2str(Cam_NO),'.avi'];
            video_read_handler = VideoReader(raw_video);
            frame_size = [2592 2048];
            %             scaler0 = [1,1,1,1,1,1,1,1,1]; % raw
            %             shift0 = [0,0,0]; % raw
%             scaler0 = [0.7,0.9,0.4,  1,1,0.4,  1.1,1,0.4];
%             scaler0 = [0.7,0.9,0.9,  1,1,0.9,  1.1,1,0.9];
            scaler0 = [0.7,0.9,0.9,  1,1,0.9,  1.1,1,0.9];
            shift0 = [0,-1,-1]; % head, body, abdomen
            
            
            % changing in the model
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
            
            
            % input holder
            input = struct();
            
            % information
            animal_NO = DataBase.Trial(Trial_NO).Info.AnimalNum;
            animal_dia = DataBase.cockroach_model.dia(animal_NO);
            frame_num = DataBase.Trial(Trial_NO).Info.FrameNum;
            input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass;
            
            % model mat
            head_mat_origin = DataBase.cockroach_model.head(animal_NO);
            body_mat_origin = DataBase.cockroach_model.body(animal_NO);
            abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);
            
            
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
            
            animal_dia.total.neck_point = animal_dia.total.neck_point * ratio.body.length + [0,0,shift0(2)]';
            animal_dia.total.waist_point = animal_dia.total.waist_point * ratio.body.length + [0,0,shift0(2)]';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % kinematics
            body_com = DataBase.Trial(Trial_NO).modified.Cockroach.Body.com;
            body_eul = DataBase.Trial(Trial_NO).modified.Cockroach.Body.eul;
            head_eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Head.eul_b.*[0,1,0];
            abdomen_eul_b = DataBase.Trial(Trial_NO).modified.Cockroach.Abdomen_Up.eul_b.*[0,1,0];
            beam_pitch_left = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.left_pitch';
            beam_pitch_right = DataBase.Trial(Trial_NO).modified.Cockroach.Beam.right_pitch';
            
            % create beam angle holder
            beam_pitch_left_model = NaN(length(beam_pitch_left),1);
            beam_pitch_right_model = beam_pitch_left_model;
            
            % loop frame to calculate the model beam angle
            is_first_frame = 1;
            
            for frame_i = 1:frame_num 
                
                %         disp(frame_i)
                
                % load body frame and head/abdomen relative eul angle
                input.body.com = body_com(frame_i,:);
                input.body.eul = body_eul(frame_i,:);
                input.head.eul_b = head_eul_b(frame_i,:);
                input.abdomen.eul_b = abdomen_eul_b(frame_i,:);
                input.beam.ref_left_pitch = beam_pitch_left(frame_i);
                input.beam.ref_right_pitch = beam_pitch_right(frame_i);
                
                % calculate head and abdomen com and eul
                input = calculate_head_abdomen(animal_dia,input);
                % calculate beam angle
                input = calculate_state_stl_tribody_v2(input,body_mat,head_mat,abdomen_mat);
                
                % load beam
                beam_pitch_left_model(frame_i) = input.beam.angle_left;
                beam_pitch_right_model(frame_i) = input.beam.angle_right;
                
                % calculate the mat in model
                body_mat_ = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
                head_mat_ = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
                abdomen_mat_ = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
                
                %%%%%%%%%%%%%%%%%%% Different from Mode 2 %%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% Change model to the world frame, then to camera view%%%%%%%%
                % add beam corners to patch
                beam_width = 10;
                gap_width = 10;
                beam_length = 93;
                beam_left_corners_x = [0;1;1;0] * beam_length * sin(beam_pitch_left_model(frame_i));
                beam_left_corners_y = [1;1;-1,;-1] * beam_width/2 + gap_width/2 + beam_width/2 ;
                beam_left_corners_z = [0;1;1;0] * beam_length * cos(beam_pitch_left_model(frame_i));
                beam_right_corners_x = [0;1;1;0] * beam_length * sin(beam_pitch_right_model(frame_i));
                beam_right_corners_y = -([1;1;-1,;-1] * beam_width/2 + gap_width/2 + beam_width/2);
                beam_right_corners_z = [0;1;1;0] * beam_length * cos(beam_pitch_right_model(frame_i));
                beam_left_corners = [beam_left_corners_x,beam_left_corners_y,beam_left_corners_z];
                beam_right_corners = [beam_right_corners_x,beam_right_corners_y,beam_right_corners_z];
                
                % roll direction
                if (DataBase.Trial(Trial_NO).Info.RollDirection == -1)
                    body_mat_.vertice_position(:,2) = - body_mat_.vertice_position(:,2);
                    head_mat_.vertice_position(:,2) = - head_mat_.vertice_position(:,2);
                    abdomen_mat_.vertice_position(:,2) = - abdomen_mat_.vertice_position(:,2);
                    beam_left_corners(:,2) = - beam_left_corners(:,2);
                    beam_right_corners(:,2) = - beam_right_corners(:,2);
                end
                
                % shift back to world frame (using gap, bias)
                XYZ_bias = InfoNum(Trial_NO,31:33);
                total_shift = [0,DataBase.Trial(Trial_NO).Info.Gap*20-20+5,0] + XYZ_bias;
                body_mat_.vertice_position = body_mat_.vertice_position + total_shift;
                head_mat_.vertice_position = head_mat_.vertice_position + total_shift;
                abdomen_mat_.vertice_position = abdomen_mat_.vertice_position + total_shift;
                beam_left_corners = beam_left_corners + total_shift;
                beam_right_corners = beam_right_corners + total_shift;
                
                % shift to Cam view frame (using calibration)
                for i = 1:body_mat_.num_vertice
                    xyz = body_mat_.vertice_position(i,:);
                    UV = fDLT3D22D(Cal(:,Cam_NO),xyz);
                    body_mat_.vertice_position(i,1) = UV(1);
                    body_mat_.vertice_position(i,2) = frame_size(2)-UV(2);
                    body_mat_.vertice_position(i,3) = 0;
                end
                for i = 1:head_mat_.num_vertice
                    xyz = head_mat_.vertice_position(i,:);
                    UV = fDLT3D22D(Cal(:,Cam_NO),xyz);
                    head_mat_.vertice_position(i,1) = UV(1);
                    head_mat_.vertice_position(i,2) = frame_size(2)-UV(2);
                    head_mat_.vertice_position(i,3) = 0;
                end
                for i = 1:abdomen_mat_.num_vertice
                    xyz = abdomen_mat_.vertice_position(i,:);
                    UV = fDLT3D22D(Cal(:,Cam_NO),xyz);
                    abdomen_mat_.vertice_position(i,1) = UV(1);
                    abdomen_mat_.vertice_position(i,2) = frame_size(2)-UV(2);
                    abdomen_mat_.vertice_position(i,3) = 0;
                end
                for i = 1:4
                    xyz = beam_left_corners(i,:);
                    UV = fDLT3D22D(Cal(:,Cam_NO),xyz);
                    beam_left_corners(i,1) = UV(1);
                    beam_left_corners(i,2) = frame_size(2)-UV(2);
                    beam_left_corners(i,3) = 0;
                end
                for i = 1:4
                    xyz = beam_right_corners(i,:);
                    UV = fDLT3D22D(Cal(:,Cam_NO),xyz);
                    beam_right_corners(i,1) = UV(1);
                    beam_right_corners(i,2) = frame_size(2)-UV(2);
                    beam_right_corners(i,3) = 0;
                end
                
                % load and patch
                raw_video_frame = read(video_read_handler,frame_i);
                body_patchable = mat2stl_patchable_YW(body_mat_);
                head_patchable = mat2stl_patchable_YW(head_mat_);
                abdomen_patchable = mat2stl_patchable_YW(abdomen_mat_);
                
                if is_first_frame == 1
                    is_first_frame = 0;
                    
                    fig_handler = figure(4);
                    set(gcf,'Position',[2000,500,frame_size/4]);
                    set(gca,'Position',[0,0,1,1]);
                    xlim([0,frame_size(1)]);
                    ylim([0,frame_size(2)]);
                    
                    hold on;
                    
                    background_handler = imshow(raw_video_frame);
                    
                    body_handler = patch(...
                        body_patchable,...
                        'FaceColor',       [0.9294,0.6902,0.1294], ...
                        'EdgeColor',       'none',        ...
                        'FaceAlpha',       0.3,             ...
                        'FaceLighting',    'gouraud',     ...
                        'AmbientStrength', 0.15);
                    
                    head_handler = patch(...
                        head_patchable,...
                        'FaceColor',       'r', ...
                        'EdgeColor',       'none',        ...
                        'FaceAlpha',       0.3,             ...
                        'FaceLighting',    'gouraud',     ...
                        'AmbientStrength', 0.15);
                    
                    
                    abdomen_handler = patch(...
                        abdomen_patchable,...
                        'FaceColor',       [1,1,0.2], ...
                        'EdgeColor',       'none',        ...
                        'FaceAlpha',       0.3,             ...
                        'FaceLighting',    'gouraud',     ...
                        'AmbientStrength', 0.15);
                    
                    beam_left_handler = patch('XData',beam_left_corners(:,1),'YData',beam_left_corners(:,2),'ZData',beam_left_corners(:,3),...
                        'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',1);
                    beam_right_handler = patch('XData',beam_right_corners(:,1),'YData',beam_right_corners(:,2),'ZData',beam_right_corners(:,3),...
                        'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',1);
                    
                else
                    background_handler.CData = raw_video_frame;
                    body_handler.Vertices = body_patchable.vertices;
                    head_handler.Vertices = head_patchable.vertices;
                    abdomen_handler.Vertices = abdomen_patchable.vertices;
                    beam_left_handler.Vertices = beam_left_corners;
                    beam_right_handler.Vertices = beam_right_corners;
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % video recording
                if is_video == 1
                    frame = getframe(gcf);
                    writeVideo(v,frame);
                end
            end
            if is_video == 1
                close(v);
            end
        end
    end
end


if is_video == 1
    close(v);
    close all;
    disp("Finish!");
end
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
% Yaqing created this on 2020/07/27 to (manually) find a better body shrink
% ratio and beam angle shrink ratio
% Four parameter as result:
%   1. body shrink ratio:           body_ratio
%   2. beam angle shrink ratio:     beam_ratio
%   3. axis shift or not:           is_axis_shift
%   4. abdomen transparent or not:  is_ab_trans

%   5. thick shrink ratio:          thick_ratio

save_path = [REPO,'/output/YW_temp_1/'];

is_new_method = 1; % 1, nearest beam angle 0, maximum beam angle
left_angle_diffs = [];
right_angle_diffs = [];

is_plotted = 0;
is_calculate_difference = 1;
result = nan(36,8);

% guess
body_ratio = 1;
beam_ratio = 1;
thick_ratio = 1;
is_axis_shift = 1;
is_ab_trans = 0;


% settings
for trial_i = 1:36
    % trial_i = 4;
    is_reconstruct = 0;
    a_thresh = -100;
    beam_stiff = 2.5;
    
    % basic
    addpath([REPO,'/code/model_construction/Dependences_stl']);
    %%% load database
    load([REPO,'/data/kinematics/DataBase.mat']);
    
    % information
    animal_NO = DataBase.Trial(trial_i).Info.AnimalNum;
    animal_dia = DataBase.cockroach_model.dia(animal_NO);
    frame_num = DataBase.Trial(trial_i).Info.FrameNum;
    input.total.mass = DataBase.cockroach_model.dia(animal_NO).total.mass;
    
    % model mat
    head_mat_origin = DataBase.cockroach_model.head(animal_NO);
    body_mat_origin = DataBase.cockroach_model.body(animal_NO);
    abdomen_mat_origin = DataBase.cockroach_model.abdomen(animal_NO);
    
    % kinematics
    body_com = DataBase.Trial(trial_i).modified.Cockroach.Body.com;
    body_eul = DataBase.Trial(trial_i).modified.Cockroach.Body.eul;
    head_eul_b = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b.*[0,1,0];
    abdomen_eul_b = DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b.*[0,1,0];
    beam_pitch_left = DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch';
    beam_pitch_right = DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch';
    
    % zero beam
    beam_pitch_left = beam_pitch_left-nanmean(beam_pitch_left(1:10));
    beam_pitch_right = beam_pitch_right-nanmean(beam_pitch_right(1:10));
    
    
    scaler0 = [0.7,0.9,0.9,  1,1,0.9,  1,1,0.9];
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
    input.is_ab_trans = is_ab_trans;
    input.mass_bias_b = shift0';
    input.beam_cal_re = 0;
    
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
        animal_dia_.total.neck_point = animal_dia.total.neck_point * ratio.body.length + [0,0,shift0(2)]';
        animal_dia_.total.waist_point = animal_dia.total.waist_point * ratio.body.length + [0,0,shift0(2)]';
    else
        animal_dia_.total.neck_point = animal_dia.total.neck_point;
        animal_dia_.total.waist_point = animal_dia.total.waist_point;
    end
    
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
        input = calculate_head_abdomen(animal_dia_,input);
        % calculate beam angle
        input = calculate_state_stl_tribody_v2(input,body_mat,head_mat,abdomen_mat);
        
        % load beam
        beam_pitch_left_model(frame_i) = input.beam.angle_left;
        beam_pitch_right_model(frame_i) = input.beam.angle_right;
        
        % reconstruct video
        if is_reconstruct
            body_mat_ = stl_SE3_YW(body_mat,[input.body.eul,input.body.com]);
            head_mat_ = stl_SE3_YW(head_mat,[input.head.eul,input.head.com]);
            abdomen_mat_ = stl_SE3_YW(abdomen_mat,[input.abdomen.eul,input.abdomen.com]);
            reconstruction_visualization_stl_tribody(input,body_mat_,head_mat_,abdomen_mat_);
        end
    end
    
    % beam_ratio
    beam_pitch_left_model = beam_pitch_left_model * beam_ratio;
    beam_pitch_right_model = beam_pitch_right_model * beam_ratio;
    
    % calculate the difference
    if is_calculate_difference == 1
        % calculate the difference 
        % a. from touch to RollStartFrame
        % b. from RollStartFrame to Roll60inFrame
        % 1. max absolute difference
        % 2. average absolute difference
        % result: left a1, a2, b1, b2, right
        
        left_diff_absolute = abs(beam_pitch_left_model-beam_pitch_left);
        right_diff_absolute = abs(beam_pitch_right_model-beam_pitch_right);
        
        left_angle_diffs = [left_angle_diffs, left_diff_absolute'];
        right_angle_diffs = [right_angle_diffs,right_diff_absolute'];
        
        result(trial_i,1) = nanmax(left_diff_absolute(DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame));
        result(trial_i,2) = nanmean(left_diff_absolute(DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame));
        result(trial_i,3) = nanmax(left_diff_absolute(DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.Roll60inFrame));
        result(trial_i,4) = nanmean(left_diff_absolute(DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.Roll60inFrame));
        result(trial_i,5) = nanmax(right_diff_absolute(DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame));
        result(trial_i,6) = nanmean(right_diff_absolute(DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame));
        result(trial_i,7) = nanmax(right_diff_absolute(DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.Roll60inFrame));
        result(trial_i,8) = nanmean(right_diff_absolute(DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.Roll60inFrame));
    end
        
    
    
    % plot figure
    if is_plotted == 1
        
        % sp1: left beam angle
        % sp2: right beam angle
        % sp3: sum(beam angle ^ 2)
        
        figure();
        set(gcf,'Position',[2000,100,1800,1000]);
        hold on;
        suptitle(['Trial: ',num2str(trial_i)],'FontSize',30);
        
        sp1 = subplot('Position',[0.025,0.5,0.45,0.4]);
        hold on;
        p11 = plot(beam_pitch_left_model*180/pi,'LineWidth',3);
        p12 = plot(beam_pitch_left*180/pi,'LineWidth',3);
        set(gca,'FontSize',20);
        sp1a = gca;
        ylim = sp1a.YLim;
        line([1,1]*DataBase.Trial(trial_i).Info.TouchFrame,ylim,'LineStyle',':','Color','k','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollStartFrame,ylim,'LineStyle',':','Color','b','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.Roll60inFrame,ylim,'LineStyle',':','Color','g','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollMaxFrame,ylim,'LineStyle',':','Color','r','LineWidth',3)
        legend([p11,p12],{"Beam angle (°,facing) - model","Beam angle (°,facing) - ground truth"},'Location','southwest')
        box on;
        grid on;
        
        sp2 = subplot('Position',[0.025,0.05,0.45,0.4]);
        hold on;
        p21 = plot(beam_pitch_right_model*180/pi,'LineWidth',3);
        p22 = plot(beam_pitch_right*180/pi,'LineWidth',3);
        set(gca,'FontSize',20);
        sp2a = gca;
        ylim = sp2a.YLim;
        line([1,1]*DataBase.Trial(trial_i).Info.TouchFrame,ylim,'LineStyle',':','Color','k','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollStartFrame,ylim,'LineStyle',':','Color','b','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.Roll60inFrame,ylim,'LineStyle',':','Color','g','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollMaxFrame,ylim,'LineStyle',':','Color','r','LineWidth',3)
        legend([p21,p22],{"Beam angle (°,back) - model","Beam angle (°,back) - ground truth"},'Location','northwest')
        box on;
        grid on;
        
        sp3 = subplot('Position',[0.525,0.3,0.45,0.6]);
        hold on;
        p31 = plot((beam_pitch_left_model.*beam_pitch_left_model+beam_pitch_right_model.*beam_pitch_right_model)*beam_stiff,'LineWidth',3);
        p32 = plot((beam_pitch_left.*beam_pitch_left+beam_pitch_right.*beam_pitch_right)*beam_stiff,'LineWidth',3);
        set(gca,'FontSize',20);
        sp3a = gca;
        ylim = sp3a.YLim;
        line([1,1]*DataBase.Trial(trial_i).Info.TouchFrame,ylim,'LineStyle',':','Color','k','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollStartFrame,ylim,'LineStyle',':','Color','b','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.Roll60inFrame,ylim,'LineStyle',':','Color','g','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollMaxFrame,ylim,'LineStyle',':','Color','r','LineWidth',3)
        legend([p31,p32],{"Elastic energy - model","Elastic energy - ground truth"},'Location','northeast')
        box on;
        grid on;
        
        
        %     str = {['body ratio:   ',num2str(body_ratio)],...
        %         ['beam ratio:  ',num2str(beam_ratio)],...
        %         ['thick ratio:  ',num2str(thick_ratio)],...
        %         ['is axis shift: ',num2str(is_axis_shift)],...
        %         ['is ab trans:  ',num2str(is_ab_trans)]};
        %     the_box = annotation('textbox',[0.6,0.05,0.3,0.2],'String',str,'FitBoxToText','on','FontSize',30);
        
        saveas(gcf,[save_path,'Trial_',num2str(trial_i),'.jpg']);
        close all;
    end
end

result =result * 180/pi;

disp(nanmean([left_angle_diffs,right_angle_diffs]) * 180/pi);
disp(nanstd([left_angle_diffs,right_angle_diffs]) * 180/pi);
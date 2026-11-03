REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
% Yaqing created this on 2020/07/27 to (manually) find a better body shrink
% ratio and beam angle shrink ratio
% Four parameter as result:
%   1. body shrink ratio:           body_ratio
%   2. beam angle shrink ratio:     beam_ratio
%   3. axis shift or not:           is_axis_shift
%   4. abdomen transparent or not:  is_ab_trans

%   5. thick shrink ratio:          thick_ratio

% guess
body_ratio = 1;
beam_ratio = 1;
thick_ratio = 1;
is_axis_shift = 1;
is_ab_trans = 0;


% settings
trial_i = 1;
is_reconstruct = 0;
a_thresh = -100;

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


is_plotted = 0;
while (1)
    
    % interface
    %   1. body shrink ratio:           body_ratio
    %   2. beam angle shrink ratio:     beam_ratio
    %   3. axis shift or not:           is_axis_shift
    %   4. abdomen transparent or not:  is_ab_trans
    prompt = {'1: body_ratio','2: beam_ratio','3: thick_ratio','4: is_axis_shift','5: is_ab_trans'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {num2str(body_ratio),num2str(beam_ratio),num2str(thick_ratio),num2str(is_axis_shift),num2str(is_ab_trans)};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    % enter
    body_ratio = str2num(answer{1});
    beam_ratio = str2num(answer{2});
    thick_ratio = str2num(answer{3});
    is_axis_shift = str2num(answer{4});
    is_ab_trans = str2num(answer{5});
    
    
    % changing in the model
    ratio = struct();
    ratio.head.length = body_ratio;
    ratio.head.width = body_ratio;
    ratio.head.thickness = thick_ratio;
    ratio.body.length = body_ratio;
    ratio.body.width = body_ratio;
    ratio.body.thickness = thick_ratio;
    ratio.abdomen.length = body_ratio;
    ratio.abdomen.width = body_ratio;
    ratio.abdomen.thickness = thick_ratio;
    
    % input holder
    input = struct();
    input.is_ab_trans = is_ab_trans;
    
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
    
    if is_axis_shift
        animal_dia_.total.neck_point = animal_dia.total.neck_point * ratio.body.length;
        animal_dia_.total.waist_point = animal_dia.total.waist_point * ratio.body.length;
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
    
    % plot figure
    if is_plotted == 0
        is_plotted = 1;
        
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
        legend([p11,p12],{"Beam angle (left) - model","Beam angle (left) - ground truth"},'Location','southwest')
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
        legend([p21,p22],{"Beam angle (right) - model","Beam angle (right) - ground truth"},'Location','northwest')
        box on;
        grid on;
        
        sp3 = subplot('Position',[0.525,0.3,0.45,0.6]);
        hold on;
        p31 = plot((beam_pitch_left_model+beam_pitch_right_model).*(beam_pitch_left_model+beam_pitch_right_model)*180/pi*180/pi,'LineWidth',3);
        p32 = plot((beam_pitch_left+beam_pitch_right).*(beam_pitch_left+beam_pitch_right)*180/pi*180/pi,'LineWidth',3);
        set(gca,'FontSize',20);
        sp3a = gca;
        ylim = sp3a.YLim;
        line([1,1]*DataBase.Trial(trial_i).Info.TouchFrame,ylim,'LineStyle',':','Color','k','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollStartFrame,ylim,'LineStyle',':','Color','b','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.Roll60inFrame,ylim,'LineStyle',':','Color','g','LineWidth',3)
        line([1,1]*DataBase.Trial(trial_i).Info.RollMaxFrame,ylim,'LineStyle',':','Color','r','LineWidth',3)
        legend([p31,p32],{"Beam angle^2 - model","Beam angle^2 - ground truth"},'Location','northeast')
        box on;
        grid on;
        
        
        str = {['body ratio:   ',num2str(body_ratio)],...
            ['beam ratio:  ',num2str(beam_ratio)],...
            ['thick ratio:  ',num2str(thick_ratio)],...
            ['is axis shift: ',num2str(is_axis_shift)],...
            ['is ab trans:  ',num2str(is_ab_trans)]};
        the_box = annotation('textbox',[0.6,0.05,0.3,0.2],'String',str,'FitBoxToText','on','FontSize',30);
        
    else
        
        p11.YData = beam_pitch_left_model*180/pi;
        p21.YData = beam_pitch_right_model*180/pi;
        p31.YData = (beam_pitch_left_model+beam_pitch_right_model).*(beam_pitch_left_model+beam_pitch_right_model)*180/pi*180/pi;
        % fix y limit
        y_limit_up = max([p11.YData,p12.YData])+5;
        y_limit_down = min([p11.YData,p12.YData])-5;
        sp1a.YLim = [y_limit_down,y_limit_up];
        y_limit_up = max([p21.YData,p22.YData])+5;
        y_limit_down = min([p21.YData,p22.YData])-5;
        sp2a.YLim = [y_limit_down,y_limit_up];
        y_limit_up = max([p31.YData,p32.YData])+5;
        y_limit_down = min([p31.YData,p32.YData])-5;
        sp3a.YLim = [y_limit_down,y_limit_up];
        
        
        str = {['body ratio:   ',num2str(body_ratio)],...
            ['beam ratio:  ',num2str(beam_ratio)],...
            ['thick ratio:  ',num2str(thick_ratio)],...
            ['is axis shift: ',num2str(is_axis_shift)],...
            ['is ab trans:  ',num2str(is_ab_trans)]};
        the_box.String = str;
    end
end

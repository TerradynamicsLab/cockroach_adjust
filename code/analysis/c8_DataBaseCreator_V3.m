%%% Yaqing created this file on 11012018 to create data base for further analyze
%%% Modified on 02/14/2018
%%% Modified again on 6/23/2020

close all;clear;clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

is_re = 0;

%%  Create DataBase
if is_re == 1
    save_file = [REPO,'/data/kinematics/DataBase_re.mat'];
else
    save_file = [REPO,'/data/kinematics/DataBase.mat'];
end

DataBase = {};
% DataBase Structure
% DataBase
% 	Vision                                        %Vision of the data base creator code
% 	Date                                          %what date is it?
% 	TrialNum                                      %how many Trials do you have.  Basiclly Trial 1 is calibration
% 	Trial(n)
%         Info                                    %
%             NameSuffix                          %
%             AnimalNum                           %
%             Tempurature                         %
%             RollDirection                       %
%             Frame                               %
%                 Num                             %
%                 Enter                           %
%                 Touch                           %
%                 TraverseStart                   %
%                 TraverseEnd                     %
%                 Leave                           %
%         raw
%             Cockroach
%                 Body                                %
%                     Position                        %
%                     Rotm                            %
%                     YPR                             %
%                 Head                                %
%                     Position                        %
%                     Rotm                            %
%                     YPR                             %
%                 Abdomen
%                     Point(4)                        %
%                         Position                    %
%                 Leg
%                     L
%                     R
%                         Position
%             Beam
%                 Left                                %
%                     Pitch                           %
%                 Right                               %
%                     Pitch                           %
%         Modified
%             cockroach_model
%             cockroach
%                 head
%                     com f*3   mm
%                     eul f*3   rad
%                     eul_b f*3 rad
%                 body
%                     com f*3   mm
%                     eul f*3   rad
%                 abdomen_Up
%                     eul f*3   rad
%                     eul_b f*3 rad
%                 abdomen_Down
%                     eul f*3   rad
%                     eul_u f*3 rad
%                 leg
%                     left_position_b
%                     right_position_b
%             beam
%                 right_pitch
%                 left_pitch

%%  Basic Input
DataBase.Vision = 3;
DataBase.Date = '20200623';
DataBase.TrialNum = 36;
MainFolder = [REPO,'/data/kinematics/'];
InfoFile = [REPO,'/data/info/Info.xlsx'];
PT_data_file = [REPO,'/data/kinematics/point_tag_data.mat'];

%  Loading Info in each Trial
[InfoNum,InfoText] = xlsread(InfoFile,'selected_36');
[m,n] = size(InfoText);
for i=1:n
    %  Loading NameSuffix
    if string(InfoText(1,i)) == "RawName"
        for j=1:DataBase.TrialNum
            RawName = char(InfoText(j+1,i));
            DataBase.Trial(j).Info.NameSuffix = RawName;
        end
        continue;
    end
    %  Loading FrameNum
    if string(InfoText(1,i)) == "FrameNum"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.FrameNum = InfoNum(j,i);
        end
        continue;
    end
    %  Loading EnterFrame
    if string(InfoText(1,i)) == "EnterFrame"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.EnterFrame = InfoNum(j,i);
        end
        continue;
    end
    %  Loading TouchFrame
    if string(InfoText(1,i)) == "TouchFrame"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.TouchFrame = InfoNum(j,i);
        end
        continue;
    end
    %  Loading LeaveFrame
    if string(InfoText(1,i)) == "LeaveFrame"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.LeaveFrame = InfoNum(j,i);
        end
        continue;
    end
    %  Loading RollDirection
    if string(InfoText(1,i)) == "RollDirection"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.RollDirection = InfoNum(j,i);
        end
        continue;
    end
    %  Loading AnimalNum
    if string(InfoText(1,i)) == "AnimalID"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.AnimalNum = InfoNum(j,i);
        end
        continue;
    end
    %  Loading Gap
    if string(InfoText(1,i)) == "Gap"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.Gap = InfoNum(j,i);
        end
        continue;
    end
    %  Loading LandFrame
    if string(InfoText(1,i)) == "LandFrame"
        for j=1:DataBase.TrialNum
            DataBase.Trial(j).Info.LandFrame = InfoNum(j,i);
        end
        continue;
    end
    
end

%  From Tracking
for trial_i = 1:DataBase.TrialNum
    XYZ_bias = InfoNum(trial_i,31:33);
    
    PT_data = load(PT_data_file);
    PT_data = PT_data.PT_data;
    
    %  Loading BodyTag
    DataBase.Trial(trial_i).raw.Cockroach.Body.Position = PT_data.tag.trial(trial_i).tag(1).xyz;
    DataBase.Trial(trial_i).raw.Cockroach.Body.Rotm = PT_data.tag.trial(trial_i).tag(1).Rotation;
    DataBase.Trial(trial_i).raw.Cockroach.Body.YPR = [PT_data.tag.trial(trial_i).tag(1).yaw',...
        PT_data.tag.trial(trial_i).tag(1).pitch',PT_data.tag.trial(trial_i).tag(1).roll'];
    
    %  Loading HeadTag
    DataBase.Trial(trial_i).raw.Cockroach.Head.Position = PT_data.tag.trial(trial_i).tag(2).xyz;
    DataBase.Trial(trial_i).raw.Cockroach.Head.Rotm = PT_data.tag.trial(trial_i).tag(2).Rotation;
    DataBase.Trial(trial_i).raw.Cockroach.Head.YPR = [PT_data.tag.trial(trial_i).tag(2).yaw',...
        PT_data.tag.trial(trial_i).tag(2).pitch',PT_data.tag.trial(trial_i).tag(2).roll'];
    
    %  Loading Beam Data
    %     DataBase.Trial(trial_i).raw.Beam.Left.Pitch = PT_data.tag.trial(trial_i).tag(3).pitch';
    %     DataBase.Trial(trial_i).raw.Beam.Right.Pitch = PT_data.tag.trial(trial_i).tag(4).pitch';
    DataBase.Trial(trial_i).raw.Beam.Left.Pitch = atan((PT_data.tag.trial(trial_i).tag(3).xyz(:,1)-XYZ_bias(1))./(PT_data.tag.trial(trial_i).tag(3).xyz(:,3)-XYZ_bias(3)));
    DataBase.Trial(trial_i).raw.Beam.Right.Pitch = atan((PT_data.tag.trial(trial_i).tag(4).xyz(:,1)-XYZ_bias(1))./(PT_data.tag.trial(trial_i).tag(4).xyz(:,3)-XYZ_bias(3)));
    
    %  Loading Abdomen Point
    for p = 5:8
        DataBase.Trial(trial_i).raw.Cockroach.Abdomen.Point(p-4).Position = [PT_data.point.trial(trial_i).point(p).xyz];
    end
    
    %  Loading Leg Point
    DataBase.Trial(trial_i).raw.Cockroach.Leg.L.Position = [PT_data.point.trial(trial_i).point(1).xyz];
    DataBase.Trial(trial_i).raw.Cockroach.Leg.R.Position = [PT_data.point.trial(trial_i).point(4).xyz];
    
end

%% Modify the data for better analysis

% load cockroach model
if is_re == 1
    load([REPO,'/data/cockroach_model/f2_SW_model_V1_re/cockroach_model.mat']);
else
    load([REPO,'/data/cockroach_model/f1_SW_model_V1/cockroach_model.mat']);
end
DataBase.cockroach_model = cockroach_model;


for trial_i = 1:DataBase.TrialNum
    % Deal with tags
    DataBase.Trial(trial_i).modified.Cockroach.Body.eul = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Body.com = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Head.eul = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Head.com = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    % load data just collected
    body_tag_x = DataBase.Trial(trial_i).raw.Cockroach.Body.Position(:,1);
    body_tag_y = DataBase.Trial(trial_i).raw.Cockroach.Body.Position(:,2);
    body_tag_z = DataBase.Trial(trial_i).raw.Cockroach.Body.Position(:,3);
    body_tag_yaw = DataBase.Trial(trial_i).raw.Cockroach.Body.YPR(:,1);
    body_tag_p = DataBase.Trial(trial_i).raw.Cockroach.Body.YPR(:,2);
    body_tag_r = DataBase.Trial(trial_i).raw.Cockroach.Body.YPR(:,3);
    head_tag_yaw = DataBase.Trial(trial_i).raw.Cockroach.Head.YPR(:,1);
    head_tag_p = DataBase.Trial(trial_i).raw.Cockroach.Head.YPR(:,2);
    head_tag_r = DataBase.Trial(trial_i).raw.Cockroach.Head.YPR(:,3);
    
    % Interplate NaNs in the middle
    frames_temp = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame;
    body_tag_x(frames_temp) = fLinearInterpolation_YW(body_tag_x(frames_temp));
    body_tag_y(frames_temp) = fLinearInterpolation_YW(body_tag_y(frames_temp));
    body_tag_z(frames_temp) = fLinearInterpolation_YW(body_tag_z(frames_temp));
    body_tag_yaw(frames_temp) = fLinearInterpolation_YW(body_tag_yaw(frames_temp));
    body_tag_p(frames_temp) = fLinearInterpolation_YW(body_tag_p(frames_temp));
    body_tag_r(frames_temp) = fLinearInterpolation_YW(body_tag_r(frames_temp));
    head_tag_yaw(frames_temp) = fLinearInterpolation_YW(head_tag_yaw(frames_temp));
    head_tag_p(frames_temp) = fLinearInterpolation_YW(head_tag_p(frames_temp));
    head_tag_r(frames_temp) = fLinearInterpolation_YW(head_tag_r(frames_temp));
    body_tag_com = [body_tag_x,body_tag_y,body_tag_z];
    body_tag_eul = [body_tag_yaw,body_tag_p,body_tag_r];
    head_tag_eul = [head_tag_yaw,head_tag_p,head_tag_r];
    
    % Shift tags position to the world
    XYZ_bias = InfoNum(trial_i,31:33);
    body_tag_com = body_tag_com + ones(DataBase.Trial(trial_i).Info.FrameNum,3).*[-[0,DataBase.Trial(trial_i).Info.Gap*20-20+5,0]-XYZ_bias];
    trans_e2t = load([[REPO,'/data/kinematics/f1_tag2stl/'],...
        'Animal_',num2str(DataBase.Trial(trial_i).Info.AnimalNum),'.mat']);
    body_Re2t = eul2rotm(trans_e2t.EULbe2bt);
    body_Te2t = [body_Re2t,trans_e2t.Pbe2bt;0,0,0,1];
    body_Tt2e = [body_Re2t',-body_Re2t'*trans_e2t.Pbe2bt;0,0,0,1];
    head_Re2t = eul2rotm(trans_e2t.EULhe2ht);
    head_Rt2e = head_Re2t';
    for f = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
        body_Tw2t = [eul2rotm(body_tag_eul(f,:)),body_tag_com(f,:)';0,0,0,1];
        body_Tw2e = body_Tw2t * body_Tt2e;
        body_eul = rotm2eul(body_Tw2e(1:3,1:3));
        body_com = body_Tw2e(1:3,4)';
        head_Rw2t = eul2rotm(head_tag_eul(f,:));
        head_Rw2e = head_Rw2t * head_Rt2e;
        head_eul = rotm2eul(head_Rw2e);
        head_com = body_com +(body_Tw2e(1:3,1:3) * cockroach_model.dia(DataBase.Trial(trial_i).Info.AnimalNum).total.neck_point)';
        head_eul_b = rotm2eul(body_Tw2e(1:3,1:3)'*head_Rw2e);
        DataBase.Trial(trial_i).modified.Cockroach.Body.com(f,1:3) = body_com;
        DataBase.Trial(trial_i).modified.Cockroach.Body.eul(f,1:3) = body_eul;
        DataBase.Trial(trial_i).modified.Cockroach.Head.eul(f,1:3) = head_eul;
        DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(f,1:3) = head_eul_b;
        DataBase.Trial(trial_i).modified.Cockroach.Head.com(f,1:3) = head_com;
    end
    
    % Deal with abdomen
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul_u = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    for f = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
        body_Tw2t = [eul2rotm(body_tag_eul(f,:)),body_tag_com(f,:)';0,0,0,1];
        body_Tw2e = body_Tw2t * body_Tt2e;
        P1xyz = DataBase.Trial(trial_i).raw.Cockroach.Abdomen.Point(1).Position(f,1:3);
        P2xyz = DataBase.Trial(trial_i).raw.Cockroach.Abdomen.Point(2).Position(f,1:3);
        P3xyz = DataBase.Trial(trial_i).raw.Cockroach.Abdomen.Point(3).Position(f,1:3);
        P4xyz = DataBase.Trial(trial_i).raw.Cockroach.Abdomen.Point(4).Position(f,1:3);
        ac = P1xyz-P2xyz;
        bc = P1xyz-P4xyz;
        abn = norm(P2xyz-P4xyz);
        cdn = norm(cross(ac,bc))/abn;
        adn = sqrt(norm(ac)^2-cdn^2);
        Pdxyz = P2xyz+(P4xyz-P2xyz)*(adn/abn);
        xaxis = (P1xyz-Pdxyz)/norm(P1xyz-Pdxyz);
        yaxis = (P2xyz-Pdxyz)/norm(P2xyz-Pdxyz);
        zaxis = cross(xaxis,yaxis);
        Abdomen_Up_Rotm = [xaxis',yaxis',zaxis'];
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(f,1:3) = rotm2eul(Abdomen_Up_Rotm);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(f,1:3) = rotm2eul(body_Tw2e(1:3,1:3)'*Abdomen_Up_Rotm);
        
        ac = P2xyz-P3xyz;
        bc = P4xyz-P3xyz;
        abn = norm(P2xyz-P4xyz);
        cdn = norm(cross(ac,bc))/abn;
        adn = sqrt(norm(ac)^2-cdn^2);
        Pdxyz = P2xyz+(P4xyz-P2xyz)*(adn/abn);
        xaxis = (Pdxyz-P3xyz)/norm(Pdxyz-P3xyz);
        yaxis = (P2xyz-Pdxyz)/norm(P2xyz-Pdxyz);
        zaxis = cross(xaxis,yaxis);
        Abdomen_Down_Rotm = [xaxis',yaxis',zaxis'];
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul(f,1:3) = rotm2eul(Abdomen_Down_Rotm);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul_u(f,1:3) = rotm2eul(Abdomen_Up_Rotm'*Abdomen_Down_Rotm);
    end
    
    % Deal with legs
    DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b = NaN(DataBase.Trial(trial_i).Info.FrameNum,3);
    
    for f = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
        body_Tw2t = [eul2rotm(body_tag_eul(f,:)),body_tag_com(f,:)';0,0,0,1];
        body_Tw2e = body_Tw2t * body_Tt2e;
        inv_body_Tw2e = [body_Tw2e(1:3,1:3)',-body_Tw2e(1:3,1:3)'*body_Tw2e(1:3,4);0,0,0,1];
        left_position_w = [DataBase.Trial(trial_i).raw.Cockroach.Leg.L.Position(f,:)';1]-[0,DataBase.Trial(trial_i).Info.Gap*20-20+5,0,0]'-[XYZ_bias,0]';
        left_position_b = inv_body_Tw2e*left_position_w;
        DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(f,1:3) = left_position_b(1:3)';
        right_position_w = [DataBase.Trial(trial_i).raw.Cockroach.Leg.R.Position(f,:)';1]-[0,DataBase.Trial(trial_i).Info.Gap*20-20+5,0,0]'-[XYZ_bias,0]';
        right_position_b = inv_body_Tw2e*right_position_w;
        DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(f,1:3) = right_position_b(1:3)';
    end
    
    % Deal with beam
    %%% left
    %%%%% interplation
    left_pitch = fLinearInterpolation_YW(DataBase.Trial(trial_i).raw.Beam.Left.Pitch);
    %%%%% smooth
    left_pitch = fadaptiveB(left_pitch',100,5,20,6);
    DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch = left_pitch;
    %%%%% zero (enter -> touch-1 )
    %     DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch = left_pitch - nanmean(left_pitch(DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame-1));
    %%% Right
    %%%%% interplation
    right_pitch = fLinearInterpolation_YW(DataBase.Trial(trial_i).raw.Beam.Right.Pitch);
    %%%%% smooth
    right_pitch = fadaptiveB(right_pitch',100,5,20,6);
    DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch = right_pitch;
    %%%%% zero (enter -> touch-1 )
    %     DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch = right_pitch - nanmean(right_pitch(DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame-1));
    
    %% Mirror when roll dir == -1
    if (DataBase.Trial(trial_i).Info.RollDirection == -1)
        DataBase.Trial(trial_i).modified.Cockroach.Body.com(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Body.com(:,2);
        DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3);
        
        DataBase.Trial(trial_i).modified.Cockroach.Head.com(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Head.com(:,2);
        DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul(:,3);
        DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,3);
        
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul(:,3);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,3);
        
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul(:,3);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul_u(:,1) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul_u(:,1);
        DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul_u(:,3) = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Down.eul_u(:,3);
        
        Old_left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,1:3);
        Old_right_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,1:3);
        DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,1:3) = Old_right_position_b;
        DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(:,2);
        DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,1:3) = Old_left_position_b;
        DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,2) = -DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(:,2);
        
        Old_beam_left_ptich = DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch;
        DataBase.Trial(trial_i).modified.Cockroach.Beam.left_pitch = DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch;
        DataBase.Trial(trial_i).modified.Cockroach.Beam.right_pitch = Old_beam_left_ptich;
    end
    
    %% Set RollMaxFrame, RollStartFrame, RollEndFrame, reset leaveframe
    body_roll = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,end)*180/pi;
    [~,RollMaxFrame] = nanmax(body_roll);
    DataBase.Trial(trial_i).Info.RollMaxFrame = RollMaxFrame;
    
    for RollStartFrame = RollMaxFrame:-1:1
        if isnan(body_roll(RollStartFrame))
            break;
        end
        if body_roll(RollStartFrame)<0
            break;
        end
    end
    DataBase.Trial(trial_i).Info.RollStartFrame = RollStartFrame;
    
    for RollEndFrame = RollMaxFrame:DataBase.Trial(trial_i).Info.FrameNum
        if isnan(body_roll(RollEndFrame))
            break;
        end
        if body_roll(RollEndFrame)<20
            break;
        end
    end
    DataBase.Trial(trial_i).Info.RollEndFrame = RollEndFrame;
    
    for Roll60inFrame = RollMaxFrame:-1:1
        if isnan(body_roll(Roll60inFrame))
            break;
        end
        if body_roll(Roll60inFrame)<60
            break;
        end
    end
    DataBase.Trial(trial_i).Info.Roll60inFrame = Roll60inFrame;
    
    for Roll60outFrame = RollMaxFrame:DataBase.Trial(trial_i).Info.FrameNum
        if isnan(body_roll(Roll60outFrame))
            break;
        end
        if body_roll(Roll60outFrame)<60
            break;
        end
    end
    DataBase.Trial(trial_i).Info.Roll60outFrame = Roll60outFrame;
    
    for leaveframe = DataBase.Trial(trial_i).Info.LeaveFrame:-1:1
        if ~isnan(body_roll(leaveframe))
            break;
        end
    end
    DataBase.Trial(trial_i).Info.LeaveFrame = leaveframe;
    
    
end


%%  Save File
save(save_file,'DataBase');







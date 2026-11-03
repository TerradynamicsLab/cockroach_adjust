% Yaqing created this on 06/24/2020 to create the simple bar plots and line
% plots in the paper
% 06/28/2020, revised to contain 6 phases
% Run, Pitch, Transition, Roll, Land, Run2
% the seperation: touchframe, roll = 20,  roll = 60, roll = 60, landframe

close all;clear;clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root


%%
save_folder = [REPO,'/data/kinematics/simple_plot/double_bar/'];

%%  Load DataBase
DataBase_file = [REPO,'/data/kinematics/DataBase'];
load(DataBase_file);

% create the data holder
DataTemp = struct();

All_trial = 1:DataBase.TrialNum;
PitchRoll_trial = [1:6,13:18,25:30];
PureRoll_trial = [7:12,19:24,31:36];

%%%%%%%%%%%%%%Customize%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% 4 phase %%%%%%%%%%%%%%%%%
trial_series1 = PitchRoll_trial;
trial_series2 = PureRoll_trial;
series = '_doubleBar_4phase';
phase_num = 4;

phase_color = [
    0,1,0;
    0,0,1;
    0.93,0.69,0.13;
    0.47,0.67,0.19;
    ];

for trial_i = 1:DataBase.TrialNum
    frame_span(trial_i,1:phase_num,1:2) = [
        DataBase.Trial(trial_i).Info.EnterFrame,DataBase.Trial(trial_i).Info.TouchFrame;
        DataBase.Trial(trial_i).Info.TouchFrame,DataBase.Trial(trial_i).Info.RollStartFrame;
        DataBase.Trial(trial_i).Info.RollStartFrame,DataBase.Trial(trial_i).Info.LandFrame;
        DataBase.Trial(trial_i).Info.LandFrame,DataBase.Trial(trial_i).Info.LeaveFrame;
        ];
end

xlims = [0.5,4.5];

% %%%%%%%%%%%%%% 6 phase %%%%%%%%%%%%%%%%%
% trial_series1 = PitchRoll_trial;
% trial_series2 = PureRoll_trial;
% series = '_doubleBar_6phase';
% 
% phase_num = 6;
% for trial_i = 1:DataBase.TrialNum
%     frame_span(trial_i,1:phase_num,1:2) = [
%         DataBase.Trial(trial_i).Info.EnterFrame,DataBase.Trial(trial_i).Info.TouchFrame;
%         DataBase.Trial(trial_i).Info.TouchFrame,DataBase.Trial(trial_i).Info.RollStartFrame;
%         DataBase.Trial(trial_i).Info.RollStartFrame,DataBase.Trial(trial_i).Info.Roll60inFrame;
%         DataBase.Trial(trial_i).Info.Roll60inFrame,DataBase.Trial(trial_i).Info.Roll60outFrame;
%         DataBase.Trial(trial_i).Info.Roll60outFrame,DataBase.Trial(trial_i).Info.LandFrame;
%         DataBase.Trial(trial_i).Info.LandFrame,DataBase.Trial(trial_i).Info.LeaveFrame;
%         ];
% end
% phase_color = [
%     0,1,0;
%     0,0,1;
%     0.93,0.69,0.13;
%     1,0,0;
%     0.49,0.18,0.56;
%     0.47,0.67,0.19;
%     ];
% 
% xlims = [0.5,6.5];
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

Yroll = [];
Eroll = [];

Ypitch = [];
Epitch = [];

Yhead = [];
Ehead = [];

Yhead_ab = [];
Ehead_ab = [];

Yabdomen = [];
Eabdomen = [];

Yabdomen_ab = [];
Eabdomen_ab = [];

Ylegsprawl = [];
Elegsprawl = [];

Yleghight = [];
Eleghight = [];


for iteration = 1:2
    if iteration == 1
        trial_series = trial_series1;
    else
        trial_series = trial_series2;
    end
    colors(:,iteration,:) = phase_color;
    
    for phase_i = 1:phase_num
        phase(phase_i).Roll_mean = NaN(1,DataBase.TrialNum);
        phase(phase_i).Pitch_mean = NaN(1,DataBase.TrialNum);
        phase(phase_i).HeadFlex_std = NaN(1,DataBase.TrialNum);
        phase(phase_i).AbdomenFlex_std = NaN(1,DataBase.TrialNum);
        phase(phase_i).LegSprawl_mean = NaN(1,DataBase.TrialNum);
        phase(phase_i).LegHeightDiff_mean = NaN(1,DataBase.TrialNum);
    end
    
    for trial_i = trial_series
        % calculate LegSprawl and LegHeightDiff
        LegSprawl = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
        LegHeightDiff = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
        for frame_i = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
            right_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
            left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
            LegSprawl(frame_i) = abs(acos(dot(right_position_b, left_position_b) / (norm(right_position_b) * norm(left_position_b))));
            LegHeightDiff(frame_i) = right_position_b(3)-left_position_b(3);
        end
        
        % load in data in each phase
        for phase_i = 1:phase_num
            frame_span_p = frame_span(trial_i,phase_i,1):frame_span(trial_i,phase_i,2);
            DataTemp(trial_i).phase(phase_i).Roll.Data = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_p,3);
            DataTemp(trial_i).phase(phase_i).Pitch.Data = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_p,2);
            DataTemp(trial_i).phase(phase_i).HeadFlex.Data = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_span_p,2);
            DataTemp(trial_i).phase(phase_i).AbdomenFlex.Data = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_span_p,2);
            DataTemp(trial_i).phase(phase_i).LegSprawl.Data = LegSprawl(frame_span_p);
            DataTemp(trial_i).phase(phase_i).LegHeightDiff.Data = LegHeightDiff(frame_span_p);
            
            % calculate mean, std in each trial
            DataTemp(trial_i).phase(phase_i).Roll.Mean = nanmean(DataTemp(trial_i).phase(phase_i).Roll.Data);
            DataTemp(trial_i).phase(phase_i).Pitch.Mean = nanmean(DataTemp(trial_i).phase(phase_i).Pitch.Data);
            DataTemp(trial_i).phase(phase_i).HeadFlex.Mean = nanmean(DataTemp(trial_i).phase(phase_i).HeadFlex.Data);
            DataTemp(trial_i).phase(phase_i).AbdomenFlex.Mean = nanmean(DataTemp(trial_i).phase(phase_i).AbdomenFlex.Data);
            DataTemp(trial_i).phase(phase_i).HeadFlex.Std = nanstd(DataTemp(trial_i).phase(phase_i).HeadFlex.Data);
            DataTemp(trial_i).phase(phase_i).AbdomenFlex.Std = nanstd(DataTemp(trial_i).phase(phase_i).AbdomenFlex.Data);
            DataTemp(trial_i).phase(phase_i).LegSprawl.Mean = nanmean(DataTemp(trial_i).phase(phase_i).LegSprawl.Data);
            DataTemp(trial_i).phase(phase_i).LegHeightDiff.Mean = nanmean(DataTemp(trial_i).phase(phase_i).LegHeightDiff.Data);
            
            phase(phase_i).Roll_mean(trial_i) = DataTemp(trial_i).phase(phase_i).Roll.Mean;
            phase(phase_i).Pitch_mean(trial_i) = DataTemp(trial_i).phase(phase_i).Pitch.Mean;
            phase(phase_i).HeadFlex_mean(trial_i) = DataTemp(trial_i).phase(phase_i).HeadFlex.Mean;
            phase(phase_i).AbdomenFlex_mean(trial_i) = DataTemp(trial_i).phase(phase_i).AbdomenFlex.Mean;
            phase(phase_i).HeadFlex_std(trial_i) = DataTemp(trial_i).phase(phase_i).HeadFlex.Std;
            phase(phase_i).AbdomenFlex_std(trial_i) = DataTemp(trial_i).phase(phase_i).AbdomenFlex.Std;
            phase(phase_i).LegSprawl_mean(trial_i) = DataTemp(trial_i).phase(phase_i).LegSprawl.Mean;
            phase(phase_i).LegHeightDiff_mean(trial_i) = DataTemp(trial_i).phase(phase_i).LegHeightDiff.Mean;
            
        end
        
    end
    
    %% sum up
    roll_collect = [];
    pitch_collect = [];
    head_flex_absolute_collect = [];
    abdomen_flex_absolute_collect = [];
    head_flex_collect = [];
    abdomen_flex_collect = [];
    leg_sprawl_collect = [];
    leg_hight_collect = [];
    for phase_i = 1:phase_num
        roll_collect = [roll_collect,phase(phase_i).Roll_mean'];
        pitch_collect = [pitch_collect,phase(phase_i).Pitch_mean'];
        head_flex_absolute_collect = [head_flex_absolute_collect,phase(phase_i).HeadFlex_mean'];
        abdomen_flex_absolute_collect = [abdomen_flex_absolute_collect,phase(phase_i).AbdomenFlex_mean'];
        head_flex_collect = [head_flex_collect,phase(phase_i).HeadFlex_std'];
        abdomen_flex_collect = [abdomen_flex_collect,phase(phase_i).AbdomenFlex_std'];
        leg_sprawl_collect = [leg_sprawl_collect,phase(phase_i).LegSprawl_mean'];
        leg_hight_collect = [leg_hight_collect,phase(phase_i).LegHeightDiff_mean'];
    end
    
    roll.av = nanmean(roll_collect)*180/pi;
    roll.sd = nanstd(roll_collect)*180/pi;
    
    pitch.av = nanmean(pitch_collect)*180/pi;
    pitch.sd = nanstd(pitch_collect)*180/pi;
    
    head_flex_absolute.av = nanmean(head_flex_absolute_collect)*180/pi;
    head_flex_absolute.sd = nanstd(head_flex_absolute_collect)*180/pi;
    
    abdomen_flex_absolute.av = nanmean(abdomen_flex_absolute_collect)*180/pi;
    abdomen_flex_absolute.sd = nanstd(abdomen_flex_absolute_collect)*180/pi;
    
    head_flex.av = nanmean(head_flex_collect)*180/pi;
    head_flex.sd = nanstd(head_flex_collect)*180/pi;
    
    abdomen_flex.av = nanmean(abdomen_flex_collect)*180/pi;
    abdomen_flex.sd = nanstd(abdomen_flex_collect)*180/pi;
    
    leg_sprawl.av = nanmean(leg_sprawl_collect)*180/pi;
    leg_sprawl.sd = nanstd(leg_sprawl_collect)*180/pi;
    
    leg_hight.av = nanmean(leg_hight_collect);
    leg_hight.sd = nanstd(leg_hight_collect);
    
    
    %
    Yroll = [Yroll, roll.av'];
    Eroll = [Eroll, roll.sd'];
    
    Ypitch = [Ypitch, pitch.av'];
    Epitch = [Epitch, pitch.sd'];
    
    Yhead = [Yhead, head_flex.av'];
    Ehead = [Ehead, head_flex.sd'];
    
    Yhead_ab = [Yhead_ab, head_flex_absolute.av'];
    Ehead_ab = [Ehead_ab, head_flex_absolute.sd'];
    
    Yabdomen = [Yabdomen, abdomen_flex.av'];
    Eabdomen = [Eabdomen, abdomen_flex.sd'];
    
    Yabdomen_ab = [Yabdomen_ab, abdomen_flex_absolute.av'];
    Eabdomen_ab = [Eabdomen_ab, abdomen_flex_absolute.sd'];
    
    Ylegsprawl = [Ylegsprawl, leg_sprawl.av'];
    Elegsprawl = [Elegsprawl, leg_sprawl.sd'];
    
    Yleghight = [Yleghight, leg_hight.av'];
    Eleghight = [Eleghight, leg_hight.sd'];
    
end
%% bar plots drawing

%%% Roll
f = figure(1);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
superbar(Yroll, 'E', Eroll, 'BarFaceColor', colors);
xlim(xlims)
ylim([min(min(Yroll-Eroll))-6,max(max(Yroll+Eroll))+6]);
box on;
set( gca, 'XTickLabel', {''});
box on
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'BodyRoll',series,'.jpg'])

%%% Pitch
f = figure(2);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
superbar(Ypitch, 'E', Epitch, 'BarFaceColor',colors);
ylabel({'Body Pitch (°)'});
xlim(xlims)
ylim([min(min(Ypitch-Epitch))-6,max(max(Ypitch+Epitch))+6]);
box on;
set( gca, 'XTickLabel', {'';'';'';'';''} )
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'BodyPitch',series,'.jpg'])

%%% head_flex
f = figure(3);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
superbar(Yhead, 'E', Ehead, 'BarFaceColor', colors);
ylabel({'Head Flexion STD DEV (°)'});
set( gca, 'XTickLabel', {''} )
% title('Head STD')
xlim(xlims)
ylim([min(min(Yhead-Ehead))-3,max(max(Yhead+Ehead))+3]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'HeadFlex',series,'.jpg'])

%%% head_flex_absolute
f = figure(7);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
superbar(Yhead_ab, 'E', Ehead_ab, 'BarFaceColor', colors);
ylabel({'Head Flexion (°)'});
set( gca, 'XTickLabel', {''} )
xlim(xlims)
ylim([min(min(Yhead_ab-Ehead_ab))-3,max(max(Yhead_ab+Ehead_ab))+3]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'HeadFlex_absolute',series,'.jpg'])

%%% abdomen_flex
f = figure(4);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
superbar(Yabdomen, 'E', Eabdomen, 'BarFaceColor', colors);
ylabel({'Abdomen Flexion STD DEV (°)'});
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim(xlims)
ylim([min(min(Yabdomen-Eabdomen))-3,max(max(Yabdomen+Eabdomen))+3]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'AbdomFlex',series,'.jpg'])

%%% abdomen_flex_absolute
f = figure(8);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
superbar(Yabdomen_ab, 'E', Eabdomen_ab, 'BarFaceColor', colors);
ylabel({'Abdomen Flexion (°)'});
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim(xlims)
ylim([min(min(Yabdomen_ab-Eabdomen_ab))-3,max(max(Yabdomen_ab+Eabdomen_ab))+3]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'AbdomFlex_absolute',series,'.jpg'])

%%% leg_sprawl
f = figure(5);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
superbar(Ylegsprawl, 'E', Elegsprawl, 'BarFaceColor', colors);
ylabel({'Leg Sprawl (°)'});
set( gca, 'XTickLabel', {''} )
xlim(xlims)
ylim([min(min(Ylegsprawl-Elegsprawl))-10,max(max(Ylegsprawl+Elegsprawl))+10]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'LegSprawl',series,'.jpg'])

%%% leg_hight
f = figure(6);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
superbar(Yleghight, 'E', Eleghight, 'BarFaceColor', colors);
ylabel({'Leg Height Difference (mm)'});
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim(xlims)
ylim([min(min(Yleghight-Eleghight))-3,max(max(Yleghight+Eleghight))+3]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'LegHight',series,'.jpg'])



close all;
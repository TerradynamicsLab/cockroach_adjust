% Yaqing created this on 06/24/2020 to create the simple bar plots and line
% plots in the paper
% 06/28/2020, revised to contain 6 phases
% Run, Pitch, Transition, Roll, Land, Run2
% the seperation: touchframe, roll = 20,  roll = 60, roll = 60, landframe

close all;clear;clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

is_line_plot = 0;


%%
save_folder = [REPO,'/data/kinematics/simple_plot/'];

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
trial_series = All_trial;
series = '_All_4phase';
% trial_series = PitchRoll_trial;
% series = '_PitchRoll_4phase';
% trial_series = PureRoll_trial;
% series = '_PureRoll_4phase';

phase_num = 4;
for trial_i = trial_series
    frame_span(trial_i,1:phase_num,1:2) = [
        DataBase.Trial(trial_i).Info.EnterFrame,DataBase.Trial(trial_i).Info.TouchFrame;
        DataBase.Trial(trial_i).Info.TouchFrame,DataBase.Trial(trial_i).Info.RollStartFrame;
        DataBase.Trial(trial_i).Info.RollStartFrame,DataBase.Trial(trial_i).Info.LandFrame;
        DataBase.Trial(trial_i).Info.LandFrame,DataBase.Trial(trial_i).Info.LeaveFrame;
        ];
end
phase_color = [
    0,1,0;
    0,0,1;
    0.93,0.69,0.13;
    0.47,0.67,0.19;
    ];

% % %%%%%%%%%%%%%% 6 phase %%%%%%%%%%%%%%%%%
% % trial_series = All_trial;
% % series = '_All_6phase';
% % trial_series = PitchRoll_trial;
% % series = '_PitchRoll_6phase';
% trial_series = PureRoll_trial;
% series = '_PureRoll_6phase';
%
% phase_num = 6;
% for trial_i = trial_series
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
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
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

% % prepare for statistics
% roll_file = [save_folder,'BodyRoll',series,'.csv'];
% csvwrite(roll_file,roll_collect*180/pi);
% 
% pitch_file = [save_folder,'BodyPitch',series,'.csv'];
% csvwrite(pitch_file,pitch_collect*180/pi);
% 
% head_absolute_file = [save_folder,'HeadFlex_absolute',series,'.csv'];
% csvwrite(head_absolute_file,head_flex_absolute_collect*180/pi);
% 
% abdomen_absolute_file = [save_folder,'AbdomenFlex_absolute',series,'.csv'];
% csvwrite(abdomen_absolute_file,abdomen_flex_absolute_collect*180/pi);
% 
% head_file = [save_folder,'HeadFlex',series,'.csv'];
% csvwrite(head_file,head_flex_collect*180/pi);
% 
% abdomen_file = [save_folder,'AbdomenFlex',series,'.csv'];
% csvwrite(abdomen_file,abdomen_flex_collect*180/pi);
% 
% leg_sprawl_file = [save_folder,'LegSprawl',series,'.csv'];
% csvwrite(leg_sprawl_file,leg_sprawl_collect*180/pi);
% 
% leg_hight_file = [save_folder,'LegHeight',series,'.csv'];
% csvwrite(leg_hight_file,leg_hight_collect);


%% bar plots drawing

%%% Roll
f = figure(1);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = roll.av;
E = roll.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Body Roll (°)'});
% title('Body Roll')
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-6,max(Y+E)+6]);
box on;
set( gca, 'XTickLabel', {''});
box on
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'BodyRoll',series,'.jpg'])

%%% Pitch
f = figure(2);
axes1 = axes('Parent',f);
hold(axes1,'on');
% set(axes1,'FontSize',22,'FontWeight','bold','YTick', [0 10 20 30 40]);
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = pitch.av;
E = pitch.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Body Pitch (°)'});
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-6,max(Y+E)+6]);
box on;
% title('Body Pitch')
set( gca, 'XTickLabel', {'';'';'';'';''} )
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'BodyPitch',series,'.jpg'])

%%% head_flex
f = figure(3);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = head_flex.av;
E = head_flex.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Head Flexion STD DEV (°)'});
set( gca, 'XTickLabel', {''} )
% title('Head STD')
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-3,max(Y+E)+3]);
box on;
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'HeadFlex',series,'.jpg'])

%%% head_flex_absolute
f = figure(7);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = head_flex_absolute.av;
E = head_flex_absolute.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Head Flexion (°)'});
set( gca, 'XTickLabel', {''} )
% title('Head STD')
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-3,max(Y+E)+3]);
box on;
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'HeadFlex_absolute',series,'.jpg'])

%%% abdomen_flex
f = figure(4);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
Y = abdomen_flex.av;
E = abdomen_flex.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Abdomen Flexion STD DEV (°)'});
% title('Abdomen Pitch')
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-3,max(Y+E)+3]);
box on;
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'AbdomFlex',series,'.jpg'])

%%% abdomen_flex
f = figure(8);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
Y = abdomen_flex_absolute.av;
E = abdomen_flex_absolute.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Abdomen Flexion (°)'});
% title('Abdomen Pitch')
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-3,max(Y+E)+3]);
box on;
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'AbdomFlex_absolute',series,'.jpg'])

%%% leg_sprawl
f = figure(5);
axes1 = axes('Parent',f);
hold(axes1,'on');
% set(axes1,'FontSize',22,'FontWeight','bold','YTick', [60 80 100 120]);
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = leg_sprawl.av;
E = leg_sprawl.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Leg Sprawl (°)'});
% title('Sprawl Angle')
set( gca, 'XTickLabel', {''} )
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-10,max(Y+E)+10]);
box on;
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'LegSprawl',series,'.jpg'])

%%% leg_hight
f = figure(6);
axes1 = axes('Parent',f);
hold(axes1,'on');
% set(axes1,'FontSize',22,'FontWeight','bold','YTick', [0 5 10 15 20]);
set(axes1,'FontSize',22,'FontWeight','bold');
Y = leg_hight.av;
E = leg_hight.sd;
superbar(Y, 'E', E, 'BarFaceColor', permute(phase_color, [1 2 3]));
ylabel({'Leg Height Difference (mm)'});
set( gca, 'XTickLabel', {''} )
% title('Leg Height Diff')
axes1.YGrid='on';
xlim([0.5 phase_num+0.5])
ylim([min(Y-E)-3,max(Y+E)+3]);
box on;
set(gcf, 'position', [100,100,600,450])
%saveas(gcf,[save_folder,'LegHight',series,'.jpg'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if is_line_plot
    
    %% line plots drawing
    DataTemp = struct();
    
    %%% Roll
    DataTemp(1).ValName = 'Roll (°)';
    DataTemp(1).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        Temp = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,3)*180/pi;
        DataTemp(1).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Pitch
    DataTemp(2).ValName = 'Pitch (°)';
    DataTemp(2).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        Temp = - DataBase.Trial(trial_i).modified.Cockroach.Body.eul(:,2)*180/pi;
        DataTemp(2).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Head flexion
    DataTemp(3).ValName = 'Head flexion (°)';
    DataTemp(3).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        Temp = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(:,2)*180/pi;
        DataTemp(3).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Abdomen flexion
    DataTemp(4).ValName = 'Abdomen flexion (°)';
    DataTemp(4).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        Temp = - DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(:,2)*180/pi;
        DataTemp(4).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Leg hight difference
    DataTemp(5).ValName = 'Leg hight difference (mm)';
    DataTemp(5).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        % calculate LegHeightDiff
        Temp = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
        for frame_i = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
            right_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
            left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
            Temp(frame_i) = right_position_b(3)-left_position_b(3);
        end
        DataTemp(5).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Leg Sprawl
    DataTemp(6).ValName = 'Leg Sprawl (°)';
    DataTemp(6).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        % calculate LegSprawl
        Temp = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
        for frame_i = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
            right_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
            left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
            Temp(frame_i) = abs(acos(dot(right_position_b, left_position_b) / (norm(right_position_b) * norm(left_position_b))))*180/pi;
        end
        DataTemp(6).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Left Leg hight
    DataTemp(7).ValName = 'Left Leg hight (mm)';
    DataTemp(7).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        % calculate LegHeightDiff
        Temp = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
        for frame_i = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
            left_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.left_position_b(frame_i,:);
            Temp(frame_i) = left_position_b(3);
        end
        DataTemp(7).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    %%% Right Leg hight
    DataTemp(8).ValName = 'Right Leg hight (mm)';
    DataTemp(8).Value = NaN(DataBase.TrialNum,2000);
    for trial_i = trial_series
        % calculate LegHeightDiff
        Temp = NaN(DataBase.Trial(trial_i).Info.FrameNum,1);
        for frame_i = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.LeaveFrame
            right_position_b = DataBase.Trial(trial_i).modified.Cockroach.Leg.right_position_b(frame_i,:);
            Temp(frame_i) = right_position_b(3);
        end
        DataTemp(8).Value(trial_i,1001-DataBase.Trial(trial_i).Info.RollStartFrame:1000+length(Temp)-DataBase.Trial(trial_i).Info.RollStartFrame) = Temp;
    end
    
    
    %%% Mean and std
    for v = 1:8
        DataTemp(v).Mean = NaN(1,2000);
        DataTemp(v).Std = NaN(1,2000);
        
        for f = 1:2000
            DataTemp(v).Mean(f) = nanmean(DataTemp(v).Value(:,f));
            DataTemp(v).Std(f) = nanstd(DataTemp(v).Value(:,f));
        end
    end
    
    % plot figures
    ylims=[
        -60,100;
        -25,55;
        -5,65;
        -10,45;
        -26,26;
        0,180;
        ];
    LineWidthEach = 1;
    LineWidthMean = 6;
    LineWidthStd = 3;
    s = get(0, 'ScreenSize');
    
    for data_i = 1:6
        % Create figure
        fig = figure(data_i+8);
        set(gcf, 'position', [0 0 s(3) s(4)]);
        hold on;
        % Each Trial
        for trial_i = trial_series
            for phase_i = 1:phase_num
                frame_span_temp = (frame_span(trial_i,phase_i,1):frame_span(trial_i,phase_i,2)) - DataBase.Trial(trial_i).Info.RollStartFrame;
                plot(frame_span_temp/100,DataTemp(data_i).Value(trial_i,frame_span_temp+1000),'LineWidth',LineWidthEach,'Color',phase_color(phase_i,1:3));
            end
        end
        % Mean and std
        plot((-999:1000)/100,DataTemp(data_i).Mean,'LineWidth',LineWidthMean,'Color',[0 0 0]);
        hold on;
        plot((-999:1000)/100,DataTemp(data_i).Mean-DataTemp(data_i).Std,'LineWidth',LineWidthStd,'Color',[0 0 0]);
        hold on;
        plot((-999:1000)/100,DataTemp(data_i).Mean+DataTemp(data_i).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 0.2]);
        hold on;
        line([0 0],[-1000 1000],'LineStyle','--','Color','k','LineWidth',5);
        grid on;
        
        xlim([-1.7,1.5]);ylim(ylims(data_i,:))
        set(gca,'FontSize',40,'FontWeight','bold');
        xlabel({'Time(s)'});
        ylabel({DataTemp(data_i).ValName});
        hold on;
        box on;
        
        %saveas(gcf,[save_folder,'Data_',num2str(data_i),series,'.jpg'])
    end
    
    % leg height
    % Create figure
    fig = figure(15);
    set(gcf, 'position', [0 0 s(3) s(4)]);
    hold on;
    
    % Each Trial
    for trial_i = trial_series
        plot((-999:1000)/100,DataTemp(7).Value(trial_i,1:2000),'LineWidth',LineWidthEach,'Color',[0.7 0.7 1]);
        plot((-999:1000)/100,DataTemp(8).Value(trial_i,1:2000),'LineWidth',LineWidthEach,'Color',[1 0.7 0.7]);
    end
    % Mean and std
    a(1) = plot((-999:1000)/100,DataTemp(7).Mean,'LineWidth',LineWidthMean,'Color',[0,0,1]);
    hold on;
    plot((-999:1000)/100,DataTemp(7).Mean-DataTemp(7).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);
    hold on;
    plot((-999:1000)/100,DataTemp(7).Mean+DataTemp(7).Std,'LineWidth',LineWidthStd,'Color',[0.2 0.2 1]);
    hold on;
    a(2)=plot((-999:1000)/100,DataTemp(8).Mean,'LineWidth',LineWidthMean,'Color',[1 0 0]);
    hold on;
    plot((-999:1000)/100,DataTemp(8).Mean-DataTemp(8).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
    hold on;
    plot((-999:1000)/100,DataTemp(8).Mean+DataTemp(8).Std,'LineWidth',LineWidthStd,'Color',[1 0.2 0.2]);
    hold on;
    line([0 0],[-1000 1000],'LineStyle','--','Color','k','LineWidth',5);
    grid on;
    
    xlim([-1.7,1.5]);ylim([-25,10])
    set(gca,'FontSize',40,'FontWeight','bold');
    xlabel({'Time(s)'});
    ylabel({'Leg Height (mm)'});
    %     ylabel({'Amplitude(mm)'});
    hold on;
    box on;
    %     close all;
    legend([a(1),a(2)],{'Pushing Leg','Supporting Leg'},'FontSize',30,'Location','northeast');
    % legend([a(7),a(8)],'Pushing Leg','Supporting Leg','FontSize',30);
    
    %saveas(gcf,[save_folder,'Data_',num2str(7),series,'.jpg'])
end


close all;
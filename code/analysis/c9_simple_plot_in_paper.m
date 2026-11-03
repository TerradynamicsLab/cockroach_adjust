% Yaqing created this on 06/24/2020 to create the simple bar plots and line
% plots in the paper

close all;clear;clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

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
trial_series = All_trial;
series = '_All';
% trial_series = PitchRoll_trial;
% series = '_PitchRoll';
% trial_series = PureRoll_trial;
% series = '_PureRoll';

Approach.Roll_mean = NaN(1,DataBase.TrialNum);
Approach.Pitch_mean = NaN(1,DataBase.TrialNum);
Approach.HeadFlex_std = NaN(1,DataBase.TrialNum);
Approach.AbdomenFlex_std = NaN(1,DataBase.TrialNum);
Approach.LegSprawl_mean = NaN(1,DataBase.TrialNum);
Approach.LegHeightDiff_mean = NaN(1,DataBase.TrialNum);

Explore.Roll_mean = NaN(1,DataBase.TrialNum);
Explore.Pitch_mean = NaN(1,DataBase.TrialNum);
Explore.HeadFlex_std = NaN(1,DataBase.TrialNum);
Explore.AbdomenFlex_std = NaN(1,DataBase.TrialNum);
Explore.LegSprawl_mean = NaN(1,DataBase.TrialNum);
Explore.LegHeightDiff_mean = NaN(1,DataBase.TrialNum);


Roll.Roll_mean = NaN(1,DataBase.TrialNum);
Roll.Pitch_mean = NaN(1,DataBase.TrialNum);
Roll.HeadFlex_std = NaN(1,DataBase.TrialNum);
Roll.AbdomenFlex_std = NaN(1,DataBase.TrialNum);
Roll.LegSprawl_mean = NaN(1,DataBase.TrialNum);
Roll.LegHeightDiff_mean = NaN(1,DataBase.TrialNum);


Leave.Roll_mean = NaN(1,DataBase.TrialNum);
Leave.Pitch_mean = NaN(1,DataBase.TrialNum);
Leave.HeadFlex_std = NaN(1,DataBase.TrialNum);
Leave.AbdomenFlex_std = NaN(1,DataBase.TrialNum);
Leave.LegSprawl_mean = NaN(1,DataBase.TrialNum);
Leave.LegHeightDiff_mean = NaN(1,DataBase.TrialNum);



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
    frame_span_Approach = DataBase.Trial(trial_i).Info.EnterFrame:DataBase.Trial(trial_i).Info.TouchFrame;
    DataTemp(trial_i).Approach.Roll.Data = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Approach,3);
    DataTemp(trial_i).Approach.Pitch.Data = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Approach,2);
    DataTemp(trial_i).Approach.HeadFlex.Data = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_span_Approach,2);
    DataTemp(trial_i).Approach.AbdomenFlex.Data = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_span_Approach,2);
    DataTemp(trial_i).Approach.LegSprawl.Data = LegSprawl(frame_span_Approach);
    DataTemp(trial_i).Approach.LegHeightDiff.Data = LegHeightDiff(frame_span_Approach);
    
    frame_span_Explore = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.RollStartFrame;
    DataTemp(trial_i).Explore.Roll.Data = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Explore,3);
    DataTemp(trial_i).Explore.Pitch.Data = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Explore,2);
    DataTemp(trial_i).Explore.HeadFlex.Data = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_span_Explore,2);
    DataTemp(trial_i).Explore.AbdomenFlex.Data = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_span_Explore,2);
    DataTemp(trial_i).Explore.LegSprawl.Data = LegSprawl(frame_span_Explore);
    DataTemp(trial_i).Explore.LegHeightDiff.Data = LegHeightDiff(frame_span_Explore);
    
    frame_span_Roll = DataBase.Trial(trial_i).Info.RollStartFrame:DataBase.Trial(trial_i).Info.RollEndFrame;
    DataTemp(trial_i).Roll.Roll.Data = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Roll,3);
    DataTemp(trial_i).Roll.Pitch.Data = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Roll,2);
    DataTemp(trial_i).Roll.HeadFlex.Data = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_span_Roll,2);
    DataTemp(trial_i).Roll.AbdomenFlex.Data = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_span_Roll,2);
    DataTemp(trial_i).Roll.LegSprawl.Data = LegSprawl(frame_span_Roll);
    DataTemp(trial_i).Roll.LegHeightDiff.Data = LegHeightDiff(frame_span_Roll);
    
    frame_span_Leave = DataBase.Trial(trial_i).Info.RollEndFrame:DataBase.Trial(trial_i).Info.LeaveFrame;
    DataTemp(trial_i).Leave.Roll.Data = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Leave,3);
    DataTemp(trial_i).Leave.Pitch.Data = -DataBase.Trial(trial_i).modified.Cockroach.Body.eul(frame_span_Leave,2);
    DataTemp(trial_i).Leave.HeadFlex.Data = DataBase.Trial(trial_i).modified.Cockroach.Head.eul_b(frame_span_Leave,2);
    DataTemp(trial_i).Leave.AbdomenFlex.Data = -DataBase.Trial(trial_i).modified.Cockroach.Abdomen_Up.eul_b(frame_span_Leave,2);
    DataTemp(trial_i).Leave.LegSprawl.Data = LegSprawl(frame_span_Leave);
    DataTemp(trial_i).Leave.LegHeightDiff.Data = LegHeightDiff(frame_span_Leave);
    
    DataTemp(trial_i).Approach.Roll.Mean = nanmean(DataTemp(trial_i).Approach.Roll.Data);
    DataTemp(trial_i).Approach.Pitch.Mean = nanmean(DataTemp(trial_i).Approach.Pitch.Data);
    DataTemp(trial_i).Approach.HeadFlex.Std = nanstd(DataTemp(trial_i).Approach.HeadFlex.Data);
    DataTemp(trial_i).Approach.AbdomenFlex.Std = nanstd(DataTemp(trial_i).Approach.AbdomenFlex.Data);
    DataTemp(trial_i).Approach.LegSprawl.Mean = nanmean(DataTemp(trial_i).Approach.LegSprawl.Data);
    DataTemp(trial_i).Approach.LegHeightDiff.Mean = nanmean(DataTemp(trial_i).Approach.LegHeightDiff.Data);
    
    DataTemp(trial_i).Explore.Roll.Mean = nanmean(DataTemp(trial_i).Explore.Roll.Data);
    DataTemp(trial_i).Explore.Pitch.Mean = nanmean(DataTemp(trial_i).Explore.Pitch.Data);
    DataTemp(trial_i).Explore.HeadFlex.Std = nanstd(DataTemp(trial_i).Explore.HeadFlex.Data);
    DataTemp(trial_i).Explore.AbdomenFlex.Std = nanstd(DataTemp(trial_i).Explore.AbdomenFlex.Data);
    DataTemp(trial_i).Explore.LegSprawl.Mean = nanmean(DataTemp(trial_i).Explore.LegSprawl.Data);
    DataTemp(trial_i).Explore.LegHeightDiff.Mean = nanmean(DataTemp(trial_i).Explore.LegHeightDiff.Data);
    
    DataTemp(trial_i).Roll.Roll.Mean = nanmean(DataTemp(trial_i).Roll.Roll.Data);
    DataTemp(trial_i).Roll.Pitch.Mean = nanmean(DataTemp(trial_i).Roll.Pitch.Data);
    DataTemp(trial_i).Roll.HeadFlex.Std = nanstd(DataTemp(trial_i).Roll.HeadFlex.Data);
    DataTemp(trial_i).Roll.AbdomenFlex.Std = nanstd(DataTemp(trial_i).Roll.AbdomenFlex.Data);
    DataTemp(trial_i).Roll.LegSprawl.Mean = nanmean(DataTemp(trial_i).Roll.LegSprawl.Data);
    DataTemp(trial_i).Roll.LegHeightDiff.Mean = nanmean(DataTemp(trial_i).Roll.LegHeightDiff.Data);
    
    DataTemp(trial_i).Leave.Roll.Mean = nanmean(DataTemp(trial_i).Leave.Roll.Data);
    DataTemp(trial_i).Leave.Pitch.Mean = nanmean(DataTemp(trial_i).Leave.Pitch.Data);
    DataTemp(trial_i).Leave.HeadFlex.Std = nanstd(DataTemp(trial_i).Leave.HeadFlex.Data);
    DataTemp(trial_i).Leave.AbdomenFlex.Std = nanstd(DataTemp(trial_i).Leave.AbdomenFlex.Data);
    DataTemp(trial_i).Leave.LegSprawl.Mean = nanmean(DataTemp(trial_i).Leave.LegSprawl.Data);
    DataTemp(trial_i).Leave.LegHeightDiff.Mean = nanmean(DataTemp(trial_i).Leave.LegHeightDiff.Data);
    
    Approach.Roll_mean(trial_i) = DataTemp(trial_i).Approach.Roll.Mean;
    Approach.Pitch_mean(trial_i) = DataTemp(trial_i).Approach.Pitch.Mean;
    Approach.HeadFlex_std(trial_i) = DataTemp(trial_i).Approach.HeadFlex.Std;
    Approach.AbdomenFlex_std(trial_i) = DataTemp(trial_i).Approach.AbdomenFlex.Std;
    Approach.LegSprawl_mean(trial_i) = DataTemp(trial_i).Approach.LegSprawl.Mean;
    Approach.LegHeightDiff_mean(trial_i) = DataTemp(trial_i).Approach.LegHeightDiff.Mean;
    
    Explore.Roll_mean(trial_i) = DataTemp(trial_i).Explore.Roll.Mean;
    Explore.Pitch_mean(trial_i) = DataTemp(trial_i).Explore.Pitch.Mean;
    Explore.HeadFlex_std(trial_i) = DataTemp(trial_i).Explore.HeadFlex.Std;
    Explore.AbdomenFlex_std(trial_i) = DataTemp(trial_i).Explore.AbdomenFlex.Std;
    Explore.LegSprawl_mean(trial_i) = DataTemp(trial_i).Explore.LegSprawl.Mean;
    Explore.LegHeightDiff_mean(trial_i) = DataTemp(trial_i).Explore.LegHeightDiff.Mean;
    
    Roll.Roll_mean(trial_i) = DataTemp(trial_i).Roll.Roll.Mean;
    Roll.Pitch_mean(trial_i) = DataTemp(trial_i).Roll.Pitch.Mean;
    Roll.HeadFlex_std(trial_i) = DataTemp(trial_i).Roll.HeadFlex.Std;
    Roll.AbdomenFlex_std(trial_i) = DataTemp(trial_i).Roll.AbdomenFlex.Std;
    Roll.LegSprawl_mean(trial_i) = DataTemp(trial_i).Roll.LegSprawl.Mean;
    Roll.LegHeightDiff_mean(trial_i) = DataTemp(trial_i).Roll.LegHeightDiff.Mean;
    
    Leave.Roll_mean(trial_i) = DataTemp(trial_i).Leave.Roll.Mean;
    Leave.Pitch_mean(trial_i) = DataTemp(trial_i).Leave.Pitch.Mean;
    Leave.HeadFlex_std(trial_i) = DataTemp(trial_i).Leave.HeadFlex.Std;
    Leave.AbdomenFlex_std(trial_i) = DataTemp(trial_i).Leave.AbdomenFlex.Std;
    Leave.LegSprawl_mean(trial_i) = DataTemp(trial_i).Leave.LegSprawl.Mean;
    Leave.LegHeightDiff_mean(trial_i) = DataTemp(trial_i).Leave.LegHeightDiff.Mean;
    
end

%% sum up
roll.av = nanmean([Approach.Roll_mean' ,Explore.Roll_mean' , Roll.Roll_mean', Leave.Roll_mean'])*180/pi;
roll.sd = nanstd([Approach.Roll_mean' ,Explore.Roll_mean' , Roll.Roll_mean', Leave.Roll_mean'])*180/pi;

pitch.av = nanmean([Approach.Pitch_mean' ,Explore.Pitch_mean' , Roll.Pitch_mean', Leave.Pitch_mean'])*180/pi;
pitch.sd = nanstd([Approach.Pitch_mean' ,Explore.Pitch_mean' , Roll.Pitch_mean', Leave.Pitch_mean'])*180/pi;

head_flex.av = nanmean([Approach.HeadFlex_std' ,Explore.HeadFlex_std' , Roll.HeadFlex_std', Leave.HeadFlex_std'])*180/pi;
head_flex.sd = nanstd([Approach.HeadFlex_std' ,Explore.HeadFlex_std' , Roll.HeadFlex_std', Leave.HeadFlex_std'])*180/pi;

abdomen_flex.av = nanmean([Approach.AbdomenFlex_std' ,Explore.AbdomenFlex_std' , Roll.AbdomenFlex_std', Leave.AbdomenFlex_std'])*180/pi;
abdomen_flex.sd = nanstd([Approach.AbdomenFlex_std' ,Explore.AbdomenFlex_std' , Roll.AbdomenFlex_std', Leave.AbdomenFlex_std'])*180/pi;

leg_sprawl.av = nanmean([Approach.LegSprawl_mean' ,Explore.LegSprawl_mean' , Roll.LegSprawl_mean', Leave.LegSprawl_mean'])*180/pi;
leg_sprawl.sd = nanstd([Approach.LegSprawl_mean' ,Explore.LegSprawl_mean' , Roll.LegSprawl_mean', Leave.LegSprawl_mean'])*180/pi;

leg_hight.av = nanmean([Approach.LegHeightDiff_mean' ,Explore.LegHeightDiff_mean' , Roll.LegHeightDiff_mean', Leave.LegHeightDiff_mean']);
leg_hight.sd = nanstd([Approach.LegHeightDiff_mean' ,Explore.LegHeightDiff_mean' , Roll.LegHeightDiff_mean', Leave.LegHeightDiff_mean']);

%% bar plots drawing

%%% Roll
f = figure(1);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = roll.av;
E = roll.sd;
color = colormap(jet);
C = [];
for i = 1:4
    C = [C; color(16*i,:)];
end
superbar(Y, 'E', E, 'BarFaceColor', permute(C, [1 2 3]));
ylabel({'Body Roll (°)'});
% title('Body Roll')
xlim([0.5 3.5])
ylim([-20 80]);
box on;
set( gca, 'XTickLabel', {''});
box on
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'BodyRoll',series,'.jpg'])

%%% Pitch
f = figure(2);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold','YTick', [0 10 20 30 40]);
axes1.YGrid='on';
Y = pitch.av;
E = pitch.sd;
color = colormap(jet);
C = [];
for i = 1:4
    C = [C; color(16*i,:)];
end
superbar(Y, 'E', E, 'BarFaceColor', permute(C, [1 2 3]));
ylabel({'Body Pitch (°)'});
xlim([0.5 3.5])
ylim([-5 40]);
box on;
% title('Body Pitch')
set( gca, 'XTickLabel', {'';'';'';'';''} )
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'BodyPitch',series,'.jpg'])

%%% head_flex
f = figure(3);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
axes1.YGrid='on';
Y = head_flex.av;
E = head_flex.sd;
color = colormap(jet);
C = [];
for i = 1:4
    C = [C; color(16*i,:)];
end
superbar(Y, 'E', E, 'BarFaceColor', permute(C, [1 2 3]));
ylabel({'Head Flexion STD DEV (°)'});
set( gca, 'XTickLabel', {''} )
% title('Head STD')
xlim([0.5 3.5])
ylim([-2 20]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'HeadFlex',series,'.jpg'])

%%% abdomen_flex
f = figure(4);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold');
Y = abdomen_flex.av;
E = abdomen_flex.sd;
color = colormap(jet);
C = [];
for i = 1:4
    C = [C; color(16*i,:)];
end
superbar(Y, 'E', E, 'BarFaceColor', permute(C, [1 2 3]));
ylabel({'Abdomen Flexion STD DEV (°)'});
% title('Abdomen Pitch')
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim([0.5 3.5])
ylim([-2 22]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'AbdomFlex',series,'.jpg'])

%%% leg_sprawl
f = figure(5);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold','YTick', [60 80 100 120]);
axes1.YGrid='on';
Y = leg_sprawl.av;
E = leg_sprawl.sd;
color = colormap(jet);
C = [];
for i = 1:4
    C = [C; color(16*i,:)];
end
superbar(Y, 'E', E, 'BarFaceColor', permute(C, [1 2 3]));
ylabel({'Leg Sprawl (°)'});
% title('Sprawl Angle')
set( gca, 'XTickLabel', {''} )
xlim([0.5 3.5])
ylim([60 140]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'LegSprawl',series,'.jpg'])

%%% leg_hight
f = figure(6);
axes1 = axes('Parent',f);
hold(axes1,'on');
set(axes1,'FontSize',22,'FontWeight','bold','YTick', [0 5 10 15 20]);
Y = leg_hight.av;
E = leg_hight.sd;
color = colormap(jet);
C = [];
for i = 1:4
    C = [C; color(16*i,:)];
end
superbar(Y, 'E', E, 'BarFaceColor', permute(C, [1 2 3]));
ylabel({'Leg Height Difference (mm)'});
set( gca, 'XTickLabel', {''} )
% title('Leg Height Diff')
set( gca, 'XTickLabel', {''} )
axes1.YGrid='on';
xlim([0.5 3.5])
ylim([-4 10]);
box on;
set(gcf, 'position', [100,100,600,450])
saveas(gcf,[save_folder,'LegHight',series,'.jpg'])

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
    fig = figure(data_i+6);
    set(gcf, 'position', [0 0 s(3) s(4)]);
    hold on;
    % Each Trial
    for trial_i = trial_series
        tempframe = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
        plot((-999:tempframe)/100,DataTemp(data_i).Value(trial_i,1:tempframe+1000),'LineWidth',LineWidthEach,'Color',[0 0.5 1]);
        hold on;
        plot((tempframe:0)/100,DataTemp(data_i).Value(trial_i,tempframe+1000:1000),'LineWidth',LineWidthEach,'Color',[0.5 1 0.5]);
        hold on;
        plot((0:1000)/100,DataTemp(data_i).Value(trial_i,1000:2000),'LineWidth',LineWidthEach,'Color',[1 0.5 0]);
        hold on;
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
    
    saveas(gcf,[save_folder,'Data_',num2str(data_i),series,'.jpg'])
end

% leg height
% Create figure
fig = figure(13);
set(gcf, 'position', [0 0 s(3) s(4)]);
hold on;

% Each Trial
for i = trial_series
   
    tempframe = DataBase.Trial(trial_i).Info.TouchFrame - DataBase.Trial(trial_i).Info.RollStartFrame;
    plot((-999:tempframe)/100,DataTemp(7).Value(i,1:tempframe+1000),'LineWidth',LineWidthEach,'Color',[0.7 0.7 1]);
    hold on;
    plot((tempframe:0)/100,DataTemp(7).Value(i,tempframe+1000:1000),'LineWidth',LineWidthEach,'Color',[0.7 0.7 1]);
    hold on;
    plot((0:1000)/100,DataTemp(7).Value(i,1000:2000),'LineWidth',LineWidthEach,'Color',[0.7 0.7 1]);
    hold on;
    plot((-999:tempframe)/100,DataTemp(8).Value(i,1:tempframe+1000),'LineWidth',LineWidthEach,'Color',[1 0.7 0.7]);
    hold on;
    plot((tempframe:0)/100,DataTemp(8).Value(i,tempframe+1000:1000),'LineWidth',LineWidthEach,'Color',[1 0.7 0.7]);
    hold on;
    plot((0:1000)/100,DataTemp(8).Value(i,1000:2000),'LineWidth',LineWidthEach,'Color',[1 0.7 0.7]);
    hold on;
    
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

saveas(gcf,[save_folder,'Data_',num2str(7),series,'.jpg'])

close all;
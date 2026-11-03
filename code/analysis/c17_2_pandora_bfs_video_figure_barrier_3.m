close all; clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
addpath(genpath([REPO,'/code/analysis/Dependences']));

is_re = 0;
beam_cal_re = 0;
is_fix = 0;

project = struct();
% video settings
is_video = 0;


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

if exist(video_folder, 'dir')
    disp('Video folder already exist');
else
    mkdir(video_folder)
end

% Mode: 1, measured head angle. 2. fixed head angle
mode = 1;
% plot_mode: 1, original. 2, fixed colorbar. 3, neighbor colorbar.
plot_mode = 3;

for mode = 1
    for plot_mode = 3
        for trial_i = 37%:36
            % display the trial_i
            disp(['trial_i: ',num2str(trial_i)]);
            
            
            if is_video
                if is_re == 1
                    video_name = [video_folder,'Trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.avi'];
                else
                    if mode == 1
                        video_name = [video_folder,'Trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.avi'];
%                         video_name = [video_folder,'Trial_',num2str(trial_i),'_groundtruth_',num2str(plot_mode),'.avi'];
                    elseif mode == 2
                        video_name = [video_folder,'Trial_',num2str(trial_i),'_headfix_',num2str(plot_mode),'.avi'];
                    elseif mode == 3
                        video_name = [video_folder,'Trial_',num2str(trial_i),'_HBfix_',num2str(plot_mode),'.avi'];
                    else
                        error('Wrong mode');
                    end
                end
                v = VideoWriter(video_name);
                close(v);
                open(v);
            end
            
            % load data and barrier_BFS
            if is_re == 1
                load([project.folder,'data_trial_',num2str(trial_i),'_beam_cal_re_',num2str(beam_cal_re),'.mat']);
                load([project.folder,'barrier_BFS_',num2str(trial_i),'_beam_cal_re_',num2str(beam_cal_re),'.mat']);
            else
                if mode == 1
                    load([project.folder,'data_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
                    load([project.folder,'barrier_BFS_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat']);
                    
%                     load([project.folder,'data_trial_',num2str(trial_i),'_groundtruth.mat']);
%                     load([project.folder,'barrier_BFS_',num2str(trial_i),'_groundtruth.mat']);
                elseif mode == 2
                    load([project.folder,'data_trial_',num2str(trial_i),'_headfix.mat']);
                    load([project.folder,'barrier_BFS_',num2str(trial_i),'_headfix.mat']);
                elseif mode == 3
                    load([project.folder,'data_trial_',num2str(trial_i),'_HBfix.mat']);
                    load([project.folder,'barrier_BFS_',num2str(trial_i),'_HBfix.mat']);
                else
                    error('Wrong mode');
                end
                
            end
            
            %% video
            % frames
            Frame_num = length(barrier_BFS.route);
            % for each frame
            for frame_i = 1:Frame_num
                
                %%% loading your landscape at this head_pitch_b, this frame
                roll_length = size(data.landscape_value,2);
                pitch_length = size(data.landscape_value,3);
                landscape = reshape(data.landscape_value(frame_i,:,:),[roll_length,pitch_length])';
                body_roll = reshape(data.body_roll(frame_i,:,:),[roll_length,pitch_length])';
                body_pitch = reshape(data.body_pitch(frame_i,:,:),[roll_length,pitch_length])';
                body_roll = body_roll*180/pi;
                body_pitch = body_pitch*180/pi;
                
                if frame_i == 1
                    % plot the first frame
                    figure(1);
                    clf;
                    hold on;
                    colormap(fire);
                    set(gcf,'Position',[20,50,850,850]);
                    
                    if plot_mode == 1
                        linecolor = 'w';
                    else
                        linecolor = 'k';
                    end
                    
                    s1 = surf(body_roll,body_pitch,landscape,'EdgeAlpha',0);
                    l1 = plot3(barrier_BFS.R_route(frame_i).roll,barrier_BFS.R_route(frame_i).pitch,barrier_BFS.R_route(frame_i).energy,...
                        'LineStyle','-','LineWidth',1,'Color',linecolor);
                    l2 = plot3(barrier_BFS.R_route(frame_i).roll(1:frame_i),barrier_BFS.R_route(frame_i).pitch(1:frame_i),barrier_BFS.R_route(frame_i).energy(1:frame_i),...
                        'LineStyle','-','LineWidth',3,'Color',linecolor);
                    l3 = plot3(barrier_BFS.route(frame_i).roll,barrier_BFS.route(frame_i).pitch,barrier_BFS.route(frame_i).energy,...
                        'LineStyle',':','LineWidth',3,'Color',linecolor);
                    p1 = plot3(barrier_BFS.pitch_minimum.roll(frame_i),barrier_BFS.pitch_minimum.pitch(frame_i),barrier_BFS.pitch_minimum.energy(frame_i),...
                        'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',linecolor);
                    p2 = plot3(barrier_BFS.roll_minimum.roll(frame_i),barrier_BFS.roll_minimum.pitch(frame_i),barrier_BFS.roll_minimum.energy(frame_i),...
                        'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',linecolor);
                    p3 = plot3(barrier_BFS.saddle.roll(frame_i),barrier_BFS.saddle.pitch(frame_i),barrier_BFS.saddle.energy(frame_i),...
                        'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',linecolor);
                    p4 = plot3(barrier_BFS.R_route(frame_i).roll(frame_i),barrier_BFS.R_route(frame_i).pitch(frame_i),barrier_BFS.R_route(frame_i).energy(frame_i),...
                        'o','MarkerFaceColor','g','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor',linecolor);
                    
                    set(gca, 'XDir','reverse');
                    xlim([-120,120]);
                    ylim([-90,90]);
                    set(gca,'FontSize', 20);
                    colorbar;
                    view([-135,70]);
                    
                    if plot_mode == 1
                        
                    elseif plot_mode == 2
                        zlim([0,5]);
                        caxis([0.1,0.7]);
                        
                    elseif plot_mode == 3
                        zlim([0,5]);
                        if ~isnan(barrier_BFS.saddle.energy(frame_i))
                            caxis([-0.2,0.1]+barrier_BFS.saddle.energy(frame_i));
                        else
                        end
                    else
                        
                    end
                    
                else
                    s1.ZData = landscape;
                    l1.ZData = barrier_BFS.R_route(frame_i).energy;
                    l2.XData = barrier_BFS.R_route(frame_i).roll(1:frame_i);
                    l2.YData = barrier_BFS.R_route(frame_i).pitch(1:frame_i);
                    l2.ZData = barrier_BFS.R_route(frame_i).energy(1:frame_i);
                    l3.XData = barrier_BFS.route(frame_i).roll;
                    l3.YData = barrier_BFS.route(frame_i).pitch;
                    l3.ZData = barrier_BFS.route(frame_i).energy;
                    p1.XData = barrier_BFS.pitch_minimum.roll(frame_i);
                    p1.YData = barrier_BFS.pitch_minimum.pitch(frame_i);
                    p1.ZData = barrier_BFS.pitch_minimum.energy(frame_i);
                    p2.XData = barrier_BFS.roll_minimum.roll(frame_i);
                    p2.YData = barrier_BFS.roll_minimum.pitch(frame_i);
                    p2.ZData = barrier_BFS.roll_minimum.energy(frame_i);
                    p3.XData = barrier_BFS.saddle.roll(frame_i);
                    p3.YData = barrier_BFS.saddle.pitch(frame_i);
                    p3.ZData = barrier_BFS.saddle.energy(frame_i);
                    p4.XData = barrier_BFS.R_route(frame_i).roll(frame_i);
                    p4.YData = barrier_BFS.R_route(frame_i).pitch(frame_i);
                    p4.ZData = barrier_BFS.R_route(frame_i).energy(frame_i);
                    
                    if plot_mode == 3
                        if ~isnan(barrier_BFS.saddle.energy(frame_i))
                            caxis([-0.2,0.1]+barrier_BFS.saddle.energy(frame_i));
                        else
                        end
                    end
                end
                
                
                % insert frame in video
                if is_video
                    frame = getframe(gcf);
                    writeVideo(v,frame);
                else
                    drawnow;
                    pause(0.05);
                end
                
            end
            
            if is_video
                close(v);
            end
            
            %% figure
            time = (1:Frame_num)/100;
            % gether R_energy
            R_energy = nan(1,Frame_num);
            % for each frame
            for frame_i = 1:Frame_num
                R_energy(frame_i) = barrier_BFS.R_route(frame_i).energy(frame_i);
            end
            % plot
            f2 = figure(2);
            set(f2,'Position',[10,10,650, 510]);
            clf;
            hold on;
            lp = plot(time,barrier_BFS.pitch_minimum.energy,...
                'Color','b','LineWidth',3);
            lr = plot(time,barrier_BFS.roll_minimum.energy,...
                'Color','r','LineWidth',3);
            ls = plot(time,barrier_BFS.saddle.energy,...
                'Color',[0.9294,0.6902,0.1294],'LineWidth',3);
            lre = plot(time,R_energy,...
                'Color','g','LineWidth',3);
            
            y_max = nanmax([barrier_BFS.pitch_minimum.energy,barrier_BFS.roll_minimum.energy,barrier_BFS.saddle.energy,R_energy]);
            y_min = nanmin([barrier_BFS.pitch_minimum.energy,barrier_BFS.roll_minimum.energy,barrier_BFS.saddle.energy,R_energy]);
            y_lim = ([y_min,y_max] - (y_min+y_max)/2)*1.2 + (y_min+y_max)/2;
            
            x1 = DataBase.Trial(trial_i).Info.RollStartFrame - DataBase.Trial(trial_i).Info.TouchFrame;
            x2 = DataBase.Trial(trial_i).Info.Roll60inFrame - DataBase.Trial(trial_i).Info.TouchFrame;
            x3 = DataBase.Trial(trial_i).Info.RollMaxFrame - DataBase.Trial(trial_i).Info.TouchFrame;
            l1 = line([x1,x1]/100,y_lim,'LineStyle','--','LineWidth',2,'Color','b');
            l2 = line([x2,x2]/100,y_lim,'LineStyle','--','LineWidth',2,'Color','k');
            l3 = line([x3,x3]/100,y_lim,'LineStyle','--','LineWidth',2,'Color','r');
            
            box on;
            grid on;
            xlim([0,time(end)]);
            %     ylim(y_lim);
            ylim([0,1.2]);
            set(gca,'FontSize', 20);
            
            if is_re == 1
                saveas(f2,[video_folder,'Trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.jpg']);
            else
                if mode == 1
                    saveas(f2,[video_folder,'Trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.jpg']);
%                     saveas(f2,[video_folder,'Trial_',num2str(trial_i),'_groundtruth.jpg']);
                elseif mode == 2
                    saveas(f2,[video_folder,'Trial_',num2str(trial_i),'_headfix.jpg']);
                elseif mode == 3
                    saveas(f2,[video_folder,'Trial_',num2str(trial_i),'_HBfix.jpg']);
                else
                    error('Wrong mode');
                end
            end
            
        end
    end
end
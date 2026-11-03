%% Tracking BEETAGS
%%% Yaqing Modified 8/17/2018, to adapt this code to code
%%% ReconstructMotion_V5.m(modified by Rick on 8/15/2018)
clear;clc;close all;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
%opengl('save', 'software');
addpath(genpath('D:\Dropbox (Terradynamics Lab)\Everyone\Resources\Codes\'))

CamNum = 8;
codelist = [1,4,9,15,646 699 703 671 631 652 657 698 702 666 688 692 656 661];
MainFolder = [REPO,'/raw_videos/f1_raw_videos/']; % save your compressed camera videos
TrackedVideoFolder = [REPO,'/tracking/p1_tracking/']; % To save your tracked videos
TrackedDataFolder = [REPO,'/tracking/p1_tracking/']; % To save your tracked data
IsSaveVid = 0;

testedthreshold=[0.30 0.44 0.30 0.30 0.30 0.30 0.30 0.30];

cd(MainFolder);
for Trial = 1:length(dir('*.avi'))/CamNum
    disp(Trial);
    for Cam = 1:CamNum
        VidName = ['Trial_',num2str(Trial),'_Cam_',num2str(Cam),'.avi'] ;
        DataName = ['Trial_',num2str(Trial),'_Cam_',num2str(Cam),'.mat'] ;
        
        if isfile([TrackedDataFolder,DataName])
            continue;
        end
        
        cd(MainFolder);
        obj = VideoReader(VidName);
        frames = 1:obj.NumberOfFrames;
        trackingData = struct();
        
        for i = 1:length(frames)
            
            disp(['Frame ',num2str(i),' tracking']);
            I = read(obj,frames(i));
            dat=locateCodes2(I,'vis',0,'tagList',codelist,'threshMode',0,'thresh',testedthreshold(Cam),'sizeThresh',100);drawnow; % core tracking code 
            trackingData(i).F = dat;
        end
        TrackDat2 = struct();
        nframes = length(frames);
        ks = 0;
        for j = 1:numel(codelist)
            ks=ks+1;
        end
        for k = 1:ks
            for i = 1:nframes
                TrackDat2(k).CentroidX(i) = NaN;
                TrackDat2(k).CentroidY(i) = NaN;
                TrackDat2(k).CornersX(i,:) = [NaN;NaN;NaN;NaN];
                TrackDat2(k).CornersY(i,:) = [NaN;NaN;NaN;NaN];
                TrackDat2(k).FrontX(i) = NaN;
                TrackDat2(k).FrontY(i) = NaN;
                TrackDat2(k).number(i) = NaN;
                TrackDat2(k).Orientation(i) = NaN;
                TrackDat2(k).orientation(i) = NaN;
                TrackDat2(k).Area(i) = NaN;
                TrackDat2(k).Frame(i) = NaN;
            end
        end
        for i = 1:nframes
            k=0;
            F = trackingData(i).F;
            for j = 1:numel(codelist)
                k=k+1;
                if ~isempty(F)
                    FS = F([F.number] == 0);
                    for ii=1:length([F.number])
                        if F(ii).number == codelist(j)
                            FS = F(ii);
                            break;
                        end 
                    end
                    if ~isempty(FS)
                        TrackDat2(k).CentroidX(i) = FS.Centroid(1);
                        TrackDat2(k).CentroidY(i) = FS.Centroid(2);
                        TrackDat2(k).CornersX(i,:) = FS.Corners(1,:);
                        TrackDat2(k).CornersY(i,:) = FS.Corners(2,:);
                        TrackDat2(k).FrontX(i) = FS.frontX;
                        TrackDat2(k).FrontY(i) = FS.frontY;
                        TrackDat2(k).number(i) = FS.number;
                        TrackDat2(k).Orientation(i) = FS.Orientation;
                        TrackDat2(k).orientation(i) = FS.orientation;
                        TrackDat2(k).Area(i) = FS.Area;
                        TrackDat2(k).Frame(i) = frames(i);
                    %%%%%%%%%%%%%
                    else
                        TrackDat2(k).CentroidX(i) = NaN;
                        TrackDat2(k).CentroidY(i) = NaN;
                        TrackDat2(k).CornersX(i,:) = [NaN;NaN;NaN;NaN];
                        TrackDat2(k).CornersY(i,:) = [NaN;NaN;NaN;NaN];
                        TrackDat2(k).FrontX(i) = NaN;
                        TrackDat2(k).FrontY(i) = NaN;
                        TrackDat2(k).number(i) = NaN;
                        TrackDat2(k).Orientation(i) = NaN;
                        TrackDat2(k).orientation(i) = NaN;
                        TrackDat2(k).Area(i) = NaN;
                        TrackDat2(k).Frame(i) = NaN;
                    %%%%%%%%%%%%%
                    end
                else
                    TrackDat2(k).CentroidX(i) = NaN;
                    TrackDat2(k).CentroidY(i) = NaN;
                    TrackDat2(k).CornersX(i,:) = [NaN;NaN;NaN;NaN];
                    TrackDat2(k).CornersY(i,:) = [NaN;NaN;NaN;NaN];
                    TrackDat2(k).FrontX(i) = NaN;
                    TrackDat2(k).FrontY(i) = NaN;
                    TrackDat2(k).number(i) = NaN;
                    TrackDat2(k).Orientation(i) = NaN;
                    TrackDat2(k).orientation(i) = NaN;
                    TrackDat2(k).Area(i) = NaN;
                    TrackDat2(k).Frame(i) = NaN;
                    %%%%%%%%%%%%%
                end
            end
        end
        im_size = size(I);
        %% Save data
        cd(TrackedDataFolder);
        save(DataName, 'TrackDat2','im_size')
        %% Save Video
        if IsSaveVid==1
            cd(TrackedVideoFolder);
            TD = TrackDat2;
            disp('replaying video with tracking data shown');
            OutputMovie = 1; %Set to 1 if you want to save a movie, set to 0 if not
            f = figure;
            if OutputMovie == 1
                vidObj = VideoWriter(VidName);
                vidObj.FrameRate = 100;
                open(vidObj)
            end
            set(f,'position',[0 0 1280/4 1024/4]);
            n = 0;
            for i = 1:length(frames)
                disp(['Frame ',num2str(i),' saving file']);
                n = n+1;
                im = read(obj, frames(i));
                imshow(im);
                set(f,'position',[1 1 1280/2 1024/2]);
                hold on;
                if numel(TD)~=1
                    for j = 1:numel(TD)
                        if numel(TD(j).CentroidX) >= n && ~isnan(TD(j).CentroidX(n))
                            try
                                plot([TD(j).CentroidX(n)-2*sqrt(TD(j).Area(n))*sind(TD(j).Orientation(n)) TD(j).CentroidX(n)+2*sqrt(TD(j).Area(n))*sind(TD(j).Orientation(n))],...
                                    [TD(j).CentroidY(n)-2*sqrt(TD(j).Area(n))*cosd(TD(j).Orientation(n)) TD(j).CentroidY(n)+2*sqrt(TD(j).Area(n))*cosd(TD(j).Orientation(n))],...
                                    'color','r','linewidth',2);plot(TD(j).CentroidX(n)-2*sqrt(TD(j).Area(n))*sind(TD(j).Orientation(n)), TD(j).CentroidY(n)-2*sqrt(TD(j).Area(n))*cosd(TD(j).Orientation(n)),'ro','markerfacecolor','r','markersize',15);
                                text(TD(j).CentroidX(n)+5, TD(j).CentroidY(n)+5, num2str(TD(j).number(n)),'FontSize', 25, 'Color', 'b');
                            catch
                                continue
                            end
                        end
                    end
                end
                drawnow
                CurrentFrame = getframe(f);
                writeVideo(vidObj, CurrentFrame);
                hold off;
            end
            close(vidObj);
        end
        close all
        clearvars -except txt codelist MainFolder TrackedVideoFolder TrackedDataFolder VideoFolder CamNum Trial testedthreshold IsSaveVid
        cd(MainFolder);
    end
end



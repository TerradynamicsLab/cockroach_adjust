%%% Tommy Mitchel 2017, based of code by Yuanfeng Han & Sean Gart
%%% Ratan cleaned up the code later.
%%% Rick Han Modified 7/23/2018, Modified for autonomous force experiments
%%% Rick Han Modified 8/15/2018, Solving the problem of one camera never
%%% track one tag and remove the empty structure in the data saving and add
%%% tag ID
%%% n-camera 3D reconstruction. Uses all available cameras to do reconstruction.

clear;clc;close all;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
% visualization and saving data?
Vis = 0; Sav = 1; Reproject = 0;

% Specify some default arguments
enableFill = 0;
enableSmooth = 0;

%number of cameras
num_cam = 8;

% load info
info_file = [REPO,'/data/info/Info.xlsx'];
[info_num, info_txt] = xlsread(info_file);
info_cal_series = info_txt(2:end,8);

%  calibration folder
cal_folder = [REPO,'/data/calibration/'];

% Source for tracked data and calibration
folderpath = [REPO,'/tracking/p1_tracking/']; % Tracked data folder

% Tags used in video
tagList = [1,4,9,15,646 699 703 671 631 652 657 698 702 666 688 692 656 661];

% save folder
save_folder = [REPO,'/data/reconstruction/f2_tags/'];


% loop over all experimental trials
for trial = 1:133
    disp(trial);
    
    % Read the calibration file
    calibFile = [cal_folder,'cal_',char(info_cal_series(trial)),'DLTcoefs.csv'];
    calibFile = csvread(calibFile);
    
    % Loop over all the cameras
    for i = 1:num_cam
        pts{i} = load([folderpath,'Trial_',num2str(trial),'_Cam_',num2str(i),'.mat']);
        for j = 1:length(tagList)
            Lk(i,j) = length(pts{i}.TrackDat2(j).number);
        end
        Ik{i} = find(Lk(i,:));
    end
    
    mov_size = fliplr(pts{1}.im_size(1:2));
    
    n = 0;
    for i = 1:num_cam-1
        for j = i+1:num_cam
            n = n+1;
            tgs{n} = intersect(Ik{i}, Ik{j});
        end
    end
    
    tags = [];
    for i = 1:length(tgs)
        tags = union(tags, tgs{i});
    end
    
    totaltags = length(tags);
    
    for i = 1:totaltags
        ii = tags(i);
        Y = max(Lk(:, ii));
        
        for j = 1:num_cam
            
            if Lk(j, ii) > 0
  
                camPts{ii}.centerXY(1:Y, (2*j)-1:2*j) = [pts{j}.TrackDat2(ii).CentroidX(1:Y)', (mov_size(2) - pts{j}.TrackDat2(ii).CentroidY(1:Y))'];
                camPts{ii}.frontXY(1:Y, (2*j)-1:2*j) = [pts{j}.TrackDat2(ii).FrontX(1:Y)', (mov_size(2) - pts{j}.TrackDat2(ii).FrontY(1:Y))'];
                
                camPts{ii}.centerXY(camPts{ii}.centerXY == 0) = NaN;
                camPts{ii}.frontXY(camPts{ii}.frontXY == 0) = NaN;
                
                % Tag Corner orietnation
                %        [C1]-----[F]-----[ ]
                %         |                |
                %         |                |
                %         |      [XYZ]     |
                %         |                |
                %         |                |
                %        [C2]-------------[ ]
                
                for l = 1:Y
                    if pts{j}.TrackDat2(ii).CornersX(l, 1) == 0
                        camPts{ii}.corner1XY(l, (2*j)-1:2*j) = [NaN, NaN];
                        camPts{ii}.corner2XY(l, (2*j)-1:2*j) = [NaN; NaN];
                    else
                        corners = [pts{j}.TrackDat2(ii).CornersX(l, 1:4)', (mov_size(2) - pts{j}.TrackDat2(ii).CornersY(l, 1:4))'];
                        
                        % Vector pointing to the front of the tag
                        f_vect = (camPts{ii}.frontXY(l, (2*j)-1:2*j) - camPts{ii}.centerXY(l, (2*j)-1:2*j));
                        f_vect = (f_vect/norm(f_vect))';
                        
                        % 2D rotation matrix
                        R_I_cent = [f_vect, [-f_vect(2); f_vect(1)]];
                        
                        % 2D transformation matrix
                        g_I_cent = [R_I_cent, camPts{ii}.centerXY(l, (2*j)-1:2*j)'; 0, 0, 1];
                        
                        % g_cent_I = inv(g_I_cent);
                        % Closed form inverse transformation - more numerically
                        % stable since it does not involve matrix inversion
                        g_cent_I = [R_I_cent' , -R_I_cent'*g_I_cent(1:2,3);0 0 1];
                        
                        % code to get the right corner every time
                        for k = 1:4
                            c_cent_I = g_cent_I*([corners(k, 1:2)'; 1]);
                            c_rot(k, 1:2) = c_cent_I(1:2)';
                            th = atan2(c_rot(k, 2), c_rot(k, 1));
                            if th >= 0
                                theta(k, 1:2) = [k, th]; %#ok<*SAGROW>
                            else
                                theta(k, 1:2) = [k, 2*pi + th];
                            end
                        end
                        
                        [~, ind1] = min(theta(:, 2));
                        c_ind1 = theta(ind1, 1);
                        count = 0;
                        for k = 1:setdiff(1:4, c_ind1)
                            count = count + 1;
                            theta2(count, 1:2) = theta(k, 1:2);
                        end
                        [~, ind2] = min(theta2(:, 2));
                        c_ind2 = theta(ind2, 1);
                        
                        camPts{ii}.corner1XY(l, (2*j)-1:2*j) = [pts{j}.TrackDat2(ii).CornersX(l, c_ind1), (mov_size(2) - pts{j}.TrackDat2(ii).CornersY(l, c_ind1))];
                        camPts{ii}.corner2XY(l, (2*j)-1:2*j) = [pts{j}.TrackDat2(ii).CornersX(l, c_ind2), (mov_size(2) - pts{j}.TrackDat2(ii).CornersY(l, c_ind2))];
                    end
                end
            else
                camPts{ii}.centerXY(1:Y, (2*j)-1:2*j) = nan;
                camPts{ii}.frontXY(1:Y, (2*j)-1:2*j) = nan;
                camPts{ii}.corner1XY(l, (2*j)-1:2*j) = nan;
                camPts{ii}.corner2XY(l, (2*j)-1:2*j) = nan;
            end
        end
        
        % Reconstruct the motion without filling/smoothing
        [tag(ii).xyz, ~]  = dlt_reconstruct3D(calibFile, camPts{ii}.centerXY);
        tag(ii).xyz(tag(ii).xyz == 0) = NaN;
        
        [tag(ii).fxyz, ~] = dlt_reconstruct3D(calibFile, camPts{ii}.frontXY);
        tag(ii).fxyz(tag(ii).fxyz == 0) = NaN;
        
        [tag(ii).c1xyz, ~] = dlt_reconstruct3D(calibFile, camPts{ii}.corner1XY);
        tag(ii).c1xyz(tag(ii).c1xyz == 0) = NaN;
        
        [tag(ii).c2xyz, ~] = dlt_reconstruct3D(calibFile, camPts{ii}.corner2XY);
        tag(ii).c2xyz(tag(ii).c2xyz == 0) = NaN;
        
        % Fill missing data if required
        %         if (enableFill)
        %             tag(ii).xyz = fillmissing(tag(ii).xyz, 'spline', 1,'endvalues' , 'none');
        %             tag(ii).fxyz = fillmissing(tag(ii).fxyz, 'spline', 1,'endvalues' , 'none');
        %             tag(ii).c1xyz = fillmissing(tag(ii).c1xyz, 'spline', 1,'endvalues' , 'none');
        %             tag(ii).c2xyz = fillmissing(tag(ii).c2xyz, 'spline', 1,'endvalues' , 'none');
        %         end
        
        % Smooth the data if required
        %         if (enableSmooth)
        %             tag(ii).xyz = smooth2a(tag(ii).xyz, 6, 0);
        %             tag(ii).fxyz = smooth2a(tag(ii).fxyz(:, 1:3), 6, 0);
        %             tag(ii).c1xyz = smooth2a(tag(ii).c1xyz, 6, 0);
        %             tag(ii).c2xyz = smooth2a(tag(ii).c2xyz, 6, 0);
        %         end
        
        %Find orientation: x axis points toward front of tag; z axis points
        %out the tag; y axis points to the left of the tag
        
        for l = 1:Y
            x_axis = (tag(ii).fxyz(l, 1:3) - tag(ii).xyz(l, 1:3))/ norm(tag(ii).fxyz(l, 1:3) - tag(ii).xyz(l, 1:3));
            c1v = tag(ii).c1xyz(l, 1:3) - tag(ii).xyz(l, 1:3);
            z_axis = cross(x_axis, c1v)/norm(cross(x_axis, c1v));
            y_axis = cross(z_axis, x_axis);
            R = [x_axis', y_axis', z_axis'];
            
            tag(ii).Rotation(:,:,l) = R;
            euler_angles = rotm2eul(R);
            
            tag(ii).yaw(l) = euler_angles(1);
            tag(ii).pitch(l) = euler_angles(2);
            tag(ii).roll(l) = euler_angles(3);
            %             tag(ii).shell3D{l,1} = DLTBody(point,tag.xyz(l,:),tag.Rotation(:,:,l));
            %             tag(ii).rc(l,:) = tag(ii).shell3D{l,1}(1,:); %obtain rotation center
            %             tag.heading(l,1) = atan2d(Pil(2)-tag.shell3D{l}(1,2),Pil(1)-tag.shell3D{l}(1,1)) - tag.yaw(l)/pi*180; %obtain heading in 2D
            tag(ii).ID = ii;
        end
    end
    
    tag = tag(~cellfun(@isempty,{tag.xyz}));
    
    if Sav == 1
        save([save_folder,'Trial_',num2str(trial),'.mat'],'tag'); %DLT saving folder
    end
    
    if Vis == 1
        
        % load point cloud and .obj file
        
        S = loadawobj('D:\Dropbox (Terradynamics Lab)\Rick\Tracked Data Testing New Code\Robot Info\RobotAssembly.obj');
        
        % setup movie saving directory
        outputMovieName = ['F:\New Robot Pillar Experiment 8-9-2018\DLT Video\Trial_',num2str(trial),'.avi'];
        vidObj = VideoWriter(outputMovieName); %#ok<TNMLP>
        vidObj.FrameRate=100;
        open(vidObj)
        
        % setup figure size
        f = figure; set(f,'position',[10,10,800,600]);
        
        for jj = 1:length(tag.xyz)
            disp(jj);
            PillarConstruct();hold on
            DrawObject(point,S,tag.xyz(jj,:),tag.Rotation(:,:,jj));axis equal;
            plot3(tag.shell3D{jj}(:,1),tag.shell3D{jj}(:,2),tag.shell3D{jj}(:,3),'.');hold on;
            plot3(tag.rc(jj,1),tag.rc(jj,2),tag.rc(jj,3),'s','MarkerFaceColor','r'),axis equal
            xlim([-50,250]);ylim([-50,200]);zlim([-5,350]);view([-50,34]);%view([0,0,1]);
            xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)');
            set(gcf,'color','w'); set(gca,'FontSize',20);
            box on; grid off; drawnow;
            currFrame = getframe(f);
            writeVideo(vidObj, currFrame);
            hold off;
        end
        
        close(vidObj);
        close all;
    end
    
    if Reproject == 1
        for kk = 1%: num_cam
            
            obj = VideoReader(['F:\New Robot Pillar Experiment 8-9-2018\Compressed Videos\Camera_',num2str(kk),'_Trial_',num2str(trial),'.avi']);
            frames = 1:obj.NumberOfFrames;
            n = length(frames);
            
            for m = 1:length(tag.xyz)
                if isempty(tag.shell3D{m})~= 1
                    shell2D{m} = dlt_inverse(calibFile(:,kk),tag.shell3D{m});
                    xyz2D(m,:) = dlt_inverse(calibFile(:,kk),tag.xyz(m,:));
                end
            end
            
            f1 = figure(2);
            outputMovieName = ['F:\New Robot Pillar Experiment 8-8-2018\Reprojection\Camera_',num2str(kk),'_Trial_',num2str(trial),'.avi'];
            vidObj = VideoWriter(outputMovieName); %#ok<TNMLP>
            vidObj.FrameRate=100;
            open(vidObj)
            
            for q = 1:length(tag.xyz)
                I = read(obj,q);
                imshow(I);hold on;set(f1, 'Position', [100,100,600,800]);
                
                try
                    plot(shell2D{q}(:,1),size(I,1)-shell2D{q}(:,2),'.','LineWidth',1,'color',[0,1,0]); hold on
                    plot(xyz2D(q,1),size(I,1)-xyz2D(q,2),'o','LineWidth',1,'color','r','MarkerSize',10,'MarkerFaceColor','r'); hold on
                catch
                end
                
                %view(-90,90);
                drawnow
                currFrame = getframe(f1);
                writeVideo(vidObj, currFrame);
                hold off;
            end
            close(vidObj);
            close all;
        end
    end
    
    clearvars -except info_cal_series cal_folder Vis Sav Reproject enableFill enableSmooth num_cam folderpath calibFile trial Pil tagList save_folder
end
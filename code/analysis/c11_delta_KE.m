% Yaqing created this on 07/02/2020 to calculate the delta_KE

close all;clear;clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root
%%
save_folder = [REPO,'/data/kinematics/delta_KE/'];
%%  Load DataBase
DataBase_file = [REPO,'/data/kinematics/DataBase'];
load(DataBase_file);

kinetic_energy_holder = NaN(1,DataBase.TrialNum);

% params
body_mass = 2.9e-3;
head_mass = 0;
body_Ixx = 120e-9;
body_Iyy = 317e-9;
body_Izz = 421e-9;
head_Ixx = 0;
head_Iyy = 0;
head_Izz = 0;

InfoFile = [REPO,'/data/info/Info.xlsx'];

%  Loading Info in each Trial
[InfoNum,InfoText] = xlsread(InfoFile,'selected_36');
[m,n] = size(InfoText);


for trial_i = 1:DataBase.TrialNum
    % calculate kinetic energy
    %%% extract motions
    extract_frames = DataBase.Trial(trial_i).Info.TouchFrame:DataBase.Trial(trial_i).Info.LandFrame;
%     extract_frames =InfoNum(trial_i,28):InfoNum(trial_i,29);
    extract_frame_num = length(extract_frames);
    body_x_spatial = DataBase.Trial(trial_i).modified.Cockroach.Body.com(extract_frames,1)*1e-3;
    body_y_spatial = DataBase.Trial(trial_i).modified.Cockroach.Body.com(extract_frames,2)*1e-3;
    body_z_spatial = DataBase.Trial(trial_i).modified.Cockroach.Body.com(extract_frames,3)*1e-3;
    body_eul_spatial = DataBase.Trial(trial_i).modified.Cockroach.Body.eul(extract_frames,:);
%     % eul angle filter
    body_eul_spatial(:,1) = fadaptiveB( body_eul_spatial(:,1),100,5,20,6);
    body_eul_spatial(:,2) = fadaptiveB( body_eul_spatial(:,2),100,5,20,6);
    body_eul_spatial(:,3) = fadaptiveB( body_eul_spatial(:,3),100,5,20,6);
    %%% calculate velocities
    %%%% body omega
    Rw2b = struct();
    Rw2b_dot = struct();
    body_omega_b = nan(3,extract_frame_num-1);
    for f = 1:extract_frame_num
        Rw2b(f).R = eul2rotm(body_eul_spatial(f,:));
    end
    for f = 1:extract_frame_num-1
        Rw2b_dot(f).R = Rw2b(f+1).R - Rw2b(f).R;
        body_omega_b_hat = Rw2b(f).R' * Rw2b_dot(f).R;
        body_omega_b(1,f) = body_omega_b_hat(3,2) * 100; %rad/s
        body_omega_b(2,f) = body_omega_b_hat(1,3) * 100; %rad/s
        body_omega_b(3,f) = body_omega_b_hat(2,1) * 100; %rad/s
    end
    %%%% body vy, vz
    [body_x_spatial_filtered,body_Vx_s,~] = fadaptiveB(body_x_spatial,100,5,20,6);
    [body_y_spatial_filtered,body_Vy_s,~] = fadaptiveB(body_y_spatial,100,5,20,6);
    [body_z_spatial_filtered,body_Vz_s,~] = fadaptiveB(body_z_spatial,100,5,20,6);
%     body_Vx_s = (body_x_spatial(2:end)-body_x_spatial(1:end-1))*100;
%     body_Vy_s = (body_y_spatial(2:end)-body_y_spatial(1:end-1))*100;
%     body_Vz_s = (body_z_spatial(2:end)-body_z_spatial(1:end-1))*100;
    body_Vy = nan(1,extract_frame_num-1);
    body_Vz = nan(1,extract_frame_num-1);
    for f = 1:extract_frame_num-1
        v_b = Rw2b(f).R'*[body_Vx_s(f);body_Vy_s(f);body_Vz_s(f)];
        body_Vx(f) = v_b(1);
        body_Vy(f) = v_b(2);
        body_Vz(f) = v_b(3);
    end
    %%% calculate kinetic_energy
    kinetic_energy = nan(1,extract_frame_num-1);
    for f = 1:extract_frame_num-1
        kinetic_energy(f) = 0 ...
            + 0.5 * body_mass * body_Vy(f)^2 ...
            + 0.5 * body_mass * body_Vz(f)^2 ...
            + 0.5 * [body_Ixx,body_Iyy,body_Izz] * (body_omega_b(:,f).*body_omega_b(:,f));
            % + 0.5 * head_mass * head_Vy(f)^2 ...
        %  + 0.5 * head_mass * head_Vz(f)^2 ...
        %  + 0.5 * [head_Ixx,head_Iyy,head_Izz] * (head_omega_b(:,f).*head_omega_b(:,f))...
    end
    kinetic_energy_average = nanmean(kinetic_energy);
    
    kinetic_energy_holder(trial_i) = kinetic_energy_average;
    
end

disp(mean(kinetic_energy_holder));
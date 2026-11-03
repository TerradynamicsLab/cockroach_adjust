clear; clc;
REPO = fileparts(fileparts(fileparts(mfilename('fullpath')))); % repository root

is_re = 0;
beam_cal_re = 0;
is_fix = 1;

project = struct();
% set project name and folder
project.name = 'barrier_3';
project.folder = [[REPO,'/output/landscape/'],project.name,'\'];

for trial_i = [37,1]
    data_file = [project.folder,'landscape_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat'];
    load(data_file);
    landscape.potential_energy(:,:,:,:,:,[1:19,55:73],:) = landscape.potential_energy(:,:,:,:,:,[1:19,55:73],[37:72,1:37]);
    landscape.left_beam_angle(:,:,:,:,:,[1:19,55:73],:) = landscape.left_beam_angle(:,:,:,:,:,[1:19,55:73],[37:72,1:37]);
    landscape.right_beam_angle(:,:,:,:,:,[1:19,55:73],:) = landscape.right_beam_angle(:,:,:,:,:,[1:19,55:73],[37:72,1:37]);
    save([project.folder,'landscape_trial_',num2str(trial_i),'_is_re_',num2str(is_re),'_beam_cal_re_',num2str(beam_cal_re),'_is_fix_',num2str(is_fix),'.mat'],'landscape');

end


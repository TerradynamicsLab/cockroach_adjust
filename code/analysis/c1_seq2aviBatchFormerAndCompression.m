% Code to generate batch files (.BAT) for seq2avi
% Terradynamics Lab - ywang460@jhu.edu - 2018

close all
clear all

%% USER INPUTS

% 1. Set Parent and Output Root Directory
% This it the top-level directory - the output folder will mirror the
% structure of this directory and its subfolders at a different destination
parentRootDir = 'N:\YWCockroachExperiment\11212018\';
SeqDataFile = 'N:\YWCockroachExperiment\11212018\11212018.xlsx';

% 2. Specify where you want to save the compressed videos
OutputRootDir = 'N:\YWCockroachExperiment\11212018\rawData\';

% 3. Specify the output BatchFile's name
outputBatchScript = 'C:\Users\Terradynamics\Documents\BatchProcessor\BatchProcessorSequential.bat';

% 4. Specify where you want to save the compressed videos
compressedOutputRootDir = 'N:\YWCockroachExperiment\11212018\data\';

% 5. Compression QFactor - stick with 3 or 4 
% lower QFactor = better quality, but larger size
compressionQFactor = 4;


%% Program will now create the batch file for you - after checking the contents of batch file using notepad, execute it.
% DO NOT MODIFY the following section if you are not familiar with BATCHFILES or FFMPEG
[num,txt,raw] = xlsread(SeqDataFile,'Trial');

trailNames = char(txt(2:length(txt(:,1)),2));
startFrames = num(1:length(num(:,1)),5);
endFrames = num(1:length(num(:,1)),6);
Cams=['E','F','G','H','I','J','K','L'];
Cam=[5,6,7,8,1,2,3,4];

aviFileList = [];


%% Program will now create the batch file for you - after checking the contents of batch file using notepad, execute it.
% DO NOT MODIFY the following section if you are not familiar with BATCHFILES or FFMPEG

% Create the Batch File
try
    delete(outputBatchScript);
catch CannotDeleteFileException
   disp('Could not delete file');
   disp(CannotDeleteFileException);
end

% Get the file ID
batFileID = fopen(outputBatchScript,'w');

% Loop through all the avi file found and make command to create the destionation folders
fprintf(batFileID, '\n');
for i = 1:length(trailNames(:,1))
    for j = 1:length(Cams)
        fprintf(batFileID, '\nchcp 65001\n');
        fprintf(batFileID, 'call "C:\\Program Files (x86)\\Norpix\\BatchProcessor\\clexport.exe" -i "%s:\\CAM%d__%s.seq" -o %s -s %d -e %d -f avi -log > "C:\\Users\\Terradynamics\\Documents\\BatchProcessor\\2018.10.10_11.34.08.014.log"\n',...
            Cams(j),Cam(j),trailNames(i,:),OutputRootDir,startFrames(i),endFrames(i));
        aviFileList = [aviFileList;['CAM' num2str(Cam(j)) '__' trailNames(i,:) '.avi']];
        fprintf(batFileID, '\n');
    end
end

%********************************************************

% Loop through all the avi file found and make command to create the destionation folders
for i = 1:length(aviFileList(:,1))
%   Get the video's folderpath and complete filename
    videoFolderPath = OutputRootDir;
    sourceVideoFName = [videoFolderPath aviFileList(i,:)];
    
%   Manipulate the source filename to get the output folderpath and filename    
    %outputVideoPath = [compressedOutputRootDir strrep(videoFolderPath,parentRootDir,[]) '\'];
    outputVideoPath = compressedOutputRootDir;
    outputVideoFName = [outputVideoPath aviFileList(i,:)];
    
end
%   Print the line in BAT file to make the directory if it does not exists
    fprintf(batFileID, 'if not exist "%s" MD "%s"\n', outputVideoPath,outputVideoPath);


% Loop through all the avi files to make command to create compressed videos
for i = 1:length(aviFileList(:,1))
%   Get the video's folderpath and complete filename
    videoFolderPath = OutputRootDir;
    sourceVideoFName = [videoFolderPath aviFileList(i,:)];
    
%   Manipulate the source filename to get the output folderpath and filename    
    %outputVideoPath = [compressedOutputRootDir strrep(videoFolderPath,parentRootDir,[]) '\'];
    outputVideoPath = compressedOutputRootDir;
    outputVideoFName = [outputVideoPath aviFileList(i,:)];

    if i ==1 % First line does not need tokens to link the subsequent commands
     fprintf(batFileID,'ffmpeg -i "%s" -vcodec libxvid -q:v %f -y "%s" ^\n',sourceVideoFName,compressionQFactor ,  outputVideoFName);   
     % vcodec: libxvid preferred; libx264 for mp4 files
    else % Remaining lines need tokens to link it to the previous command
     fprintf(batFileID,' & \t ffmpeg -i "%s" -vcodec libxvid -q:v %f -y "%s" ^\n',sourceVideoFName,compressionQFactor ,  outputVideoFName);   
    end
    
%     compressionCommandLine = ['ffmpeg -i ' sourceVideoFName ' -vcodec libxvid -q:v ' num2str(compressionQFactor) ' ' outputVideoFName];
%     fprintf(batFileID, compressionCommandLine);
%     fprintf(batFileID, '::----------------------------------------------------------------\n')
%     fprintf(batFileID, '\n')    
    
end


%***************************************************************************************************

% Close the batch file
fclose(batFileID);

disp('BATCH File created. Check the content using Notepad++ and quickly verify the contents before running the BAT file')

% IMplement chgeck for number of filesNN
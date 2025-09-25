% Define the main folder containing ROI images
mainFolder = 'C:\Data Samples\jpgimages';

% Define the output folder to store filtered images
filteredImagesFolder = 'C:\filteredimages';

% Create the output folder if it doesn't exist
if ~exist(filteredImagesFolder, 'dir')
    mkdir(filteredImagesFolder);
end

% Get a list of all subfolders in the jpgimages folder
subfolders = dir(mainFolder);
subfolders = subfolders([subfolders.isdir] & ~startsWith({subfolders.name}, '.'));

% Parameters for locallapfilter
sigma = 0.4;
alpha = 0.5;

% Loop through each subfolder
for k = 1:length(subfolders)
    % Get the subfolder path
    subfolderPath = fullfile(mainFolder, subfolders(k).name);
    
    % Get all JPG files in the subfolder
    jpgFiles = dir(fullfile(subfolderPath, '*.jpg'));
    
    % Create a corresponding subfolder in the filtered images folder
    filteredSubfolder = fullfile(filteredImagesFolder, subfolders(k).name);
    if ~exist(filteredSubfolder, 'dir')
        mkdir(filteredSubfolder);
    end
    
    % Process each JPG file in the subfolder
    for j = 1:length(jpgFiles)
        % Get the file path
        filePath = fullfile(subfolderPath, jpgFiles(j).name);
        
        % Read the JPG image
        img = imread(filePath);
        
        % Apply the local Laplacian filter
        filteredImg = locallapfilt(img, sigma, alpha);
        
        % Save the filtered image in the filtered images folder
        filteredFileName = fullfile(filteredSubfolder, jpgFiles(j).name);
        imwrite(filteredImg, filteredFileName, 'jpg');
    end
end

disp('Local Laplacian filtering complete. Filtered images are saved in the "C:\filteredimages" folder.');
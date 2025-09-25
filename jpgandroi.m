% Define the main folder containing subfolders with CR2 image files
mainFolder = 'C:\Data Samples';

% Define the folder to store JPG images
outputFolder = fullfile(mainFolder, 'jpgimages');

% Create the output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder); 
end

% Get a list of all subfolders
subfolders = dir(mainFolder);
subfolders = subfolders([subfolders.isdir] & ~startsWith({subfolders.name}, '.'));

% Define ROI coordinates (adjust based on the 2068x3355 dimensions)
xCoords = [1000, 2400, 2400, 1000]; % X-coordinates of the polygon
yCoords = [100, 100, 3400, 3400];  % Y-coordinates of the polygon

% Create a mask for the given ROI
fixedROIMask = poly2mask(xCoords, yCoords, 2068, 3355);

% Loop through each subfolder
for k = 1:length(subfolders)
    % Get the subfolder path
    subfolderPath = fullfile(mainFolder, subfolders(k).name);
    
    % Get all CR2 files in the subfolder
    cr2Files = dir(fullfile(subfolderPath, '*.cr2'));
    
    % Create a corresponding subfolder in the output JPG folder
    jpgSubfolder = fullfile(outputFolder, subfolders(k).name);
    if ~exist(jpgSubfolder, 'dir')
        mkdir(jpgSubfolder);
    end
    
    % Process each CR2 file in the subfolder
    for j = 1:length(cr2Files)
        % Get the file path
        filePath = fullfile(subfolderPath, cr2Files(j).name);
        
        % Read the CR2 image file
        rawImage = imread(filePath); % Ensure you have a CR2 plugin if needed
        
        % Convert the image to JPEG format
        jpgFileName = fullfile(jpgSubfolder, [cr2Files(j).name(1:end-4) '.jpg']);
        imwrite(rawImage, jpgFileName, 'jpg');
        
        % Read the converted JPEG image
        jpgImage = imread(jpgFileName);
        
        % Ensure the image has the specified dimensions (resize if needed)
        if size(jpgImage, 1) ~= 2068 || size(jpgImage, 2) ~= 3355
            jpgImage = imresize(jpgImage, [2068, 3355]);
        end
        
        % Apply the pre-defined ROI mask to the image
        roiImage = bsxfun(@times, jpgImage, cast(fixedROIMask, class(jpgImage)));
        
        % Save the ROI-masked image back in place of the original JPG
        imwrite(roiImage, jpgFileName, 'jpg'); % Overwrite the original image
    end
end

disp('Conversion to JPG and ROI processing with replacement complete.');
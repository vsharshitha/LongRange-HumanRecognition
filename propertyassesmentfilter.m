% Define the folder containing filtered images
filteredImagesFolder = 'C:\filteredimages';

% Define the main Excel sheet to store the concatenated results
mainExcelFile = fullfile(filteredImagesFolder, 'filteredimagemetrics.xlsx');

% Create or clear the main Excel file
if exist(mainExcelFile, 'file')
    delete(mainExcelFile); % Delete the file if it exists
end

% Get a list of all subfolders in the filteredimages folder
subfolders = dir(filteredImagesFolder);
subfolders = subfolders([subfolders.isdir] & ~startsWith({subfolders.name}, '.'));

% Loop through each subfolder
for k = 1:length(subfolders)
    % Get the subfolder path
    subfolderPath = fullfile(filteredImagesFolder, subfolders(k).name);
    
    % Get all JPG files in the subfolder
    jpgFiles = dir(fullfile(subfolderPath, '*.jpg'));
    
    % Initialize an array to store the assessment results for the subfolder
    results = {};
    
    % Process each JPG file in the subfolder
    for j = 1:length(jpgFiles)
        % Get the file path
        filePath = fullfile(subfolderPath, jpgFiles(j).name);
        
        % Read the JPG image
        img = imread(filePath);
        
        % Ensure the image is in grayscale for property assessment
        if size(img, 3) == 3
            img = rgb2gray(img); % Convert to grayscale if it's a color image
        end
        
        % Compute Mean
        imgMean = mean(img(:));
        
        % Compute Covariance Matrix (of the flattened image)
        imgCovariance = cov(double(img(:))');
        
        % Compute Sharpness (using Laplacian variance)
        %laplacian = fspecial('laplacian', 0.5);
        %laplacianImg = imfilter(double(img), laplacian, 'replicate');
        %sharpness = var(laplacianImg(:)); % Variance of the Laplacian
        [Gx, Gy] = gradient(double(img));
        gradient_magnitude = sqrt(Gx.^2 + Gy.^2);

        % Calculate sharpness as the average gradient magnitude
        sharpness = mean(gradient_magnitude(:));

        % Compute Standard Deviation
        imgStd = std(double(img(:)));
        
        % Store the results for the current image
        results{j, 1} = jpgFiles(j).name; % Image name
        results{j, 2} = imgMean;          % Mean
        results{j, 3} = imgCovariance(1, 1); % Covariance matrix (1x1, as we are flattening)
        results{j, 4} = sharpness;       % Sharpness
        results{j, 5} = imgStd;          % Standard Deviation
        
        % Save the results in an individual Excel sheet for this subfolder
        individualExcelFile = fullfile(subfolderPath, [subfolders(k).name '_metrics.xlsx']);
        writetable(cell2table(results, 'VariableNames', {'Image', 'Mean', 'Covariance', 'Sharpness', 'StdDev'}), individualExcelFile);
    end
    
    % After processing all images in the subfolder, save the results to the main Excel sheet
    if ~isempty(results)
        writetable(cell2table(results, 'VariableNames', {'Image', 'Mean', 'Covariance', 'Sharpness', 'StdDev'}), mainExcelFile, 'Sheet', subfolders(k).name);
    end
end

disp('Property assessment complete. Results saved in individual and main Excel sheets.');
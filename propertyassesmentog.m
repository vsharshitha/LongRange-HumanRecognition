% Define the main folder containing subfolders with CR2 image files
mainFolder = 'C:\Data Samples';

% Get a list of all subfolders
subfolders = dir(mainFolder);
subfolders = subfolders([subfolders.isdir] & ~startsWith({subfolders.name}, '.'));

% Initialize a cell array to store results for the Excel sheet
results = {'Subfolder', 'File Name', 'Mean', 'Covariance Matrix', 'Sharpness', 'Standard Deviation'};

% Loop through each subfolder
for k = 1:length(subfolders)
    % Get the subfolder path
    subfolderPath = fullfile(mainFolder, subfolders(k).name);
    
    % Get all CR2 files in the subfolder
    cr2Files = dir(fullfile(subfolderPath, '*.cr2'));
    
    % Process each CR2 file in the subfolder
    for j = 1:length(cr2Files)
        % Get the file path
        filePath = fullfile(subfolderPath, cr2Files(j).name);
        
        % Read the CR2 image file
        rawImage = imread(filePath); % Ensure you have a CR2 plugin if needed
        
        % Convert the image to grayscale for analysis
        grayImage = rgb2gray(rawImage);
        
        % Calculate the mean intensity
        meanIntensity = mean2(grayImage);
        
        % Calculate the covariance matrix
        covarianceMatrix = cov(double(grayImage(:)));
        
        % Calculate the sharpness (using the variance of the Laplacian method)
        %sharpness = var(imgradient(grayImage), 1, 'all');
        % Calculate gradient magnitude
        [Gx, Gy] = gradient(double(grayImage));
        gradient_magnitude = sqrt(Gx.^2 + Gy.^2);

        % Calculate sharpness as the average gradient magnitude
        sharpness = mean(gradient_magnitude(:));

        % Calculate the standard deviation of pixel intensities
        stdDeviation = std(double(grayImage(:)));
        
        % Store the results
        results{end+1, 1} = subfolders(k).name;          % Subfolder name
        results{end, 2} = cr2Files(j).name;             % File name
        results{end, 3} = meanIntensity;                % Mean
        results{end, 4} = mat2str(covarianceMatrix);    % Covariance matrix
        results{end, 5} = sharpness;                    % Sharpness
        results{end, 6} = stdDeviation;                 % Standard deviation
    end
end

% Save the results to a single Excel file in the main folder
excelFilePath = fullfile(mainFolder, 'imagemetrics.xlsx');
writecell(results, excelFilePath);

disp('Processing complete. Results saved to imagemetrics.xlsx.');
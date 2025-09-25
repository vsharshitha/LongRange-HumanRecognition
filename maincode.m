clc
clear all
close all
%Data Extraction
%disp(pwd); % Check current working directory
%disp(isfile('filter.zip')); % Check if file exists
%isfile('filter.zip')
unzip( 'filter.zip' );
imds = imageDatastore( 'filter' , ... 
    'IncludeSubfolders' ,true, ... 
    'LabelSource' , 'foldernames' );
%Data split and display
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7, 'randomized' );
numTrainImages = numel(imdsTrain.Labels);
idx = randperm(numTrainImages,16);
figure
for i = 1:16
    subplot(4,4,i)
    I = readimage(imdsTrain,idx(i));
    imshow(I)
end
%class label
classNames = categories(imdsTrain.Labels);
numClasses = numel(classNames)
%DL deployment
net = imagePretrainedNetwork( "alexnet" ,NumClasses=numClasses);
net = setLearnRateFactor(net, "fc8/Weights" ,20); % learn factor 
net = setLearnRateFactor(net, "fc8/Bias" ,20);
analyzeNetwork(net)
%input Size
inputSize = net.Layers(1).InputSize
%Data augmentation parameters
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ... 
    'RandXReflection' ,true, ... 
    'RandXTranslation' ,pixelRange, ... 
    'RandYTranslation' ,pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ... 
    'DataAugmentation' ,imageAugmenter);
%Data validation parameter
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);
%Training and epoc set
options = trainingOptions( "sgdm" , ... 
    MiniBatchSize=20, ... 
    MaxEpochs=20, ... 
    Metrics= "accuracy" , ... 
    InitialLearnRate=1e-4, ... 
    Shuffle= "every-epoch" , ... 
    ValidationData=augimdsValidation, ... 
    ValidationFrequency=3, ... 
    Verbose=false, ... 
    Plots= "training-progress" );
%Train
net = trainnet(augimdsTrain,net, "crossentropy" ,options);
scores = minibatchpredict(net,augimdsValidation);
YPred = scores2label(scores,classNames);
idx = randperm(numel(imdsValidation.Files),9);
figure
for i = 1:9
    subplot(3,3,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
end
YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation)
print('accuracy')
% im = imread( "Adarsh_H3.jpg");
% figure,imshow(im)
% X = single(im);
% 
% % scores = predict(net,X);
% % [label,score] = scores2label(scores,classNames);
% % 
% X = single(I);
% scores = predict(net,X);
% [label,score] = scores2label(scores,classNames);
% figure
% imshow(im)
% title(string(label) + " (Score: " + score + ")")
% X = single(im);
% 
 % if canUseGPU
 %     X = gpuArray(X);
 % end
% 
% scores = predict(net,X);
% label = scores2label(scores,classNames);
% 
% figure
% imshow(im)
% title( "Prediction: " + string(label))
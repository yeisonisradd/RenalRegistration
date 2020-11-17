%Yeison Rodriguez
%Week 10/20/20 - 10/27/20

clear;
load RenalRegistrationUpdatedVar.mat

%read in the file provided
I = dicomread("2D pCASL 16dyn00001.dcm");

sumImagesControl = 0;
sumImagesLabel = 0;

for image = 1:32
    if image <= 16
        %seperate into the two groups, first 16 are control
        dicomimgControl{image} = I(:,:,1, image);
        sumImagesControl = sumImagesControl + double(dicomimgControl{image});
    else
        %last 16 are label
        dicomimgLabel{image-16} = I(:,:,1,image);
        sumImagesLabel = sumImagesLabel + double(dicomimgLabel{image-16});
        
    end
    
end

%Clear I for space, it's no longer needed
I = 0;

%Calculate Average Control & Label
AverageControl = sumImagesControl/16;
AverageLabel = sumImagesLabel/16;


[controlIndex,labelIndex] = ClosestToAverage(AverageControl,AverageLabel,dicomimgControl,dicomimgLabel);
AverageDiff = 0;
for i = 1:16
    
    %create Registered Control & Label Images. Three transformations: Rigid,
    %affine, & Non-Rigid. Commented due to execution time. Use provided
    %variable file or uncomment to run program
    %   [~,regControl{i}] = elastix(dicomimgControl{i},dicomimgControl{controlIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
    %   [~,regLabel{i}] = elastix(dicomimgLabel{i},dicomimgLabel{labelIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
    
    RegisteredDynDiff{i} = abs(double(regControl{i}.transformedImages{3}) - double(regLabel{i}.transformedImages{3}));
    AverageDiff = AverageDiff + RegisteredDynDiff{i};
    
end
AverageDiff = AverageDiff/16;





%coregister the average label to the average control
[~,CoregLabel1] = elastix(AverageLabel,AverageControl,[],{'RigidParameters.txt','AffineParameters.txt'});





ASLImage1 = (abs(AverageControl - double(CoregLabel1.transformedImages{2})));
ASLImage2 = AverageDiff;


figure(1)
imshow(ASLImage1,[]);
title('Renal Perfusion Image Obtained without Registration Techniques');

figure(2)
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');


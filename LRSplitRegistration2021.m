%Yeison Rodriguez
%Week of 3/2/21

clear;


%read in the file provided
I = dicomread("20201208_2DpCASL.dcm");
I = 100*squeeze(I);
[row, col, numImages] = size(I);

sumImagesLeftControl = 0;
sumImagesRightControl = 0;
sumImagesLeftLabel = 0;
sumImagesRightLabel = 0;


for k = 1:numImages
    if k <= numImages/2
        %seperate into the two groups, first 16 are control
        dicomimgControl{k} = I(:,:,k);
        leftControl{k} = dicomimgControl{k}(:,1:col/2);
        rightControl{k} = dicomimgControl{k}(:,col/2 +1:col);
        sumImagesLeftControl = sumImagesLeftControl + double(leftControl{k});
        sumImagesRightControl = sumImagesRightControl + double(rightControl{k});
    else
        dicomimgLabel{k-numImages/2} = I(:,:,k);
        leftLabel{k-numImages/2} = dicomimgLabel{k-numImages/2}(:,1:col/2);
        rightLabel{k-numImages/2} = dicomimgLabel{k-numImages/2}(:,col/2 + 1:col);
        sumImagesLeftLabel = sumImagesLeftLabel + double(leftLabel{k-16});
        sumImagesRightLabel = sumImagesRightLabel + double(rightLabel{k-16});
        
        
    end
    
end



%Clear I for space, it's no longer needed
I = 0;

%Calculate Average Control & Label

AverageLeftControl = sumImagesLeftControl/16;
AverageRightControl = sumImagesRightControl/16;
AverageLeftLabel = sumImagesLeftLabel/16; 
AverageRightLabel = sumImagesRightLabel/16;

AverageControl(:,1:col/2) = AverageLeftControl;
AverageControl(:,col/2 + 1:col) = AverageRightControl;
AverageLabel(:,1:col/2) = AverageLeftLabel;
AverageLabel(:,col/2 + 1:col) = AverageRightLabel;
[controlIndex,labelIndex] = ClosestToAverage(AverageControl,AverageLabel,dicomimgControl,dicomimgLabel);
[controlLeftIndex,labelLeftIndex] = ClosestToAverage(AverageLeftControl,AverageLeftLabel,leftControl,leftLabel);
[controlRightIndex,labelRightIndex] = ClosestToAverage(AverageRightControl,AverageRightLabel,rightControl,rightLabel);


AverageDiff = 0;
for i = 1:numImages/2
    
    
 %create Registered Control & Label Images. Three transformations: Rigid, affine, & Non-Rigid
 [~,regLeftControl{i}] = elastix(leftControl{i},leftControl{controlIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
 [~,regRightControl{i}] = elastix(rightControl{i},rightControl{controlIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
 [~,regLeftLabel{i}] = elastix(leftLabel{i},leftLabel{labelIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
 [~,regRightLabel{i}] = elastix(rightLabel{i},rightLabel{labelIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});

end
save TestingVarLR2015.mat

sumRegLeftControl = 0;
sumRegRightControl = 0;
sumRegLeftLabel = 0;
sumRegRightLabel = 0;
%sum each image to find the average
for i = 1:16
    sumRegLeftControl = sumRegLeftControl + double(regLeftControl{i}.transformedImages{3});
    sumRegRightControl = sumRegRightControl + double(regRightControl{i}.transformedImages{3});
    sumRegLeftLabel = sumRegLeftLabel + double(regLeftLabel{i}.transformedImages{3});
    sumRegRightLabel = sumRegRightLabel + double(regRightLabel{i}.transformedImages{3});
    
end

%calculate the average of the registered images
AverageRegLeftControl = sumRegLeftControl/16;
AverageRegRightControl = sumRegRightControl/16;
AverageRegLeftLabel = sumRegLeftLabel/16;
AverageRegRightLabel = sumRegRightLabel/16;

[~,CoregLabelLeft] = elastix(AverageRegLeftLabel, AverageRegLeftControl, [], {'RigidParameters.txt','AffineParameters.txt'});
[~,CoregLabelRight] = elastix(AverageRegRightLabel, AverageRegRightControl, [], {'RigidParameters.txt','AffineParameters.txt'});

AverageRegControl(:,1:col/2) = AverageRegLeftControl;
AverageRegControl(:,col/2 + 1:col) = AverageRegRightControl;
CoregLabel(:,1:col/2) = CoregLabelLeft.transformedImages{2};
CoregLabel(:,col/2 + 1:col) = CoregLabelRight.transformedImages{2};

ASLImage2 = (abs(AverageRegControl - double(CoregLabel)));


figure(1)
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');

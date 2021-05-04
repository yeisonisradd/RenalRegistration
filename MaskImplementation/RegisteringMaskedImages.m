%read in the file provided
clear;
I = dicomread("2D pCASL 16dyn00001.dcm");
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
        
    else
        dicomimgLabel{k-numImages/2} = I(:,:,k);
        leftLabel{k-numImages/2} = dicomimgLabel{k-numImages/2}(:,1:col/2);
        rightLabel{k-numImages/2} = dicomimgLabel{k-numImages/2}(:,col/2 + 1:col);
        sumImagesLeftLabel = sumImagesLeftLabel + double(leftLabel{k-numImages/2});
        sumImagesRightLabel = sumImagesRightLabel + double(rightLabel{k-numImages/2});
        
        
    end
    
end

%create masks, right now that's not automatically determined, determined
%from the montage views of the dyanmics

%create mask for the left side
figure(1)
imshow(leftControl{5})
ROILeft = images.roi.AssistedFreehand
draw(ROILeft);
leftMask = createMask(ROILeft);
%create mask for the right side
figure(2)
imshow(rightControl{5})
ROIRight = images.roi.AssistedFreehand
draw(ROIRight);
rightMask = createMask(ROIRight);


for k = 1:numImages/2
    %apply mask to the left side of each dynamic
    leftControl{k} = leftMask.*double(leftControl{k});
    leftLabel{k} = leftMask.*double(leftLabel{k});
  
    %apply mask to the right side of each dynamic
    rightControl{k} = rightMask.*double(rightControl{k});
    rightLabel{k} = rightMask.*double(rightLabel{k});
    %sum the images to find the average for the control
    sumImagesLeftControl = sumImagesLeftControl + double(leftControl{k});
    sumImagesRightControl = sumImagesRightControl + double(rightControl{k});
    %sum the images to find the average for the label
    sumImagesLeftLabel = sumImagesLeftLabel + double(leftLabel{k});
    sumImagesRightLabel = sumImagesRightLabel + double(rightLabel{k});
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


% [controlLeftIndex,labelLeftIndex] = ClosestToAverage(AverageLeftControl,AverageLeftLabel,leftControl,leftLabel);
% [controlRightIndex,labelRightIndex] = ClosestToAverage(AverageRightControl,AverageRightLabel,rightControl,rightLabel);

AverageDiff = 0;
for i = 1:numImages/2
    
    
 %create Registered Control & Label Images. Two transformations: Rigid & Non-Rigid
 [~,regLeftControl{i}] = elastix(leftControl{i},leftControl{controlIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});
 [~,regRightControl{i}] = elastix(rightControl{i},rightControl{controlIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});
 [~,regLeftLabel{i}] = elastix(leftLabel{i},leftLabel{labelIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});
 [~,regRightLabel{i}] = elastix(rightLabel{i},rightLabel{labelIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});

end
save TestingVarLRLiOrig.mat

sumRegLeftControl = 0;
sumRegRightControl = 0;
sumRegLeftLabel = 0;
sumRegRightLabel = 0;
%sum each image to find the average
for i = 1:16
    sumRegLeftControl = sumRegLeftControl + double(regLeftControl{i}.transformedImages{2});
    sumRegRightControl = sumRegRightControl + double(regRightControl{i}.transformedImages{2});
    sumRegLeftLabel = sumRegLeftLabel + double(regLeftLabel{i}.transformedImages{2});
    sumRegRightLabel = sumRegRightLabel + double(regRightLabel{i}.transformedImages{2});
    
end

%calculate the average of the registered images
AverageRegLeftControl = sumRegLeftControl/16;
AverageRegRightControl = sumRegRightControl/16;
AverageRegLeftLabel = sumRegLeftLabel/16;
AverageRegRightLabel = sumRegRightLabel/16;

[~,CoregLabelLeft] = elastix(AverageRegLeftLabel, AverageRegLeftControl, [], {'RigidParameters.txt'});
[~,CoregLabelRight] = elastix(AverageRegRightLabel, AverageRegRightControl, [], {'RigidParameters.txt'});

AverageRegControl(:,1:col/2) = AverageRegLeftControl;
AverageRegControl(:,col/2 + 1:col) = AverageRegRightControl;
CoregLabel(:,1:col/2) = CoregLabelLeft.transformedImages{1};
CoregLabel(:,col/2 + 1:col) = CoregLabelRight.transformedImages{1};

ASLImage2 = (abs(AverageRegControl - double(CoregLabel)));


figure(3)
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');
%read in the file provided
clear;
I = dicomread("20201211_2DpCASL.dcm");
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
        
    end
    
end


for k = 1:numImages/2
    %sum the images to find the average for the control
    sumImagesLeftControl = sumImagesLeftControl + double(leftControl{k});
    sumImagesRightControl = sumImagesRightControl + double(rightControl{k});
    %sum the images to find the average for the label
    sumImagesLeftLabel = sumImagesLeftLabel + double(leftLabel{k});
    sumImagesRightLabel = sumImagesRightLabel + double(rightLabel{k});
end
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

%create mask for the left side of the control index
figure(1)
imshow(leftControl{controlIndex})
ROILeft = images.roi.AssistedFreehand
draw(ROILeft);
leftMaskC = createMask(ROILeft);
%create mask for the right side of the control index
figure(2)
imshow(rightControl{controlIndex})
ROIRight = images.roi.AssistedFreehand
draw(ROIRight);
rightMaskC = createMask(ROIRight);
%create mask for the left side of the label index
figure(3)
imshow(leftLabel{labelIndex})
ROILeft = images.roi.AssistedFreehand
draw(ROILeft);
leftMaskL = createMask(ROILeft);
%create mask for the right side of the control index
figure(4)
imshow(rightLabel{labelIndex})
ROIRight = images.roi.AssistedFreehand
draw(ROIRight);
rightMaskL = createMask(ROIRight);

%apply mask to reference index to create reference images
refLeftControl = leftMaskC.*double(leftControl{controlIndex});
refRightControl = rightMaskC.*double(rightControl{controlIndex});
refLeftLabel = leftMaskL.*double(leftLabel{labelIndex});
refRightLabel = rightMaskL.*double(rightLabel{labelIndex});
%Clear I for space, it's no longer needed
I = 0;

for i = 1:numImages/2
    
    
 %create Registered Control & Label Images. Two transformations: Rigid & Non-Rigid
 [~,regLeftControl{i}] = elastix(leftControl{i},refLeftControl,[],{'RigidParameters.txt','NonRigidParameters.txt'});
 [~,regRightControl{i}] = elastix(rightControl{i},refRightControl,[],{'RigidParameters.txt','NonRigidParameters.txt'});
 [~,regLeftLabel{i}] = elastix(leftLabel{i},refLeftLabel,[],{'RigidParameters.txt','NonRigidParameters.txt'});
 [~,regRightLabel{i}] = elastix(rightLabel{i},refRightLabel,[],{'RigidParameters.txt','NonRigidParameters.txt'});

end

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
%Coregister the average label to the average control
[~,CoregLabelLeft] = elastix(AverageRegLeftLabel, AverageRegLeftControl, [], {'RigidParameters.txt'});
[~,CoregLabelRight] = elastix(AverageRegRightLabel, AverageRegRightControl, [], {'RigidParameters.txt'});

%reconstruct the whole images
AverageRegControl(:,1:col/2) = AverageRegLeftControl;
AverageRegControl(:,col/2 + 1:col) = AverageRegRightControl;
CoregLabel(:,1:col/2) = CoregLabelLeft.transformedImages{1};
CoregLabel(:,col/2 + 1:col) = CoregLabelRight.transformedImages{1};

ASLImage1 = abs(AverageControl - AverageLabel);
ASLImage2 = (abs(AverageRegControl - double(CoregLabel)));


figure()
imshow(ASLImage1, []);
title('Renal Perfusion Image Obtained without Registration Techniques');
figure()
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');
%Yeison Rodriguez
%Week of 3/2/21

clear;


%read in the file provided
I = dicomread("20201208_2DpCASL.dcm");
I = 100*squeeze(I);
%save the size and number of images in the set
[row, col, numImages] = size(I);

%initialize sum variables which can be used to later find the average
sumImagesLeftControl = 0;
sumImagesRightControl = 0;
sumImagesLeftLabel = 0;
sumImagesRightLabel = 0;


for k = 1:numImages
    if k <= numImages/2
        %seperate into the two groups, first 16 are control
        dicomimgControl{k} = I(:,:,k);
        %seperate into left and right side of the dynamic.
        leftControl{k} = dicomimgControl{k}(:,1:col/2);
        rightControl{k} = dicomimgControl{k}(:,col/2 +1:col);
        %sum the images
        sumImagesLeftControl = sumImagesLeftControl + double(leftControl{k});
        sumImagesRightControl = sumImagesRightControl + double(rightControl{k});
    else
        %repeat process for the label images
        dicomimgLabel{k-numImages/2} = I(:,:,k);
        leftLabel{k-numImages/2} = dicomimgLabel{k-numImages/2}(:,1:col/2);
        rightLabel{k-numImages/2} = dicomimgLabel{k-numImages/2}(:,col/2 + 1:col);
        sumImagesLeftLabel = sumImagesLeftLabel + double(leftLabel{k-numImages/2});
        sumImagesRightLabel = sumImagesRightLabel + double(rightLabel{k-numImages/2});
        
        
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
%use the closest to average function to find the control and label index closest to their respective average.
[controlIndex,labelIndex] = ClosestToAverage(AverageControl,AverageLabel,dicomimgControl,dicomimgLabel);

for i = 1:numImages/2
    %create Registered Control & Label Images. Three transformations: Rigid, affine, & Non-Rigid
    [~,regLeftControl{i}] = elastix(leftControl{i},leftControl{controlIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});
    [~,regRightControl{i}] = elastix(rightControl{i},rightControl{controlIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});
    [~,regLeftLabel{i}] = elastix(leftLabel{i},leftLabel{labelIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});
    [~,regRightLabel{i}] = elastix(rightLabel{i},rightLabel{labelIndex},[],{'RigidParameters.txt','NonRigidParameters.txt'});

end

%initialize sum variables to find the average registered image
sumRegLeftControl = 0;
sumRegRightControl = 0;
sumRegLeftLabel = 0;
sumRegRightLabel = 0;
%sum each image to find the average
for i = 1:numImages/2
    %sum each registered image
    sumRegLeftControl = sumRegLeftControl + double(regLeftControl{i}.transformedImages{2});
    sumRegRightControl = sumRegRightControl + double(regRightControl{i}.transformedImages{2});
    sumRegLeftLabel = sumRegLeftLabel + double(regLeftLabel{i}.transformedImages{2});
    sumRegRightLabel = sumRegRightLabel + double(regRightLabel{i}.transformedImages{2});
    
end

%calculate the average of the registered images
AverageRegLeftControl = sumRegLeftControl/(numImages/2);
AverageRegRightControl = sumRegRightControl/(numImages/2);
AverageRegLeftLabel = sumRegLeftLabel/(numImages/2);
AverageRegRightLabel = sumRegRightLabel/(numImages/2);

[~,CoregLabelLeft] = elastix(AverageRegLeftLabel, AverageRegLeftControl, [], {'RigidParameters.txt'});
[~,CoregLabelRight] = elastix(AverageRegRightLabel, AverageRegRightControl, [], {'RigidParameters.txt'});

AverageRegControl(:,1:col/2) = AverageRegLeftControl;
AverageRegControl(:,col/2 + 1:col) = AverageRegRightControl;
CoregLabel(:,1:col/2) = CoregLabelLeft.transformedImages{1};
CoregLabel(:,col/2 + 1:col) = CoregLabelRight.transformedImages{1};

%create the standard difference image from the difference of the average control and label
ASLImage1 = (abs(AverageControl-AverageLabel));
%create the asl image from the difference of the registered control and the coregistered label
ASLImage2 = (abs(AverageRegControl - CoregLabel));


figure(1)
imshow(ASLImage1, []);
title('Renal Perfusion Image Obtained without Registration Techniques');
figure(2)
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');

%Yeison Rodriguez


clear;

%these values were computed earlier, but since registering images with
%elastix takes a long time, just load the results from earlier.
load RenalRegistrationVar.mat


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

%call the function to find the dynamic closest to the average control and
%label. These dynamics are the reference images to the rest of the images
[controlIndex,labelIndex] = ClosestToAverage(AverageControl,AverageLabel,dicomimgControl,dicomimgLabel);

%commented out due to length of execution. Use the provided var file
%instead
%  for i = 1:16
%     
% %create Registered Control & Label Images. Three transformations: Rigid, affine, & Non-Rigid
% [~,regControl{i}] = elastix(dicomimgControl{i},dicomimgControl{labelIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
% [~,regLabel{i}] = elastix(dicomimgLabel{i},dicomimgLabel{controlIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
%       
%  end
 
sumRegLeftControl = 0;
sumRegRightControl = 0;
sumRegLeftLabel = 0;
sumRegRightLabel = 0;

%sum each image to find the average
for i = 1:16
    
    sumRegLeftControl = sumRegLeftControl + double(regControl{i}.transformedImages{3}(:,1:192));
    sumRegRightControl = sumRegRightControl + double(regControl{i}.transformedImages{3}(:,193:384));
    
    sumRegLeftLabel = sumRegLeftLabel + double(regLabel{i}.transformedImages{3}(:,1:192));
    sumRegRightLabel = sumRegRightLabel + double(regLabel{i}.transformedImages{3}(:,193:384));
    
end

%calculate the average of the registered images
AverageRegLeftControl = sumRegLeftControl/16;
AverageRegRightControl = sumRegRightControl/16;
AverageRegLeftLabel = sumRegLeftLabel/16;
AverageRegRightLabel = sumRegRightLabel/16;

%coregister the average label to the average control
%coregister the registered left & right labels to the left & right controls
[~,CoregLabel1] = elastix(AverageLabel,AverageControl,[],{'RigidParameters.txt','AffineParameters.txt'});
[~,CoregLabel2Left] = elastix(AverageRegLeftLabel, AverageRegLeftControl, [], {'RigidParameters.txt','AffineParameters.txt'});
[~,CoregLabel2Right] = elastix(AverageRegRightLabel, AverageRegRightControl, [], {'RigidParameters.txt','AffineParameters.txt'});

%combine left and right kidney images of control and label together
CoregLabel2(:,1:192) = CoregLabel2Left.transformedImages{2};
CoregLabel2(:,193:384) = CoregLabel2Right.transformedImages{2};

AverageRegControl(:,1:192) = AverageRegLeftControl;
AverageRegControl(:,193:384) = AverageRegRightControl;

%Find the first perfusion image. Obtained without registration of the
%dynamics
ASLImage1 = (abs(AverageControl - double(CoregLabel1.transformedImages{2})));
%Find the second perfusion image. Obtained with registration techniques
%used on the dynamics
ASLImage2 = (abs(AverageRegControl - double(CoregLabel2)));

%display both images
figure(1)
imshow(ASLImage1,[]);
title('Renal Perfusion Image Obtained without Registration Techniques');

figure(2)
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');

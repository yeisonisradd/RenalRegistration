%Yeison Rodriguez
%Week 10/20/20 - 10/27/20

%clear;
%File is not current with current images produced. Refer to RenalRegistrationUpdated for current file

%these values were computed earlier, but since registering images with
%elastix takes a long time, just load the results from earlier.
load RenalRegistrationVar.mat

%read dicominfo
D = dicominfo('2D pCASL 16dyn00001.dcm');

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
AverageControl = sumImagesControl/16;
AverageLabel = sumImagesLabel/16; 

%these variables are used to find the images closest to the average.
%Initialized so that the first image is considered the closest at beginning
minDControl = sqrt(mean((AverageControl(:) - double(dicomimgControl{1}(:))).^2));
minDLabel = sqrt(mean((AverageLabel(:) - double(dicomimgLabel{1}(:))).^2));
controlIndex = 1;
labelIndex = 1;

for i = 2:16
    %objective way of finding the control image closest to the average
    if (sqrt(mean((AverageControl(:) - double(dicomimgControl{i}(:))).^2)) < minDControl)
        minDControl = sqrt(mean((AverageControl(:) - double(dicomimgControl{i}(:))).^2));
        controlIndex = i;
    end
    %objective way of finding the label image closest to the average
    if (sqrt(mean((AverageLabel(:) - double(dicomimgLabel{i}(:))).^2)) < minDLabel)
        minDLabel = sqrt(mean((AverageLabel(:) - double(dicomimgLabel{i}(:))).^2));
        labelIndex = i;
    end
end

% for i = 1:16
%     
% %create Registered Control & Label Images. Three transformations: Rigid, affine, & Non-Rigid
% [~,regControl{i}] = elastix(dicomimgControl{i},dicomimgControl{controlIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
% [~,regLabel{i}] = elastix(dicomimgLabel{i},dicomimgLabel{labelIndex},[],{'RigidParameters.txt','AffineParameters.txt','NonRigidParameters.txt'});
%     
% end

sumRegControl = 0;
sumRegLabel = 0;
for i = 1:16
    sumRegControl = sumRegControl + double(regControl{i}.transformedImages{3});
    sumRegLabel = sumRegLabel + double(regLabel{i}.transformedImages{3});
end

AverageRegControl = sumRegControl/16;
AverageRegLabel = sumRegLabel/16;
%coregister the two average labels to the average controls
[~,CoregLabel1] = elastix(AverageLabel,AverageControl,[],{'RigidParameters.txt','AffineParameters.txt'});
[~,CoregLabel2] = elastix(AverageRegLabel, AverageRegControl, [], {'RigidParameters.txt','AffineParameters.txt'});



ASLImage1 = abs(AverageControl - double(CoregLabel1.transformedImages{2}));
ASLImage2 = abs(AverageRegControl - double(CoregLabel2.transformedImages{2}));

figure(1)
imshow(ASLImage1,[]);
title('Renal Perfusion Image Obtained without Registration Techniques');
figure(2)
imshow(dicomimgControl{controlIndex}(:,:,1), []);
title('Reference Control Image');
figure(3)
imshow(dicomimgLabel{labelIndex}(:,:,1), []);
title('Reference Label Image');
figure(4)
imshow(AverageRegControl,[]);
title('Average of Registered Control Image Series');
figure(5)
imshow(CoregLabel2.transformedImages{2},[]);
title('Average of Registered Label Image Series, coregistered with Average of Registered Control Series');
figure(6)
imshow(ASLImage2, []);
title('Renal Perfusion Image Obtained with Registration Techniques');

save RenalRegistrationVar.mat





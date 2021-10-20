function [controlIndex, labelIndex] = ClosestToAverage(AverageCon,AverageLab,controlSeries,labelSeries)

%Calculate Average Control & Label


%these variables are used to find the images closest to the average.
%Initialized so that the first image is considered the closest at beginning
minDControl = sqrt(mean((AverageCon(:) - double(controlSeries{1}(:))).^2));
minDLabel = sqrt(mean((AverageLab(:) - double(labelSeries{1}(:))).^2));

controlIndex = 1;
labelIndex = 1;

for i = 2:length(controlSeries)
    
    %objective way of finding the control image closest to the average
    DifferenceRMS = sqrt(mean((AverageCon(:) - double(controlSeries{i}(:))).^2));
    if (DifferenceRMS < minDControl)
        minDControl = DifferenceRMS;
        controlIndex = i;
    end
    
    %objective way of finding the label image closest to the average
    DifferenceRMS = sqrt(mean((AverageLab(:) - double(labelSeries{i}(:))).^2));
    if (DifferenceRMS < minDLabel)
        minDLabel = DifferenceRMS;
        labelIndex = i;
    end
end


end
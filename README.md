# RenalRegistration
Using Elastix to Register Control and Label kidney images. Then these images are averaged, coregistered, and subtracted to find the perfusion image.
Negative control is also created, where process is repeated but without image registration.

RenalRegistration.m file and it's accompanying variable file were used to create the images shared in presentation as of 11/17/20
RenalRegistrationUpdated.m file is an updated version where the registered dynamics are subtracted first and then the average difference (perfusion image) is created. 
Parameter files are essential for both programs. 

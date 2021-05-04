# RenalRegistration
Using Elastix to Register The Control and Label kidney images. The Dynamics are first split into the left and right side of the image. These images are then registered with the reference image closest to the average control and label image. The registered images are then averaged, coregistered, and subtracted to find the perfusion image.
Negative control is also created, where process is repeated but without image registration.

Parameter files are essential for all versions of the registration programs. 

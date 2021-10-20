# RenalRegistration
Using Elastix to register 2D renal perfusion images. Note that input dataset must contain control and label kidney images.

In this program, the datasets are first split into the left and right side of the image. These images are then registered with the reference image closest to the average control and label image. The registered images are then averaged, coregistered, and subtracted to find the perfusion image.
Negative control is also created, where process is repeated but without image registration.

Note, for use of this program ensure that the matlab_elastix program is downloaded. This program creates matlab wrappers for the elastix program. For additional information/download refer to: https://github.com/raacampbell/matlab_elastix/blob/master/README.md

Parameter files are essential for all versions of the registration programs. They are where the elastix parameters are defined, and as such, are how we edit the image registrations. To properly run the program, ensure that parameter files are in the directory path or located in the same file as the program. 

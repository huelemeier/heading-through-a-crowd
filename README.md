# Estimate heading direction and traveled path through a crowd of point-light walkers
You see a crowd of point-light walkers. Your task is to adapt the ground speed to the matching translation speed of the walkers. The following video shows one trial as example:

## Technical requirements and set-up
These scripts are optimized for MatLab 2021b with Psychtoolbox (http://psychtoolbox.org/download.html) and OpenGL add-on libraries from the Psychtoolbox. So what needs to be installed on you computer are Matlab and Psychtoolbox.

## Set-up
Download all the files and add them to your Matlab folder. Within your Matlab folder, create a subfolder names "functions". Move the script "geFrustum" to this subfolder.

## Explanation of the scripts
github_path_heading_motion_parallax.m: This is the main script creating the scene.
getFrustum.m: this script generates frustum data. The main script uses this script to do some calculations. No need to adapt this script.
sample_walker3: motion data for point_light walker with normal speed
gravel.rgb.tiff: ground type gravel


## Run the script
Open the script in Matlab and click on 'run'. Matlab automatically requires your input in the command line, and subsequently asks questions. Enter the participant id and further information subsequently. When done, Psychtoolbox automatically opens a window and runs the script in that window. You will see the stimulus presentation. After each presentation, you are required to estimate your traveled distance by moving the mouse along the vertical axis. Confirm your answer by pressing the left mouse buttom. Subsequently, the next trial starts. The script finishes when all trials are done.

## Technical information about the scene
## Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originated from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints).

# Estimate heading direction and traveled path through a crowd of point-light walkers
You see a crowd of point-light walkers. Your task is to adapt the ground speed to the matching translation speed of the walkers. The following video shows two trials as example:


https://user-images.githubusercontent.com/69513270/182681764-f0e001ce-b3b8-45fe-ab02-19caddfbf5be.mov




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

You want to see the true heading direction? Just change show_true_heading (line 14) from false to true: 
```
show_true_heading = true;
```


## Technical information about the scene
## Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originate from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints). The walkers face either collectively to the left (-90°) or right (90°). 
<img width="1920" alt="background point-light walker" src="https://user-images.githubusercontent.com/69513270/182681394-1415a3ad-903e-425a-b893-b4c4a8e6fd18.png">



## Walker conditions
To decisively explore the influence of the components of biological motion on heading perception from optic flow analysis, we designed four conditions: static, natural locomotion, only translation, and only articulation.
In the static condition, the walkers resemble static figures. Here, the walkers kept their posture at a fixed position. The natural locomotion condition presents the walkers naturally moving through the world and swinging their limbs. This condition combines both elements of biological motion. The only translation condition displayed walkers sliding through the world without any limb motion. So the walkers resembles figure skaters moving in the direction they were facing. Conversely to the only translation condition, walkers in the only articulation condition moved their limbs without physical translation. This condition is imaginable as pedestrians on a treadmill. 

## Experimental scene
The experimental world spans over 20 m scene depths. The ground is programmed as blocking variable. In other words, you determine the facing variability for the whole stimulus presentation. The next time you run the script, you can change the facing variability. We placed a visible ground at eye height (1.60 m). Its appearance is structured (gravel). The gravel ground provides independent optic flow from the simulated observer motion. 

![gravel rgb](https://user-images.githubusercontent.com/69513270/182678034-d495fd3d-2364-400d-b5b4-5abbb912ed0a.png)


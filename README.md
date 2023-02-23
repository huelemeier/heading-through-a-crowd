# Estimate heading direction and traveled path through a crowd of point-light walkers
You see a crowd of point-light walkers. Your task is to adapt the ground speed to the matching translation speed of the walkers. The following video shows two trials with neither motion parallax nor a visible ground as example:




https://user-images.githubusercontent.com/69513270/183363928-1a7b7d4d-67cb-4947-b33e-0121189a90d7.mp4



## Technical requirements and set-up
These scripts are optimized for MatLab 2021b with Psychtoolbox (http://psychtoolbox.org/download.html) and OpenGL add-on libraries from the Psychtoolbox. So what needs to be installed on you computer are Matlab and Psychtoolbox.

## Set-up
Download all the files and add them to your Matlab folder. Within your Matlab folder, create a subfolder names "functions". Move the script "geFrustum" to this subfolder.

## Explanation of the scripts
- github_path_heading_motion_parallax.m: This is the main script creating the scene.
- getFrustum.m: this script generates frustum data. The main script uses this script to do some calculations. No need to adapt this script.
- sample_walker3: motion data for point_light walker with normal speed
- gravel.rgb.tiff: ground type gravel
- trajectory_heading_plots.m: Recreate what your participants sketched and save the images
- github trajectory.R: Load in data and preprocess them to recreate participants' response, and to analyse the data

## Run the script
Open the script in Matlab and click on 'run'. Matlab automatically requires your input in the command line, and subsequently asks questions. Enter the participant id, session number, and further information about the scene (grond, motion parallax, walkers at different depth) subsequently. When done, Psychtoolbox automatically opens a window and runs the script in that window. 
<img width="819" alt="Bildschirmfoto 2022-08-08 um 10 04 15" src="https://user-images.githubusercontent.com/69513270/183370429-5d14d554-48c7-4a1e-b08c-fb58f8676537.png">


You will see the stimulus presentation. After each presentation, you are required to estimate your heading direction by moving the mouse along the horizontal (heading direction) and vertical (curvature of your traveled path) axis. Press the right mouse buttom to invert the curvature direction. Confirm your answer by pressing the left mouse buttom. Subsequently, the next trial starts. The script finishes when all trials are done.

You want to see the true heading direction? Just change show_true_heading (line 17) in the script from false to true: 
```matlab
show_true_heading = true;
```


## Technical information about the scene
## Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originate from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints). The walkers face either collectively to the left (-90°) or right (90°). 
<img width="1920" alt="background point-light walker" src="https://user-images.githubusercontent.com/69513270/182681394-1415a3ad-903e-425a-b893-b4c4a8e6fd18.png">


## Walker conditions
To decisively explore the influence of the components of biological motion on heading perception from optic flow analysis, we designed four conditions: static, natural locomotion, only translation, and only articulation.
In the static condition, the walkers resemble static figures. Here, the walkers kept their posture at a fixed position. The natural locomotion condition presents the walkers naturally moving through the world and swinging their limbs. This condition combines both elements of biological motion. The only translation condition displayed walkers sliding through the world without any limb motion. So the walkers resembles figure skaters moving in the direction they were facing. Conversely to the only translation condition, walkers in the only articulation condition moved their limbs without physical translation. This condition is imaginable as pedestrians on a treadmill. 
Note these conditions are autamtically displayed in randomized order.

## Motion parallax and independent optic flow
You can change the degree of depth information available in the scene
If motion parallax is selected, the walkers stay at different depths in the room. While some of the group's position ranged between 7 and 9 m, the other ones are twice as far away, i.e., 14 to 18 m in depth. We adjust the walkers' size and points according to their positioning in the environment. Due to the positioning of the walkers in space, the scene is designed to induce motion parallax cues (Gibson, 1950). 

You can also add a grey gravel ground plane to the scene. The ground provides independent optic flow, and thus, independent self-motion information. If no ground is visible, the points of the walkers combine biological motion and simulated self-motion. 
Here are some example stimuli with increasingly more depth and self-motion information:
<img width="1205" alt="vary motion parallax and ground" src="https://user-images.githubusercontent.com/69513270/183370963-add6a67d-4f1d-4cab-8523-9b205dbdee5b.png">

## Experimental scene
The experimental world spans over 20 m scene depths. We placed a visible ground at eye height (1.60 m). Its appearance is structured (gravel). The gravel ground planeprovides independent optic flow from the simulated observer motion. The ground is programmed as blocking variable. In other words, you determine the ground appearance (black vs gravel) for the whole stimulus presentation. The next time you run the script, you can change the ground. 

![gravel rgb](https://user-images.githubusercontent.com/69513270/182678034-d495fd3d-2364-400d-b5b4-5abbb912ed0a.png)

## Procedure
Observers encounter a crowd of point-light walkers oriented collectively to the left or right. The movements change from trial to trial. Whether the walkers move their arms and legs and whether they translated varies throughout the experiment. Observers' self-motion simulation approaching the group os always be independent of the movement and direction of the group. This simulation endures about 2500 ms. 
As soon as the last frame freezes, a path appears at the observers' feet. Their task is to report the perceived heading direction and adjust the pathway suiting best their perception of approaching the walkers. Horizontally moving the computer mouse changes the path position, and vertically moving modifies the curvature. Movements upwards stretches the pathway to a straight line, whereas movements downwards curves the trajectory. In each trial, the curve points randomly to the left or right. By pushing the right mouse button, respondents invert the curve direction. Subjects register their response by pressing the left mouse button. After their response, the subsequent trial started instantly, and the self-motion simulation starts without any time delay. 


## Recreate skteched trajectory
You can recreate your participant's (average) response per condition. The matlab skript loads in preprocessed data from the R script, redraws the stimulus scene, indicates true heading direction and plots the sketched trajectory. Basic information about the id and the walker facing can be added. The script automatically saves each image. Note this process can take some time. 
Here is an example of how the images could look like:
![2_2_-90_trajectory_plot](https://user-images.githubusercontent.com/69513270/196374615-c023d0fc-a41b-4701-a6c9-e7f891252e06.jpg)

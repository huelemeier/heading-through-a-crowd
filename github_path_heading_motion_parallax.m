% This script is designed to study heading trough a crowd  
clear all; 
addpath('functions')
rng('shuffle');

ID = input('Enter subject ID '); %Input subject ID, this will also be the file name of the outsput
session = input('Enter session number '); %Input session number, this will also be the file name of the output
practice = input('Practice run [1] Experimental run [0] '); %input whether this is a practice run or not
walker_type = 1;%input('Enter walker type [0 = scrambled, walker] [1 = normal walker] ');%input walker type
observer_translating = 1;
gravel = input('black ground [0] or gravel [1]? '); % enter whether a ground is visible or not.
group_distance_z = input('Enter group distance [0 = no distance // no motion parallax] [1 = distance // motion parallax] '); % if 1: this line of code induces motion parallax. if 0: walkers are placed at the same depth.

if group_distance_z == 1
a = input('Enter amount of walkers in the distance (usually 4 of 8) '); %if motion parallax should be induced, you can enter de amount of walkers placed at another depth. 
else
    a = 0;
end

show_true_heading = false; %if true, the script displays the true heading direction. Note the path of self-motion is always straight.




%%
eye_height = 1.6;

% GL data structure needed for all OpenGL demos:
global GL;

% Is the script running in OpenGL Psychtoolbox? Abort, if not.
AssertOpenGL;

% Restrict KbCheck to checking of ESCAPE key:independent_variable_2
KbName('UnifyKeynames');

%Screen('Resolution',0,800,600) % Umrechnung: (/1980*600) mousex Positionen
Screen('Preference','Verbosity',1); 


% Find the screen to use for display:
screenid=max(Screen('Screens'));
stereoMode = 0;
multiSample = 0;

Screen('Preference', 'SkipSyncTests', 1);


%-----------
% Parameters
%-----------

nframes = 120;  %duration of stimulus, frames 60.
numwalkers = 8; %number of walkers 8

d=20;   %scene depth

hdrange = 12; %heading range in degrees


%set up conditions and trial sequence
independent_variable_sets = {[0 1], [0 1], [-90 90], [group_distance_z]}; % conditions: [translating]  [articulating] [mean walker facing]
[independent_variable_1 independent_variable_2 independent_variable_3 independent_variable_4] = ndgrid(independent_variable_sets{:}); 
conditions = [independent_variable_1(:) independent_variable_2(:) independent_variable_3(:) independent_variable_4(:)];
trials = conditions; %one trial block conveys all stimulus combinations (conditions)
trials = repmat(trials, 20, 1); %we extend trials to the desired number (= nsessions) of consecutive experimental sessions. 
trials = trials(randperm(length(trials)),:); %random permutation of all stimulus combinations generated at "conditions"

if practice
    trials = repmat(conditions, 1,1);
    trials = trials(randperm(length(trials)),:);
end


% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL;

PsychImaging('PrepareConfiguration');
% Open a double-buffered full-screen window on the main displays screen.
[win, winRect] = PsychImaging('OpenWindow', screenid, 0, [0 0 800 600], [], [], stereoMode, multiSample); % create a second window (size 800 x 600) displaying the experiemt
[win_xcenter, win_ycenter] = RectCenter(winRect);
xwidth=RectWidth(winRect);
yheight=RectHeight(winRect);

screen_height=198; %physical height of display in cm
screen_width=248; %physical width of display in cm
screen_distance=100; %physical viewing distance in cm
screen_distance_in_pixels=xwidth/screen_width*screen_distance; %physical viewing distance in pixel


HideCursor;
Priority(MaxPriority(win));

% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'win':
Screen('BeginOpenGL', win);

% Get the aspect ratio of the screen:

% Set viewport properly:
glViewport(0, 0, xwidth, yheight);

% Setup default drawing color to yellow (R,G,B)=(1,1,0). This color only
% gets used when lighting is disabled - if you comment out the call to
% glEnable(GL.LIGHTING).
glColor3f(1,1,0);

% Setup OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.

% Enable the first local light source GL.LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources,
% GL.LIGHT0, ..., GL.LIGHT7
glEnable(GL.LIGHT0);

% Enable alpha-blending for smooth dot drawing:
glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

glEnable(GL.DEPTH_TEST);

% Set projection matrix: This defines a perspective projection,
% corresponding to the model of a pin-hole camera - which is a good
% approximation of the human eye and of standard real world cameras --
% well, the best aproximation one can do with 3 lines of code ;-)
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

% Field of view = 2*atan(H/2N) where H is monitor height and N is viewing distance. Objects closer than
% 0.1 distance units or farther away than 50 distance units get clipped
% away, aspect ratio is adapted to the monitors aspect ratio:
gluPerspective(89, xwidth/yheight, 0.5, d);


% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera:
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)...
glLightfv(GL.LIGHT0,GL.POSITION,[ 1 2 3 0 ]);

% Set background clear color to 'black' (R,G,B,A)=(0,0,0,0):
glClearColor(0,0,0,0);

% Clear out the backbuffer: This also cleans the depth-buffer for
% proper occlusion handling: You need to glClear the depth buffer whenever
% you redraw your scene, e.g., in an animation loop. Otherwise occlusion
% handling will screw up in funny ways...
glClear(GL.DEPTH_BUFFER_BIT);

% Finish OpenGL rendering into PTB window. This will switch back to the
% standard 2D drawing functions of Screen and will check for OpenGL errors.

vprt1 = glGetIntegerv(GL.VIEWPORT);
Screen('EndOpenGL', win);

% Show rendered image at next vertical retrace:
Screen('Flip', win);

fps=Screen('FrameRate', win);   %use PTB framerate if its ok. otherwise....
if fps == 0
    flip_count = 0;                 %rough estimate of the frame rate per second
    timerID=tic;                    %I did this because for some reson the PTB estimate wasn't working
    while (toc(timerID) < 1)        %pretty sure this is due to the mac LCD monitors
        Screen('Flip',win);
        flip_count=flip_count+1;
    end
    frame_rate_estimate=flip_count;
    fps = frame_rate_estimate;
end

tspeed=1.1/fps;  %speed which the observer translates through the environment 

if observer_translating==0
    tspeed=0;
end


%first stuff the observer sees when they start the experiment

[~, ~, buttons1]=GetMouse(screenid);
Screen('TextSize',win, 36);
white = WhiteIndex(win);

while ~any(buttons1)
    Screen('DrawText',win, 'Click the mouse to begin the experiment.',win_xcenter-320,win_ycenter,white);
    Screen('DrawingFinished', win);
    Screen('Flip', win);
    [~, ~, buttons1]=GetMouse(screenid);
end




for trial = 1:length(trials) 
    
    % set up conditions for this trial
    translating        = trials(trial,1);
    articulating       = trials(trial,2);
    mean_walker_facing = trials(trial,3);
    group_distance_z   = trials(trial,4);
   
    walker_facing = mean_walker_facing * ones(1,numwalkers);
    
    %% set up walker    
    origin_directory = pwd;    
    FID = fopen('sample_walker3.txt');    %open walker data file    
    walker_array = fscanf(FID,'%f');      %read into matlab
    fclose(FID);   
    walker_array=reshape(walker_array,3,[]).*0.00001;  %order and scale walker array
    
    if walker_type == 0
        walker_array_original = walker_array;
    end
    
    
        
    %% set walker stuff

    if walker_type == 0
        walker_array = genscramwalker(walker_array_original,16);
    end

    clear xi
    %randomly select starting phase
    numorder=(1:16:length(walker_array));
    xi(1:numwalkers)=numorder(randi([1 length(numorder)],1,numwalkers));
%          xi(1:numwalkers)=1; % Do this so that all walkers start with the same
    %phase

    %% set walker facing and translation   

    % initialize walker translation state
    translate_walker= zeros(1,numwalkers);

    % set translation speed
    if translating
        translation_speed = 0.013;
    else
        translation_speed = 0;
    end
    
    %% adjustments for group distance
    if group_distance_z == 0;
        distance = 1;
    elseif group_distance_z == 1;
        distance = 2;
    end
    
    %generate walker random starting positions
    [walkerX,walkerY,walkerZ] = CreateUniformDotsIn3DFrustum(numwalkers,56,xwidth/yheight,0.5,d,1.4); %generate walker positions
    
    walkerX = linspace(-3,3,numwalkers)+2*(rand(1,numwalkers)-0.5);
    walkerZ = -8+2*(rand(1,numwalkers)-0.5);
    
    %a = randi(numwalkers/2-1); %wenn random Anzahl verschoben wird, muss
    %das hier entkommentiert werden
    if a == 0
        walker_distance = walkerZ;
        walkerindex = (1:numwalkers);
    else
        walker_distance = walkerZ;
        walker_distance(1:a)= walker_distance(1:a)*distance;
        walkerindex = randperm(numel(walkerZ),numwalkers);
        walkerZ = walker_distance(walkerindex);
    end
    
    %% set up ground plane    
    myimg = imread('gravel.rgb.tiff');
    %myimg = imread('chess-board-gb441fa244_1920.tiff');   
    %myimg = imread('schach2.tiff');
    mytex = Screen('MakeTexture', win, myimg, [], 1);
    
    % Retrieve OpenGL handles to the PTB texture. These are needed to use the texture
    % from "normal" OpenGL code:
    [gltex, gltextarget] = Screen('GetOpenGLTexture', win, mytex);   


    
    %% set heading stuff
    Screen('BeginOpenGL',win)
    glLoadIdentity
    viewport=glGetIntegerv(GL.VIEWPORT); %viewport
    modelview=glGetDoublev(GL.MODELVIEW_MATRIX); %modelview matrix
    projection=glGetDoublev(GL.PROJECTION_MATRIX); %(vectorized) projection matrix

    heading_deg = hdrange*(2*rand()-1);
    heading_world = -tand(heading_deg)*d;

    translate_observer=0; %start at zero

    % shift crowd to center on screen
    walkerX = walkerX - tand(heading_deg)*8;

    %% view frustum for culling used later

    glPushMatrix
    glLoadIdentity

    glRotatef(-heading_deg,0,1,0)

    proj=glGetFloatv(GL.PROJECTION_MATRIX); %projection matrix
    modl=glGetFloatv(GL.MODELVIEW_MATRIX);

    glPopMatrix

    modl=reshape(modl,4,4);
    proj=reshape(proj,4,4);

    frustum=getFrustum(proj,modl);

    Screen('EndOpenGL', win)

    %% Animation loop


    for i = 1:nframes;

        %abort program early
%         exitkey=KbCheck;
%         if exitkey
%             clear all
%             return
%         end
        

        Screen('BeginOpenGL',win);
        glClear(GL.DEPTH_BUFFER_BIT)
        glLoadIdentity

        gluLookAt(0,0,0,heading_world,0,-d,0,1,0); %set camera to look without rotating. normally just use thi
        glTranslatef(0,0,translate_observer) %translate scene
        
           if gravel == 1
            %draw texture on the ground
            glColor3f(0.6,0.6,0.6)
            
            % Enable texture mapping for this type of textures...
            glEnable(gltextarget);
            
            % Bind our texture, so it gets applied to all following objects:
            glBindTexture(gltextarget, gltex);
            
            % Clamping behaviour shall be a cyclic repeat:
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);
            
            % Enable mip-mapping and generate the mipmap pyramid:
            glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glGenerateMipmapEXT(GL.TEXTURE_2D);
            
            glBegin(GL.QUADS)
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height-0.1, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height-0.1, -200);
            glEnd();
            
            
            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture
            
           end
        
        %% PLW code

        for walker = 1:numwalkers %cycle through each walker. at this stage i draw each walker singularly. I think this could definitely be sped up but have so far not found a good way to do so

            if xi(walker)+16+12 > length(walker_array) % <--this is the size of the scrambled walker data file
                xi(walker)=1;
            end

            %get walker array for frame
            xyzmatrix = walker_array(:,xi(walker):xi(walker)+11).*repmat([1;1;1],1,12);

            if articulating
                xi(:,walker) = xi(:,walker) + 16;
            end

            %% point drawing

            %these variables set up some point drawing
            nrdots=size(xyzmatrix,2);
            nvc=size(xyzmatrix,1);

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, xyzmatrix);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix
            glTranslatef(walkerX(walker),walkerY(walker),walkerZ(walker)); %move the points to the right location


            %do facing rotation and walking translation
            glRotatef(walker_facing(walker)-90,0,1,0);
            glTranslatef(translate_walker(walker),0,0); 
            if translating
                translate_walker(walker)=translate_walker(walker) + translation_speed;
            end

            glColor3f(1.0,1.0,1.0)
           
            % this if statements adapts the point size of each walker
            % depending on its distance (walkerindex)
            smallpoint=(1:a);
            index = ismember(walkerindex(walker), smallpoint);
            if index == 1
                glPointSize(4)
            else
                glPointSize(7)
            end
            
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points

            glPopMatrix

        end

        % show true heading for testing
        if show_true_heading
            heading_point = [0,0,-d/2]';

            %these variables set up some point drawing
            nrdots=size(heading_point,2);
            nvc=size(heading_point,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, heading_point);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix               

            glColor3f(0.9,0.0,0.0)
            glPointSize(4)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end    

        Screen('EndOpenGL',win);

        translate_observer=translate_observer+tspeed; % update translated position

        Screen('Flip', win);

    end    %end animation loop

  
%%%SetMouse(-1 + (1-(-1))*rand()*win_xcenter,win_ycenter);   %set the mouse at a random position relative to the middle of the screen

    %this loop redraws the static final frame and waits for a user response
    buttons = 0;
    leftright = sign(rand-0.5);
    
  while ~buttons(1)

        

        %% redraw walkers

        Screen('BeginOpenGL',win);

        glMatrixMode(GL.MODELVIEW)
        glLoadIdentity
        glClear(GL.DEPTH_BUFFER_BIT)
        
        %set camera looking position and location
        gluLookAt(0,0,0,heading_world,0,-d,0,1,0);
        glTranslatef(0,0,translate_observer-tspeed);
        
        if gravel == 1
            %draw texture on the ground
            glColor3f(0.6,0.6,0.6)
            
            % Enable texture mapping for this type of textures...
            glEnable(gltextarget);
            
            % Bind our texture, so it gets applied to all following objects:
            glBindTexture(gltextarget, gltex);
            
            % Clamping behaviour shall be a cyclic repeat:
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);
            
            % Enable mip-mapping and generate the mipmap pyramid:
            glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glGenerateMipmapEXT(GL.TEXTURE_2D);
            
            glBegin(GL.QUADS)
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height-0.1, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height-0.1, -200);
            glEnd();
            
            
            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture
            
        end
        

   

        for walker = 1:numwalkers

            xyzmatrix = walker_array(:,xi(walker):xi(walker)+11).*repmat([1;1;1],1,12);

            %these variables set up some point drawing
            nrdots=size(xyzmatrix,2);
            nvc=size(xyzmatrix,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, xyzmatrix);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix
            glTranslatef(walkerX(walker),walkerY(walker),walkerZ(walker)); %move the points to the right location

            glRotatef(walker_facing(walker)-90,0,1,0);
            glTranslatef(translate_walker(walker),0,0);

            glColor3f(1.0,1.0,1.0)
           
            % this if statements adapts the point size of each walker
            % depending on its distance (walkerindex)
            smallpoint=(1:a);
            index = ismember(walkerindex(walker), smallpoint);
            if index == 1
                glPointSize(4)
            else
                glPointSize(7)
            end
            
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end

        % show true heading for testing if needed
        if show_true_heading
            heading_point = [0,0,-d/2]';

            %these variables set up some point drawing
            nrdots=size(heading_point,2);
            nvc=size(heading_point,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, heading_point);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix               

            glColor3f(0.9,0.0,0.0)
            glPointSize(4)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end    

        %% draw curved path
        
        % take tangent direction under the foot (heading) and radius from
        % mouse position
        [mx, my, buttons]=GetMouse(screenid); %Returns the current (x,y) position of the cursor and the up/down state of the mouse buttons.
        tangent = (mx-xwidth/2)/(xwidth/2) * leftright; %Tangente = Distanz der Mausposition vom Mittelpunkt der x-Achse im Verhältnis zum Mittelpunkt der x-achse.
        radius = yheight/(my/2+0.1);

        % toggle left/right circle 
        if buttons(2)
            leftright = -leftright;
            WaitSecs(0.15);
        end
        
        
        % calculate center of circle
        xcenter = radius * cos(tangent) * sign(tangent);
        xcenter = radius * cos(tangent) * leftright;
        zcenter = radius * sin(tangent);

        
        % calculate angles for points along circle
        th0 = tangent:-pi/360:tangent-pi;        
        th1 = [th0;th0];        
        th2 = reshape(th1,1,2*length(th1));        
        th = th2(1,2:length(th2)-1);
        
        % calculate points along circle
        x = (radius-0.25) * cos(th) * sign(xcenter) - xcenter;
        y = -eye_height+0.01 * ones(size(x));
        z = (radius-0.25) * sin(th) - zcenter - (translate_observer - tspeed);
        
        x2 = (radius+0.25) * cos(th) * sign(xcenter) - xcenter;
        y2 = -eye_height+0.01 * ones(size(x));
        z2 = (radius+0.25) * sin(th) - zcenter - (translate_observer - tspeed);


        
        %make the matrix of positions for the dots along the circle.
        numDots = length(th);
        paths_points = [reshape(x, 1, numDots); reshape(y, 1, numDots); reshape(z, 1, numDots)];
        paths_points2 = [reshape(x2, 1, numDots); reshape(y2, 1, numDots); reshape(z2, 1, numDots)];


        %these variables set up some point drawing
        nrdots=size(paths_points,2);
        nvc=size(paths_points,1);

        glClear(GL.DEPTH_BUFFER_BIT)

        %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
        glVertexPointer(nvc, GL.DOUBLE, 0, paths_points);
        glEnableClientState(GL.VERTEX_ARRAY);

        glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
        glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

        glPushMatrix               

        glColor3f(1.0,1.0,1.0)
        glLineWidth(9)
        glDrawArrays(GL.LINES, 0, nrdots); %draw lines through the points        
        glVertexPointer(nvc, GL.DOUBLE, 0, paths_points2);       
        glDrawArrays(GL.LINES, 0, nrdots); %draw lines through the points
        glPopMatrix
        
        Screen('EndOpenGL',win);
        


        %% get mouse and heading position and calculate heading error
        if buttons(1) == 1
            [mousex, ~, ~] = GetMouse(screenid);
            heading_deg;
            heading_error_deg = atand((mousex-win_xcenter)/screen_distance_in_pixels) - heading_deg; %wobei mousex = X(1)

            heading_estimate_deg = atand((mousex-win_xcenter)/screen_distance_in_pixels);
                    

        end           

        Screen('Flip', win);

    end

    Screen('Flip',win);
    WaitSecs(0.5);



    %output 

    output(trial,1) = ID;
    output(trial,2) = session;
    output(trial,3) = trial;
    output(trial,4) = walker_type;
    output(trial,5) = translating;
    output(trial,6) = articulating;
    output(trial,7) = mean_walker_facing;
    output(trial,8) = heading_deg; %true observer heading
    output(trial,9) = heading_estimate_deg; %perceived heading direction
    output(trial,10) = heading_error_deg; %heading error
    output(trial,11) = mousex; %equivalent to X(1) %in degree: atand((mousex)-win_xcenter)/screen_distance_in_pixels)
    output(trial,12) = mx; %cursor  x-axis nach dem die Kruve gezeichent wird. 
    output(trial,13) = my; % cursor position along the y-axis
    output(trial,14) = leftright; %negative values right, positive values left.
    output(trial,15) = tangent; %negative values left, positive values right (can only range between 1 and -1).
    output(trial,16) = radius; %6700 = gerade Translation wahrgenommen %atand(6700) = 90 -> gerade. ist schon in degree oder bogenmaß
    output(trial,17) = gravel; %1 = gravel, 0 = black ground
    output(trial,18) = group_distance_z;
    
    



    if ~practice
        cd('data');
        dlmwrite([num2str(ID), '_',num2str(walker_type), '_',num2str(session), '_trajectory_heading_bewegungsparallaxe.txt'],output,'\t');
        cd(origin_directory)

    end

end
 


%% Done. Close screen and exit:c
Screen('CloseAll');


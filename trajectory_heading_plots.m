% function [] = crowd_ensemble()
clear all;


addpath('functions')

%% recreate the stimulus 
gravel = 1;%input('black ground [0] or gravel [1]? ');
a = 4; % motion parallax = 4. without motion parallax: a = 0.

eye_height = 1.6;

% GL data structure needed for all OpenGL demos:
global GL;

% Is the script running in OpenGL Psychtoolbox? Abort, if not.
AssertOpenGL;

% Restrict KbCheck to checking of ESCAPE key:independent_variable_2
KbName('UnifyKeynames');
Screen('Preference','Verbosity',1);


% Find the screen to use for display:
screenid=max(Screen('Screens'));
stereoMode = 0;
multiSample = 0;

Screen('Preference', 'SkipSyncTests', 1);


%-----------
% Parameters
%-----------

nframes = 50;
numwalkers = 8; %number of walkers 8

d=20;   %scene depth

show_true_heading = true;

origin_directory = pwd;


%% open data
trials = fopen('rdata.txt');    %open walker data file
trials = fscanf(trials,'%f');      %read into matlab

A = trials(1:7:end).';
B = trials(2:7:end).';
C = trials(3:7:end).';
D = trials(4:7:end).';
E = trials(5:7:end).';
F = trials(6:7:end).';
G = trials(7:7:end).';
trials = [A;B;C;D;E;F;G].';
clear A B C D E F G

%% Setup Psychotoolbox
% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL;

PsychImaging('PrepareConfiguration');
% Open a double-buffered full-screen window on the main displays screen.
[win, winRect] = PsychImaging('OpenWindow', screenid, 0, [0 0 800 600], [], [], stereoMode, multiSample); 
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

% Get the aspect ratio of the screen



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

%% plot the trajectory and the walkers:

for trial = 1:length(trials)
    
    % set up conditions for this trial
    mean_walker_facing = trials(trial,1);
    radius = trials(trial,2);
    tangent = trials(trial,3);
    leftright = trials(trial,4);
    true_heading = trials(trial,5);
    id = trials(trial,6);
    condition = trials(trial,7);
    
    walker_facing = mean_walker_facing * ones(1,numwalkers);
    
    %% set up walker
    origin_directory = pwd;
    FID = fopen('sample_walker3.txt');    %open walker data file
    walker_array = fscanf(FID,'%f');      %read into matlab
    fclose(FID);
    walker_array=reshape(walker_array,3,[]).*0.00001;  %order and scale walker array
    
    
    
    %% set walker stuff
    
    clear xi
    %randomly select starting phase
    numorder=(1:16:length(walker_array));
    xi(1:numwalkers)=numorder(randi([1 length(numorder)],1,numwalkers));
    
    %% set walker facing and translation
    
    % initialize walker translation state
    translate_walker= zeros(1,numwalkers);
    
    
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
    
    heading_deg = true_heading;
    heading_world = -tand(heading_deg)*d;
    
    translate_observer=0; %start at zero
    
    % shift crowd to center on screen
    walkerX = walkerX - tand(heading_deg)*8;
    
    %% view frustum for culling used later
    
    glLoadIdentity
    
    glRotatef(-heading_deg,0,1,0)
    
    proj=glGetFloatv(GL.PROJECTION_MATRIX); %projection matrix
    modl=glGetFloatv(GL.MODELVIEW_MATRIX);
    
    modl=reshape(modl,4,4);
    proj=reshape(proj,4,4);
    
    frustum=getFrustum(proj,modl);
    
    Screen('EndOpenGL', win)
    
   
    
    %this loop redraws the static final frame and waits for a user response
    buttons = 0;
   
    [~, ~, buttons]=GetMouse(screenid);
    
    
    for i = 1:nframes;
        
        %% write information about the participant on the screen
        
        white = WhiteIndex(screenid);
        line1 = 'id ';
        line2 = '\ncondition ';
        line3 = '\nwalker facing: ';
        
        Screen('TextSize',win, 20);
        DrawFormattedText(win, [line1 num2str(id) line2 num2str(condition) line3 num2str(mean_walker_facing)], win_xcenter-300, win_ycenter-150, white);
        Screen('DrawingFinished', win);
        Screen('Flip',win);
        
        %% redraw walkers
        
        Screen('BeginOpenGL',win);
        
        glMatrixMode(GL.MODELVIEW)
        glLoadIdentity
        glClear(GL.DEPTH_BUFFER_BIT)
        
        
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
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height, -200);
            glEnd();
            
            
            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture
            
        end
        
        %set camera looking position and location
        gluLookAt(0,0,0,heading_world,0,-d,0,1,0);
        glTranslatef(0,0,0);
        
        
        
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
            glPointSize(7)
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
        z = (radius-0.25) * sin(th) - zcenter;% - (translate_observer - tspeed);
        
        x2 = (radius+0.25) * cos(th) * sign(xcenter) - xcenter;
        y2 = -eye_height+0.01 * ones(size(x));
        z2 = (radius+0.25) * sin(th) - zcenter;% - (translate_observer - tspeed);
        
               
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
        
        
    %% GetImage call. Alter the rect argument to change the location of the screen shot
    imageArray = Screen('GetImage', win, []);

    % imwrite is a Matlab function, not a PTB-3 function
    cd('trajectoryplots');
    imwrite(imageArray, [num2str(id), '_', num2str(condition), '_', num2str(mean_walker_facing), '_', 'trajectory_plot.jpg']);
    cd(origin_directory)
    
    clear imageArray   
        
    end
    
    Screen('Flip',win);    
    
    
    
    
end



%% Done. Close screen and exit:c
Screen('CloseAll');


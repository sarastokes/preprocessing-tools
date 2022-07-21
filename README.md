# preprocessing_tools
Workflow for preprocessing functional imaging data


### Install
- Add the ImageJ-MATLAB plugin to FIJI (follow the steps in the prerequisites section here https://imagej.net/scripting/matlab ).
- Increase your Java Heap Memory size in MATLAB (Preferences>General>Java Heap Memory). I think you’ll have to restart MATLAB for it to take effect
- This step is optional, but it gives you an extra boost in speed. Download TIFFStack (https://github.com/DylanMuir/TIFFStack) and follow the instructions in the “Download and install” section. It requires compiling some C code within MATLAB so you’ll also need to add the MinGW-w64 Compiler from MATLAB’s Add On’s menu (instructions: https://www.mathworks.com/help/matlab/matlab_external/install-mingw-support-package.html)

Before running the first time, you need to let MATLAB know where FIJI is located on your computer
```matlab
addpref('ao_tools', 'fiji_path', '...\Fiji.app\scripts')
```
Replace `'...\Fiji.app\scripts'` with the full file path to the scripts folder within the FIJI.app folder for your FIJI installation. This is needed to establish the connection between MATLAB and ImageJ. You can test your connection with:
```matlab
run('ConnectToImageJ.m`)
```

It will take a minute or so. Once complete you'll likely see some errors in red, followed by "-- Welcome to ImageJ-MATLAB --". A FIJI window will open within MATLAB. It technically works like a regular FIJI window but there are some differences you might run into if you actually try to use it for purposes other than running code from MATLAB. 

### Use
##### Initial experiment processing
1. Make sure there is an "Analysis" folder within your main experiment folder.
2. Within "Analysis", create two folders: "Videos" and "Snapshots" 

The code assumes your data follows the lab's standard file structure, shown below. The top folder is your "Experiment folder", later set to the variable `experimentDir`. Newly added folders are in italics:
- MC00838_20210714 
  - Analysis
    - Videos
    - Snapshots
  - Ref
  - Vis

Once your videos are registered, prepare them for MATLAB analysis as demonstrated below. `PreprocessFunctionalImagingData.m` is the main workflow and it relies on specific outputs from `processVideoPrep`. The key/value inputs to `processVideoPrep` allow you to specify which side you were imaging on (left, right or full), and which type of registration you want to use (frame or strip). See `help processVideoPrep` for more detailed information on the inputs. 

Note that you must save the output as `videoNames` and `p`! ImageJ cannot be called from inside functions so `PreprocessFunctionalImagingData.m` is a script assuming `videoNames` and `p` are present in the workspace.

```matlab
experimentDir = '';  % Set to your experiment folder
epochIDs = 1:10;     % The video numbers to process
[videoNames, p] = processVideoPrep(...
    experimentDir, epochIDs,...
    'ImagingSide', 'full',...
    'RegistrationType', 'strip');
run('PreprocessFunctionalImagingData.m');
```
This will crop out the stimulus side of your video without data to reduce file size (unless you specified `'ImagingSide', 'full'`) and save it as a .tif file in the "Videos" folder. Each video is saved with the format "vis_####.tif", so video ID one would be "vis_0001.tif". This is especially useful because loading .avi files into MATLAB is painfully slow, but .tif files are quick. Also if you were only imaging in half the FOV, you can save space by not storing that part. 

Additionally, three Z-projections (AVG, SUM and STD) per video will be created and saved to the "Snapshots" folder. In your "Analysis" Folder, stacks off all SUM, AVG and STD snapshots are also created, along with some Z-projections of those stacks. The stacks are useful for segmentation and determining whether there were pixel offsets in the registered videos that need to be corrected.


At this point, you no longer need MATLAB's connection to ImageJ. Close it out by running:
```matlab
ij.IJ.run("Quit", "");
```

##### Accessing the data 

To quickly load epochs, use `loadEpoch` which takes 3 inputs:
1. `videoFolder` - This is the full path to the "Videos" folder containing your .tif files, within "Analysis"
2. `epochID` - video ID or IDs(s) to load. If you include more than one ID, the videos must be the same size
3. `useTiffStack` - (optional, default = false), whether to use TIFFStack or MATLAB's built-in tiff reading capabilities.

If you input one epochID, the output will be a 3D matrix (X, Y, Time). If you input multiple epochIDs, the output will be a 4D matrix (X, Y, Time, Epochs).

```matlab
videoFolder = '..\Analysis\Videos';  % Fill in with your experiment folder
% Import the stack for video #5, using TIFFStack
imStack = loadEpoch(videoFolder, 5, true);
% Same as above, but without using TIFFStack
imStack = loadEpoch(videoFolder, 5);

% Import the stacks for videos #5 and #6
imStack = loadEpoch(videoFolder, 5:6);
```

If you want to force `loadEpoch` to always use TIFFStack without specifying a 3rd input, run the line below and your preference will be saved (and will persist across MATLAB sessions).
```matlab
addpref('ao_tools', 'use_tiffstack', true);
```

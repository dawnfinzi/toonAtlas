clear all
close all

%% Setup Freesurfer
% set your freesurfer subjects dir if you have multiple depending on the
% project
% [EK]: I don't think you need this! Unless you need a specific fsaverage
% from this folders
% k_AY_base_dir = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
% setenv('SUBJECTS_DIR', k_AY_base_dir);

%% Setup paths and toolboxes
rootDir = '/share/kalanit/biac2/kgs/';
baseDir = fullfile(rootDir,'projects/toonAtlas');
cd(baseDir)

addpath(genpath('./code'))
addpath(genpath('/share/kalanit/software/vistasoft/'))

%% Setup session
% currently set up for one subject to be processed at a time
% setSessions inputs are 
% (1) initials: 'RJ09' or 'ENK05',
% (2) sessionNr: 'RJ09' has 1 or 2, 'ENK05' has only 1
% (3) (optional) testFolder: to add 'EKtest' or 'BFtest' at the end of session
[session, fs_session] = setSessions('ENK05',1,'EKtest');

setup.vistaSession  = session;
setup.fsSession     = fs_session;
setup.vistaDataDir  = fullfile(baseDir,'tests');
setup.fsDir         = fullfile(rootDir,'anatomy','freesurferRecon',...
                       'Kids_AcrossYears');

% Create vista session folders if needed
vistaDir = fullfile(setup.vistaDataDir, setup.vistaSession);
if ~exist(vistaDir,'dir')
    fprintf(1,'mkdir %s \n',vistaDir)
    mkdir(vistaDir)
end
cd(vistaDir)

% Create a 3DAnatomy folder within the vista session folder to copy our t1
% and t1_class nifti files later
anatDir = fullfile(setup.vistaDataDir, setup.vistaSession, '3DAnatomy');
if ~exist(anatDir,'dir')
    fprintf(1,'mkdir %s \n',anatDir)
    mkdir(anatDir)
end

%% Convert T1 for mrvista and fix class file
% Get subject's FreeSurfer recon path 
cd(fullfile(setup.fsDir, setup.fsSession))

% Path to T1.mgz file created by FreeSurfer
T1.mgz = sprintf('./mri/T1.mgz');

% Path to t1.nii.gz to be output by conversion
T1.nii = sprintf('./nifti/t1.nii.gz');
if ~exist('/nifti', 'dir')
    mkdir('nifti');
end

% Convert FS recon t1.mgz to nifti format (using nearest neighbor).
% This function cannot overwrite any existing files, so if there is an
% existing file, it will ask the user what to do. 
if exist(T1.nii, 'file')
    prompt = 'This file already exists. Are you sure you want to overwrite it? Press 1 for yes, 2 for no: ';
    x = input(prompt);
    if x == 1
        delete './nifti/t1.nii.gz'
        str = sprintf('mri_convert --resample_type nearest --out_orientation RAS -i %s -o %s', T1.mgz, T1.nii);
        system(str)
    end
else
    str = sprintf('mri_convert --resample_type nearest --out_orientation RAS -i %s -o %s', T1.mgz, T1.nii);
    system(str)
end

% Convert the FS ribbon.mgz to a nifti class file (which is used by mrVista
% to create 3D meshes)
fsRibbonFile  = fullfile('./mri/ribbon.mgz');  % Full path to the ribbon.mgz file, or it can be name of directory in freesurfer subject directory (string). 
outfile       = fullfile('./nifti/t1_class.nii.gz');
fillWithCSF   = true;
alignTo       = T1.nii;
resample_type = [];
if exist(outfile, 'file')
    x = input(prompt);
    if x == 1
        delete './nifti/t1_class.nii.gz'
        fs_ribbon2itk(fsRibbonFile, outfile, fillWithCSF, alignTo, resample_type)
    end
else
    fs_ribbon2itk(fsRibbonFile, outfile, fillWithCSF, alignTo, resample_type)
end

% Copy our T1 and class file over to the mrVista session
copyfile(T1.nii, anatDir)
copyfile(outfile, anatDir)

%% initialize mrvista toon session
cd(vistaDir)
paramPath = fullfile('Stimuli','8bars_params.mat');
imgPath = fullfile('Stimuli','8bars_images.mat');

toon_init(baseDir, 'tests', setup.vistaSession)

%% Align inplane anatomy to volume anatomy
% step through s_alignInplaneToAnatomical.m
% (or align using rxAlign and Nestares) 
% First by hand: rxAlign. Then run the other sections, up to fitting
% ellipse. Make sure that the ellipse covers the brain (or most of it) but
% excludes the skull. 
% Keep running the other sections (except for 4d' (OPTIONAL) Automatic
% alignment). Then continue the rest of the sections to save.
s_alignInplaneToAnatomical

%% motion correct session
toon_motionCorrect(baseDir,'tests', setup.vistaSession);

%% install segmentation, transform tSeries to Gray, and average time series
toon_2gray(baseDir,'tests', setup.vistaSession);

%% Import FreeSurfer mesh into mrVista
fsSurfPath = fullfile(setup.fsDir,  setup.fsSession, 'surf');
toon_surf2msh(fsSurfPath, anatDir)

%% open mrVista 3 session so you can see that everything is good
% [EK]: it is not clear to me what you are supposed to check here, because
% the previous block already displays the meshes...s

vw = mrVista('3');
% in the GUI set your preferences and save them
% load a mesh to check that they are ok
% you can also inflate a mesh and save it

%% run CSS pRF model
toon_prfRun(baseDir, 'tests', setup.vistaSession, paramPath, imgPath)

%% convert maps to freesurfer surfaces
%  Once the CSS model is done (and you've checked in mrvista that it looks
%  okay, you can convert the maps to freesurfer surface coords)
smooth = 1; %smooth to match previous stages
direct_mrvEccen2fs(fullfile(setup.vistaDir, setup.vistaSessisvon), ...
                   fullfile(setup.fsDir, setup.fsSession), smooth)
               
%% transform Kastner atlas from fsaverage space to subject space to use as a reference (optional)
transform_KastnerAtlas;

%% now you can move on the ROI drawing! (see script: step2_draw_EVC_ROIs.m)


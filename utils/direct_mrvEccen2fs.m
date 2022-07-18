function direct_mrvEccen2fs(mrSessionDir, fsDir, smooth)
% direct_mrvEccen2fs(mrSessionDir, fsDir, smooth)
%
% Function to export prf parameters (unsmooth/smooth) from mrVista Gray
% Ribbon (volume) to freesurfer surface vertices
%
% INPUTS:
%   mrSessionDir      :  mrVista session path
%   fsDir             :  freesurfer directory
%   smooth            :  0 is no smoothing, and 1 is smoothing


%% ----------
% File paths
% ----------
%mrSessionDir = '/share/kalanit/biac2/kgs/projects/toonAtlas/freesurfer_test/RJ_time_03/';
%fsDir = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears/RJ09_scn181028_recon0920_v6/';

anatDir = fullfile(mrSessionDir, '3DAnatomy');
t1file  = fullfile(anatDir,'t1.nii.gz');

fsSurfDir = fullfile(fsDir, 'surf');

% directories to save results
prfFSDir = fullfile(mrSessionDir, 'FreesurferFormat'); 

if ~exist(prfFSDir, 'dir')
    mkdir(prfFSDir);
end
% ----------

%% ------------------------------------------------------------------------
% Exporting prf parameters to freesurfer vertices
%--------------------------------------------------------------------------

% step inside the vistasession directory contain mrSESSION.mat
cd(mrSessionDir);

% We need a volume view:
dataType = 'Averages';
setVAnatomyPath(t1file);
hvol = initHiddenGray;

% Set the volume view to the current data type and add the RM model
hvol = viewSet(hvol,'curdt',dataType);

% Load mrVista retinotopy Gray file
rmModel  = fullfile(mrSessionDir, 'Gray/Averages','retModel-cssFit-fFit.mat');
hvol     = rmSelect(hvol,1,rmModel);
mmPerVox = viewGet(hvol,'mmpervox');
hvol = rmLoadDefault(hvol);

% White surfaces were used in original code. But since we are using pial
% surface later when exporting parameters from freesurfer to brainstorm
% surfaces, it might be wise to chose pial surface here. Don't think it
% will make much difference because the vertices are same for both white
% and pial surface. Only the coordinate values will change for ex in the
% rois.
hemis = {'lh','rh'};

prfDataFile = fullfile(mrSessionDir, 'Gray/Averages','retModel-cssFit-fFit.mat');
load(prfDataFile,'model');

% Loop over all the parameters stored in the exported data file:
prfParamNames = {'co', 'amp', 'ph', 'map'};

% for n_surf = 1:length(surfaces_to_load)
for h = 1:length(hemis)
    
    % Select hemisphere
    allData = {};
    curHemi = hemis{h};
    fprintf('(%s): Loading parameters for %s hemisphere\n',mfilename, curHemi);
    
    % load both pial and white to make midgray
    pialSurfFname = fullfile(fsSurfDir, [curHemi,'.pial']);
    whiteSurfFname = fullfile(fsSurfDir,[curHemi,'.white']);
    
    % Load mesh using fs_meshFromSurface, this creates a mrVista compatible
    % mesh. 
    if smooth
        mrVistaMeshPial = fs_meshFromSurface(pialSurfFname);
        mrVistaMeshWhite = fs_meshFromSurface(whiteSurfFname);
    else
        mrVistaMeshPial = mprf_fs_meshFromSurface(pialSurfFname);
        mrVistaMeshWhite = mprf_fs_meshFromSurface(whiteSurfFname);
    end
    
    mrVistaMeshMidGray_vertices = mean(cat(3, mrVistaMeshPial.vertices, mrVistaMeshWhite.vertices),3);
    
    % compute mapping using mrmMapVerticesToGray (mrmMapGrayToVertices):
    vertex2GrayMap = mrmMapVerticesToGray(mrVistaMeshMidGray_vertices, viewGet(hvol,'nodes'),...
        mmPerVox);
    
    % Select the ones to map to mid gray
    verticesToMap = vertex2GrayMap > 0;
    
    % Loop over every prf parameter
    for param = 1:length(prfParamNames)
        
        curParamName = prfParamNames{param};
        % this seems silly, matlab really doesn't have dicts?!
        if strcmp(curParamName, 'map')
            outParamName = 'eccen';
        elseif strcmp(curParamName, 'ph')
            outParamName = 'phase';
        elseif strcmp(curParamName, 'amp')
            outParamName = 'size';
        elseif strcmp(curParamName, 'co')
            outParamName = 'varexp';
        end
        fprintf('(%s): Exporting %s parameter\n', mfilename, outParamName);
        
        % preallocate space
        prfFS = nan(size(vertex2GrayMap));
        
        % Select the data that fall within the vertices to map
        curData = hvol.(curParamName){1,1}; 
        prfFS(verticesToMap) = curData(vertex2GrayMap(verticesToMap));
        
        % store new mapped prf estimates in allData struct
        allData.(outParamName) = prfFS;
        
    end
    
    % output the results:
    if smooth
        fname = fullfile(prfFSDir,[curHemi '_prfParams_smooth.mat']);
    else
        fname = fullfile(prfFSDir,[curHemi '_prfParams.mat']);
    end
    save(fname, 'allData');
    
    
end

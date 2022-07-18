clear all
close all

%% setup
% set your freesurfer subjects dir if you have multiple depending on the
% project
k_AY_base_dir = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
setenv('SUBJECTS_DIR', k_AY_base_dir);

setSessions;
subjid = fs_sessions{1};

map_dir = fullfile('/share/kalanit/biac2/kgs/projects/toonAtlas/tests/', sessions{1}, 'FreesurferFormat'); 

%% If you want flatmaps, you will need to create them
% see "How to create a flat map" on the Shared Drive for detailed instructions
% Briefly,
% start by creating flat patches in tksurfer (i.e. tksurfer subjid rh inflated), then:
% cd('/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears')
% cd(subjid)
% cd('surf')
% unix('mris_flatten rh.full.patch.3d rh.full.flat.patch.3d')

%% load maps
% set var exp threshold
ve_thresh = .1;
maps = {'eccen', 'phase', 'size'};
hemis = {'lh', 'rh'}; 

lh = load([sprintf('%s/%s_prfParams_smooth.mat', map_dir, 'lh')]);
rh = load([sprintf('%s/%s_prfParams_smooth.mat', map_dir, 'rh')]);

for h = 1:length(hemis)
    if h == 1
        data = lh.allData;
        for m = 1:length(maps)
            data.(maps{m})(isnan(data.(maps{m}))) = 0;
            data.(maps{m})(data.varexp < ve_thresh) = 0;
        end
        data.varexp(isnan(data.varexp)) = 0;
        lh.allData = data;
    else
        data = rh.allData;
        for m = 1:length(maps)
            data.(maps{m})(isnan(data.(maps{m}))) = 0;
            data.(maps{m})(data.varexp < ve_thresh) = 0;
        end
        data.varexp(isnan(data.varexp)) = 0;
        rh.allData = data;
    end
end


%% set colormaps and thresholds (variable names must be as follows)
polar_map = 'mrv'; %options are 'mrv' or 'kk'
%special colormap for phase map
if strcmp(polar_map, 'kk')
    cmap_phase = load('WedgeMapRight_pRF.mat');
    cmr = cmap_phase.modeInformation.cmap;
    cmap_phase = load('WedgeMapLeft_pRF.mat');
    cml = cmap_phase.modeInformation.cmap;
    cm = [cmr(75:118,:); cmr(75:118,:)];
else %mrvista colormap
    nC = 88;
    % build two colormaps: a red->green->blue map, 
    % and a blue->yellow->red map, each using half
    % the available colors:
    rgb = mrvColorMaps('redgreenblue', round(nC/2));
    byr = mrvColorMaps('redyellowblue', round(nC/2));
    byr = flipud(byr);
    cm = [byr; rgb];
    cm = circshift(cm, round(nC/4));
    cm = flipud(cm); 
end

%% specific setup for cvndefinerois.m
mgznames = {'Kastner2015', {lh.allData.eccen' rh.allData.eccen'}, {lh.allData.phase' rh.allData.phase'}, {lh.allData.size' rh.allData.size'}, {lh.allData.varexp' rh.allData.varexp'}}; %maps to load (can be toggled with 3,4,5 & 6 keys)
crngs = {[0 25] [0 20] [0 6.28] [0 10] [0 0.75]}; %range for each map
cmaps = {jet(256) flipud(jet(256)) cm flipud(jet(256)) jet(256)}; %colormap for each map
threshs = {0.5, [0.01], [0.001], [0.01], [0.1]}; %threshold for each map

roilabels = {'V1' 'V2v' 'V2d' 'V3v' 'V3d'}; %rois to draw - 1 x N cell vector of strings
cmap = jet(256); %colormap for ROIs
rng = [1 5]; %integer for each ROI (i.e. in the mgz file V1 vertices will be 1s and hV4 vertices will be 6) - should be [1 N] where N is the max ROI index
roivals = []; %empty because no ROIs so far
%however, if you had a set of previous ROIs you wanted to build upon you
%could reload that like this:
%roivals = cvnloadmgz(sprintf('%s/%s/label/?h.EVC_ROIs.mgz', k_AY_base_dir, subjid));

%% run it
cvndefinerois;
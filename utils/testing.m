clear all

%% setup
% set your freesurfer subjects dir if you have multiple depending on the
% project
k_AY_base_dir = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
setenv('SUBJECTS_DIR', k_AY_base_dir);

setSessions;
subjid = fs_sessions{1}

%% If you want flatmaps, you will need to create them
% start by creating flat patches in tksurfer (i.e. tksurfer subjid rh inflated), then:
% cd('/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears')
% cd(subjid)
% cd('surf')
% unix('mris_flatten rh.full.patch.3d rh.full.flat.patch.3d')
% 
% A flat map has already been created for RJ

%% view maps (created by mrvEccen2fs)
mapType = 'eccen'; %pick a map
data = [sprintf('%s/%s/surf/*.%s_proj_max.mgh', k_AY_base_dir, subjid, mapType)];
data = cvnloadmgz(data);

%special colormap for phase map
cmap_phase = load('WedgeMapRight_pRF.mat');
cmr = cmap_phase.modeInformation.cmap;
cmap_phase = load('WedgeMapLeft_pRF.mat');
cml = cmap_phase.modeInformation.cmap;
cm = [cmr(75:118,:); cmr(75:118,:)];

%view map (using flat map - view 13)
if strcmp(mapType, 'eccen')
    cvnlookup(subjid,13,data,[0.01 20],colormap(flipud(jet)),0.01)
elseif strcmp(mapType, 'phase')
    cvnlookup(subjid,13,data,[0.001 6.28],cm,0.001) %6.28 is 360 in radians
elseif strcmp(mapType, 'size')
    cvnlookup(subjid,13,data,[0.01 10],colormap(flipud(jet)),0.01)
elseif strcmp(mapType, 'varexp')
    cvnlookup(subjid,13,data,[0.05 0.5],colormap(jet),0.05)
end

%% define rois setup
% this is where we actually load the relevant information for using
% cvndefinerois.m
% all we need from the above code is the subjid, to set the fsdir, and the
% cm colormap for phase if we're using that map

%% load maps
lh_eccen = cvnloadmgz([sprintf('%s/%s/surf/lh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'eccen')]);
rh_eccen = cvnloadmgz([sprintf('%s/%s/surf/rh.%s_proj_max.mgh', k_AY_base_dir,subjid, 'eccen')]);

lh_phase = cvnloadmgz([sprintf('%s/%s/surf/lh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'phase')]);
rh_phase = cvnloadmgz([sprintf('%s/%s/surf/rh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'phase')]);

lh_size = cvnloadmgz([sprintf('%s/%s/surf/lh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'size')]);
rh_size = cvnloadmgz([sprintf('%s/%s/surf/rh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'size')]);

lh_varexp = cvnloadmgz([sprintf('%s/%s/surf/lh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'varexp')]);
rh_varexp = cvnloadmgz([sprintf('%s/%s/surf/rh.%s_proj_max.mgh', k_AY_base_dir, subjid, 'varexp')]);

%% set colormaps and thresholds (variable names must be as follows)
mgznames = {{lh_eccen rh_eccen}, {lh_phase rh_phase}, {lh_size rh_size}, {lh_varexp rh_varexp}}; %maps to load (can be toggled with 3,4,5 & 6 keys)
crngs = {[0 20] [0 6.28] [0 10] [0 0.75]}; %range for each map
cmaps = {flipud(jet(256)) cm flipud(jet(256)) jet(256)}; %colormap for each map
threshs = {[0.01], [0.001], [0.01], [0.1]}; %threshold for each map

roilabels = {'V1' 'V2v' 'V2d' 'V3v' 'V3d' 'hV4'}; %rois to draw - 1 x N cell vector of strings
cmap = jet(256); %colormap for ROIs
rng = [1 6]; %integer for each ROI (i.e. in the mgz file V1 vertices will be 1s and hV4 vertices will be 6) - should be [1 N] where N is the max ROI index
roivals = []; %empty because no ROIs so far
%however, if you had a set of previous ROIs you wanted to build upon you
%could reload that like this:
%roivals =
%cvnloadmgz(sprintf('/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears/%s/label/?h.MYROINAME.mgz',
%subjid));

%% run it
cvndefinerois;

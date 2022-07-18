% Transforms individual subject mrVista eccentricity maps to freesurfer
%
% Updated 12/2019 by DF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all

% get our list of subjects from the Set function:
setSessions

% where do the subjects live
expt = '/projects/toonAtlas/'; 
exptDir = fullfile(RAID,expt);
thresh = 0.10; 

genRetDir = [exptDir 'freesurfer_test'];
fsBase = fullfile(RAID, '/anatomy/freesurferRecon/Kids_AcrossYears'); 

% parameter map
mapNames = {'retModel-cssFit-fFit'};
mapType = 'eccen';

for ss = 1:length(fs_sessions)
    subjID = fs_sessions{ss};
    retSession = sessions{ss};

    % path to subject data in 3Danat
    anatDir = fullfile(genRetDir, retSession, '3DAnatomy');
    %anatDir = fullfile(RAID, '/anatomy/vistaVol/Kids_AcrossYears', subjID);
    % path to subject data in FreesurferSegmentations
    fsDir = fullfile(fsBase, subjID);
    % paths to subject mri and surf directories
    mriDir = fullfile(fsDir, 'mri');
    surfDir = fullfile(fsDir, 'surf');
    % path to subject retinotopy session
    retDir = fullfile(genRetDir, retSession);

    for mm = 1:length(mapNames)
        mapName = mapNames{mm};
        mapPath = fullfile(retDir, 'Gray', 'Averages', [mapName, '.mat']);
        outPath = fullfile(mriDir, [mapName, '.nii.gz']);

        %% convert parameter map into nifti and generate surfaces
        cd(retDir);
        hg = initHiddenGray('Averages', 1);
        hg = rmSelect(hg, 1, mapPath);
        hg = rmLoadDefault(hg);
        
        %phase is in hg.ph, ecc is hg.map, and size is hg.amp
        if strcmp(mapType, 'eccen')
            hg.map = hg.map; %default
        elseif strcmp(mapType, 'phase')
            hg.map = hg.ph;
        elseif strcmp(mapType, 'size')
            hg.map = hg.amp;
        elseif strcmp(mapType, 'varexp')
            hg.map = hg.co;
        end

        %threshold based on variance explained (if other map type spec'ed)
        if ~strcmp(mapType, 'varexp')
            for i = 1:length(hg.map{1, 1})
                if hg.co{1, 1}(i) < thresh
                    hg.map{1, 1}(i) = NaN;
                end
            end
        end

        hg = loadAnat(hg);
        functionals2itkGray(hg, 1, outPath);

        cd(mriDir);
        cmd = ['mri_convert -ns 1 -odt float -rt nearest -rl orig.mgz ', mapName, '.nii.gz ', mapName, '.nii.gz --conform'];
        unix(cmd);

        movefile(fullfile(mriDir, [mapName, '.nii.gz']), fullfile(surfDir, [mapName, '.nii.gz']));

        cd(surfDir);
        
        %delete retModel-testingDoubleSigsWithLin-cssFit-fFit*.mgh %get rid of any previous version in case there are errors

        proj_values = [-2:0.1:2];
        % iterate through proj frac values so there aren't holes in the map
        for p = 1:length(proj_values)

            unix(['mri_vol2surf --mov ', mapName, '.nii.gz --reg register.dat --hemi lh --interp nearest --o ', ...
                fullfile(surfDir, strcat(mapName, '_lh_proj_', num2str(proj_values(p)), '.mgh')), ...
                ' --projdist ', num2str(proj_values(p))]); % left hemi

            unix(['mri_vol2surf --mov ', mapName, '.nii.gz --reg register.dat --hemi rh --interp nearest --o ', ...
                fullfile(surfDir, strcat(mapName, '_rh_proj_', num2str(proj_values(p)), '.mgh')), ...
                ' --projdist ', num2str(proj_values(p))]); % right hemi

        end


        unix(['mri_concat --i ', strcat(mapName, '_lh_proj_*'), ...
            ' --o ', sprintf('lh.%s_proj_max.mgh', mapType), ...
            ' --max']);

        unix(['mri_concat --i ', strcat(mapName, '_rh_proj_*'), ...
            ' --o ', sprintf('rh.%s_proj_max.mgh', mapType), ...
            ' --max']);


    end

end

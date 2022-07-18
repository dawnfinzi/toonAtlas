function toon_surf2msh(fsPath, vistaPath)
% function toon_surf2msh(fsPath, vistaPath)
% gets the lh.orig and rh.orig meshes from FreeSurfer and exports them to
% mrVista meshes
% Inputs
% fsPath        path to freesurfer directory 
% vistaPath     path to mrVista directory
%
% example:
% fsPath ='/Users/kalanit/Projects/SNI_NeuroDevelopment/Babies/FreeSurferSegmentations/bb11_mri0_t1_cloudbeat_test_vn';
% vistaPath='/Users/kalanit/Projects/SNI_NeuroDevelopment/Babies/data/bb11_mri0/3Danatomy'
% toon_surf2msh(fsPath, vistaPath)
% 
% KGS 2/20
% Adapted DF 06/22

% get a fs surface
lh_fsSurface=fullfile(fsPath, 'lh.orig');
% make a mesh
lh_msh = fs_meshFromSurface(lh_fsSurface);
% visualize it
meshVisualize(lh_msh)
% save mesh
out_filename=fullfile(vistaPath, 'lh_orig')
[msh, savePath] = mrmWriteMeshFile(lh_msh, out_filename)

% now for the right hemisphere
rh_fsSurface=fullfile(fsPath,'rh.orig');
rh_msh = fs_meshFromSurface(rh_fsSurface)
meshVisualize(rh_msh)
out_filename=fullfile(vistaPath,'rh_orig');
[msh, savePath] = mrmWriteMeshFile(rh_msh, out_filename)


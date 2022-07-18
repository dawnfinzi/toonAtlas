close all;
clear all;

% set your freesurfer directory to be safe
k_AY_base_dir = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
setenv('SUBJECTS_DIR', k_AY_base_dir);

setSessions;
% what subject to you want to rotate:
subjectid = fs_sessions{1}; %'fsaverage';

cd(sprintf('%s/%s/surf',k_AY_base_dir,subjectid));
delete('imglookup/full.flat*'); %delete previously cached lookup tables for cvndefinerois

hemis = {'lh' 'rh'};
% specific left and right hemisphere rotations; positive means CCW
% left 90 and right -90 are typical (rots = [90 -90];)
rots = [-180 0]; %[90 -90];  

% loop through hemis and rotate
for p=1:length(hemis)

  patchfile = sprintf('%s.full.flat.patch.3d',hemis{p});
  a1 = fast_read_patch_kj(patchfile);

  % place COM at origin
  a1.x = zeromean(a1.x);
  a1.y = zeromean(a1.y);

  % make flat patch and rotate
  a2 = a1;
  ang = rots(p)/180*pi;
  rotmat = [cos(ang) -sin(ang) 0;
            sin(ang)  cos(ang) 0;
                 0       0     1];
  temp = rotmat * [a2.x; a2.y; ones(1,length(a2.x))];
  a2.x = temp(1,:);
  a2.y = temp(2,:);

  copyfile(patchfile,[patchfile '.backup']);  % delete when done
  fast_write_patch_kj(patchfile,a2);

end

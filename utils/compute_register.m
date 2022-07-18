%% Compute register.dat file manually if it hasn't been created

fsDirs   = {'RJ09_scn181028_recon0920_v6'}; %{'SERA10_scn191214_recon0920_v6'};

% make register.dat
for s=1:length(fsDirs)
    % subject = the subject name of the freesurfer directory
    subject = fsDirs{s};
    origPath = ['/biac2/kgs//anatomy/freesurferRecon/Kids_AcrossYears/' subject '/mri/orig.mgz'];
    outFile = ['/biac2/kgs//anatomy/freesurferRecon/Kids_AcrossYears/' subject '/surf/register.dat']; %originally went to subject/label/register.dat
    cmd = ['tkregister2 --mov ' origPath ' --noedit --s ' subject ' --regheader --reg ' outFile];
    unix(cmd)
end

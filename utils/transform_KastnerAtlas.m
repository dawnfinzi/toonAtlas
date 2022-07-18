clear all
close all

k_AY_base_dir = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
setenv('SUBJECTS_DIR', k_AY_base_dir);
%%
fsbase = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
fsavg = fullfile(fsbase, 'fsaverage');
setSessions;

hemis = {'lh', 'rh'};

%% Map Kastner atlas ROIs to native surface spaces via nearest-neighbor

for s = 1:length(fs_sessions)
    for h = 1:length(hemis)
                
        sourcedata = sprintf([fsavg '/label/%s.Kastner2015.mgz'], hemis{h});
        
        target = fs_sessions{s}; 
        fsdir = fullfile(fsbase, target);
        outfile = sprintf([fsdir '/label/%s.Kastner2015.mgz'], hemis{h});
        
        % align to subject space
        command = [ 'mri_surf2surf  --srcsubject fsaverage --srcsurfreg  sphere.reg  --trgsubject ' target ' --trgsurfreg sphere.reg --hemi ' hemis{h} ' --sval ' sourcedata ' --tval ' outfile];
        unix(command);
        %nsd_mapdata(subjid,'fsaverage',sprintf('%s.white',hemis{p}),sourcedata,[],0,outfile,[],fsbase);
    end
    
end
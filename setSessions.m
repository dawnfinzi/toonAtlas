function [session, fs_session] = setSessions(subjInitials, sessionNr,varargin)
%
% List of kids with toonotopy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check inputs for extra test folder flag
if nargin<3 
    testFolder = [];
else
    testFolder = varargin{1};
end

% all subjects and freesurfer sessions
switch subjInitials
    
    case 'RN09'
        if sessionNr == 1
            session = 'RJ09_190914_21289_time_04_1';
            fs_session = 'RJ09_scn191027_recon0920_v6';
        elseif sessionNr == 2
            session = 'RJ09_190112_19741_time_03_1';
            fs_session = 'RJ09_scn181028_recon0920_v6'; 
            if ~isempty(testFolder)
                session = [session '_' testFolder];
            end
        else
             error('[%]: Cannot find sessionNr!',mfilename)
        end
    case 'ENK05'
         if sessionNr == 1
            session = 'ENK05_190317_19993_time_03_1';
            fs_session = 'ENK05_scn181201_recon0920_v6';
            if ~isempty(testFolder)
                session = [session '_' testFolder];
            end
         else
             error('[%]: Cannot find sessionNr!',mfilename)
         end
end

% NOTES:
% fs_sessions = {'ENK05_scn191214_recon0920_v6'}; JC/BF made new .gz files

return
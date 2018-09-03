function setupPsychMasterPath()
%setupPsychMasterPath - Make sure required directories are on the path. 
%setupPsychMasterPath()
%
%This is a function to help make sure required directories are on the path
%for running psychMaster. 

%find where this function is being called from.
thisFile = mfilename('fullpath');
[thisDir, ~, ~] = fileparts(thisFile);

%For now just grab this and all subdirectories
newPath2Add = genpath(thisDir);

%Now let's find the directories that are missing and add only them
%to the path.
%Why not just add all sub directories to the path and let matlab
%auto prune redundancies? Well, that always brings the added
%directoreis top of the path. Which _may_ not be wanted from the
%user.
subDirCell = regexp(newPath2Add, pathsep, 'split');
pathCell = regexp(path, pathsep, 'split');

for iSub = 1:length(subDirCell)
    
    thisFolder = subDirCell{iSub};
    
    %If thisFolder doesn't match any of the directories on the path
    %add it to the path.
    if  ~any(strcmp(thisFolder, pathCell));
        msg = sprintf('Adding to path: %s',thisFolder);
        disp(msg);
        addpath(thisFolder);
        
    end
    
end

end
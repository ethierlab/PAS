function [ mat_filenames ] = extractor( savepath )
% EXTRACTOR takes the matlab filenames in a folder and strips out the
% prefixes and the file extensions, leaving an array with polished filenames
% that can be used as input to TDT_preproc and other automated functions

    %folderpath = uigetdir('','Open folder where .mat files are stored');    
    cd(savepath)
    
    rawlist = what(savepath);
    rawlist = rawlist.mat;
    listlength = size(rawlist,1);
    
    for counter = 1:listlength
        tempstring = rawlist(counter);
        tempstring = char(string(tempstring));
        mat_filenames{counter,:} = tempstring;
    end
    
end

% fullfile
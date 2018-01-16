% FUNCTION: TDT_import.m
% C Ethier, W Ting, 2017
% Purpose: To import TDT Data into a matlab structure for further
% processing
% INPUTS: varargin{load_flag} (whether or not to load imported data in base workspace
% OUTPUTS: PRE_tdtstructure (TDT Pre PAS Data imported into Matlab format);
% POST_tdtstructure (TDT Post PAS Data imported into Matlab format)

% function [ PRE_tdtstructure, POST_tdtstructure ] = TDT_import( ) 
%     % Use TDT2mat to import PRE and POST data in specified directory into 'PRE_tdtstructure' and 'POST_tdtstructure' matlab structures, respectively.
%     PREfolderpath = uigetdir('','Open directory where PRE DATA is stored');
%     PRE_tdtstructure = TDT2mat(PREfolderpath);
%     POSTfolderpath = uigetdir('','Open directory where POST DATA is stored');
%     POST_tdtstructure = TDT2mat(POSTfolderpath);
% end

function [ save_path, num_data_files, tdt_struct ] = TDT_import(varargin)
    load_flag = false;
    
    if nargin
        load_flag = varargin{1};
    end

    % Use TDT2mat to import all data in specified directory 
    folderpath = uigetdir('','Open parent directory where DATA is stored');
    data_dir = dir(folderpath);
    
    if isempty(data_dir)
        warning('empty_directory');
        return;
    end
    
    save_path = uigetdir('','Where do you want the files to be saved');
    
    % TODO: find a better way to skip the '.' and '..' directories
    dir_idx = find([data_dir.isdir]); 
    dir_idx = dir_idx(3:end);

    num_data_files = length(dir_idx);

    for f = 1:num_data_files
        % TODO: check file extension if it really looks like a data tank
        file_name = data_dir(dir_idx(f)).name;
        
        tdt_struct = TDT2mat(fullfile(folderpath,file_name), 'VERBOSE', 0);
        
        file_name = ['m' file_name];
        eval([file_name '=tdt_struct']);
        
        %TODO: make saved structure names to match folder name and file
        %names
        save(fullfile(save_path,file_name),file_name);
        
        if load_flag
            assignin('base',file_name,tdt_struct);
        end
    end
end
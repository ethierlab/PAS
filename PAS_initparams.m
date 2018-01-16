% FUNCTION: PAS_initparams.m
% C Ethier, W Ting, 2017
% Purpose: Allows the user to specify desired init params
% INPUTS: NA
% OUTPUTS: userlower (user-specified lower bound of desired analysis time);
% userupper (user-specified upper bound of desired analysis time);
% usernumberchannel (user-specified number of channels in TDT data
% collected); usernorm (whether the user wants to perform analysis with
% normalized data or not)

function [ userlower, userupper, EMG_vect, norm, analyzestimdur, analyzeallflag, numbersessions, auto ] = PAS_initparams( )
    % Create dialog prompt and save variables. 
    prompt = {'Enter desired lower bound (s):','Enter desired upper bound (s):','Channel Numbers (space delimited):','Proceed with normalized data? (Y/N)','Just analyze stim interval? (Overrides Upper and Lower Bound) (Y/N)','analyze all?','Total number of sessions:'};
    dlg_title = 'Input desired analysis parameters';
    num_lines = 1;
    % Default params
    defaultans = {'0.1','0.8','1:2','Y','Y','N','5'};
    params = inputdlg(prompt,dlg_title,num_lines,defaultans);
    userlower = str2double(params{1});
    userupper = str2double(params{2});
    EMG_vect = str2num(params{3});
    norm = params{4};
    analyzestimdur = params{5};
    analyzeallflag = params{6};
    numbersessions = params{7};
    auto = 0;
    if strcmpi (norm, 'Y') == 1 || strcmpi (norm, 'yes') == 1
        norm = true;
    elseif strcmpi (norm, 'N') == 1 || strcmpi (norm, 'no') == 1
        norm = false;
    end
    
    if strcmpi (analyzestimdur, 'Y') == 1 || strcmpi (analyzestimdur, 'yes') == 1
        analyzestimdur = 1;
    elseif strcmpi (analyzestimdur, 'N') == 1 || strcmpi (analyzestimdur, 'no') == 1
        analyzestimdur = 0; 
    end
%     if norm == true
%         set(handles.userlower, 'enable', 'off')
%         set(handles.userupper, 'enable', 'off')
%     end
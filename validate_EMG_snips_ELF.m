function [data] = validate_EMG_snips_ELF(data,varargin)
%Plots individual trials of EMG responses and asks the user to validate (keep) or not (reject) the responses


if nargin > 1
    params = varargin{1};
else
    params = struct(...
    'emg_vec'       , [],...
    'time_before'   , [],...
    'time_after'    , [],...
    'rectify'       , true);
end

if ~isfield(data,'format')
    warning('Data not in ELF format, using validate_EMG_snips.m function instead');
    data = validate_EMG_snips(data,params);
    return;
end

chan_list = data.snips.chan_list;
num_tot_chan = length(chan_list);
if ~isempty(params.emg_vec)
    chan_list = params.emg_vec;
end

num_chan    = length(chan_list);
num_snips   = data.snips.num_snips;
valid_snips = true(1,data.snips.num_snips);
stop_now    = false;
isartifact = 0;

%relevant time index
if ~isempty(params.time_before)
    t_idx = data.snips.timeframe>=-params.time_before/1000 & data.snips.timeframe<=params.time_after/1000;
else
    t_idx = true(1,length(data.snips.timeframe));
end

fh = figure; set(gcf,'Units','normalized','Position',[.2 .2 .6 .6]);

keep_button = uicontrol('Parent',fh,'Style','pushbutton','String','MEP +',...
    'Units','normalized','Position',[.27 .02 .08 .06],'ForegroundColor','g','Callback',@(src,evnt)valid_cbk(true,0));
reject_button = uicontrol('Parent',fh,'Style','pushbutton','String','MEP -',...
    'Units','normalized','Position',[.37 .02 .08 .06],'ForegroundColor','r','Callback',@(src,evnt)valid_cbk(false,0));
close_button = uicontrol('Parent',fh,'Style','pushbutton','String','CLOSE',...
    'Units','normalized','Position',[.47 .02 .08 .06],'Callback',@(src,evnt)close_cbk);
artifact_button = uicontrol('Parent',fh,'Style','pushbutton','String','ARTIFACT',...
    'Units','normalized','Position',[.57 .02 .08 .06],'ForegroundColor','b','Callback',@(src,evnt)valid_cbk(false,1));
    

for s = 1:num_snips
    % for each snip...
    
    % plot each channel in a subplot
    ah = nan(1,num_chan);
    for ch = 1:num_chan
        ah(ch) = subplot(num_chan,1,ch);
        ydata = data.snips.data{s,chan_list(ch)};
        if params.rectify
            ydata = abs(ydata);
        end
        plot(data.snips.timeframe(t_idx),ydata(t_idx));
        title(sprintf('EMG ch %d, snip %d/%d',chan_list(ch),s,num_snips));
    end
    linkaxes(ah,'xy');
    
    %wait until user clicks one of the buttons
    uiwait(gcf);
    if stop_now || ~ishandle(fh)
        break;
    end
end

% done with validation, save new data
if ishandle(fh)
    close(fh);
end

save_data = questdlg('Finished. Update data?', ...
    'Confirm changes', ...
    'Update', 'Cancel', 'Update');
switch save_data
    case 'Update'
        data.snips.num_snips = sum(valid_snips);
        data.snips.onsets    = data.snips.onsets(valid_snips,:);
        data.snips.data      = data.snips.data(valid_snips,:);
        if isfield(data.snips,'sortcode')
            data.snips.sortcode  = data.snips.sortcode(valid_snips,:);
        end
        
        % automatically save record of validation choices for
        % cross-reference later and replication of analyses.
        data.validation_record = {};
        data.validation_record = [data.validation_record, valid_snips];
        
        data.artifact_record = isartifact;
       
    case 'Cancel'
        disp('Validation cancelled');
end

% prompt = {'Enter animal name:','Enter Session Date','Enter STDP Condition'};
% dlgtitle = 'Metadata';
% metadata = inputdlg(prompt,dlgtitle);
% data.metadata = metadata;

    function valid_cbk(isvalid,newartifact)
        valid_snips(s) = isvalid;
        isartifact = isartifact+newartifact;
        uiresume(gcbf);
    end

    function close_cbk()
        stop_now     = true;
        uiresume(gcbf);
    end
 end

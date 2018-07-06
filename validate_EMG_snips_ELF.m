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

%relevant time index
if ~isempty(params.time_before)
    t_idx = data.snips.timeframe>=-params.time_before/1000 & data.snips.timeframe<=params.time_after/1000;
else
    t_idx = true(1,length(data.snips.timeframe));
end

fh = figure; set(gcf,'Units','normalized','Position',[.2 .2 .6 .6]);

keep_button = uicontrol('Parent',fh,'Style','pushbutton','String','KEEP',...
    'Units','normalized','Position',[.22 .02 .08 .06],'ForegroundColor','g','Callback',@(src,evnt)valid_cbk(true));
reject_button = uicontrol('Parent',fh,'Style','pushbutton','String','REJECT',...
    'Units','normalized','Position',[.47 .02 .08 .06],'ForegroundColor','r','Callback',@(src,evnt)valid_cbk(false));
close_button = uicontrol('Parent',fh,'Style','pushbutton','String','CLOSE',...
    'Units','normalized','Position',[.72 .02 .08 .06],'Callback',@(src,evnt)close_cbk);


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
    if stop_now
        break;
    end
end

% done with validation, save new data
close(fh);

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
        
        csvwrite([data.info.blockname '.txt'],valid_snips)
        msgbox({'Validation Choices Saved in a Text File by Block Name, in:'; pwd; [num2str(data.snips.num_snips) ' Trials Were Kept.']});
        
        
    case 'Cancel'
        disp('Validation cancelled');
end


    function valid_cbk(isvalid)
        valid_snips(s) = isvalid;
        uiresume(gcbf);
    end

    function close_cbk()
        stop_now     = true;
        uiresume(gcbf);
    end
 end

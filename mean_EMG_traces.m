function [meanEMGs] = mean_EMG_traces(data_array,EMG_vec,varargin)
%
% usage: mEMG = mean_EMG_trace(data_array,EMG_vec,[params])
%
%  This function averages the mean EMG signals specified in EMG_vec for each data structure present in the first column of the cell array data_array.
%  It returns the average EMG traces for each data structure and plots them all if the "plot_flag" optional argument is true.
%
%   inputs:
%       data_array  :  cell array of data structure, as provided by parse_tdt_data.m
%       EMG_vec     :  vector of EMG channels for which to measure recruitment
%       params      :  (optional) none, one or many of these can be provided, any missing parameter will be
%                      set to its default value, indicated in brackets here below.
%                      Use either the ('param_name',param_value) pairs or a params structure with 'param_name' fields
%
%           'plot'      :  [true], whether or not to produce one figure of all mean EMG traces for each data structure
%           'rectify'   :  [true], flag to indicate whether or not to rectify the data
%           'time_range':  [] empty to use all available data, or 2 element vector specifing desired [time_min time_max]
%
%   outputs:
%       meanEMGs = struct(...
%                   'Blocknames'    : string of block names (file names)
%                   'chan_list'     : array with emg channel numbers (same as EMG_vec)
%                   'EMGmean'       : mean emg traces over specified time range
%                   'EMGsd'         : sd of mean emg traces over specified time range
%                   'N'             : number of emg traces that were averaged
%
%%%% Ethierlab 2018/01 -- CE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Argument handling

% defaults parameters
params = struct(...
    'rectify'         ,'false', ...
    'plot'         , true,...
    'time_range'   ,[]);

params = parse_input_params(params,varargin);

% EMG variables:
if isempty(EMG_vec)
    EMG_vec = data_array{1,1}.snips.chan_list;
end

num_blocks    = size(data_array,1);
nEMGs         = length(EMG_vec);
EMGm          = cell(num_blocks,nEMGs);
EMGsd         = cell(num_blocks,nEMGs);
N             = nan(num_blocks,1); %number of snips
chan_list     = data_array{1,1}.snips.chan_list(EMG_vec);

% timeframe variables:
timeframe = data_array{1,1}.snips.timeframe;

if ~isempty(params.time_range)
    valid_idx = timeframe>=params.time_range(1) & timeframe<=params.time_range(2);
else
    valid_idx = true(1,length(timeframe));
end

timeframe = timeframe(valid_idx);
numpts    = length(timeframe);

% EMG processing
for b = 1:num_blocks
    
    EMGs     = data_array{b,1}.snips.data(:,EMG_vec);
    N(b,1)   = size(EMGs,1);
    ah       = nan(1,nEMGs);
    figure;
    
    %loop individual channels to extract data from cell array to 2D-matrix
    for e = 1:nEMGs
        
        tmp_emg = vertcat(EMGs{:,e});
        tmp_emg = tmp_emg(:,valid_idx);
        
        if params.rectify
            tmp_emg = abs(tmp_emg); %rectify
        end
        
        EMGm{b,e}  = mean(tmp_emg)';
        EMGsd{b,e} =  std(tmp_emg)';
              
        if params.plot
            %convert to mV
            ah(e) = subplot(nEMGs,1,e);
            plotShadedSD(ah(e),timeframe,10^6*EMGm{b,e},10^6*EMGsd{b,e});
            xlabel('Time (s)');
            ylabel('mean EMG (uV)');
            title(strrep(sprintf('mean EMG traces for datablock %s',data_array{b,2}),'_','\_'));
            legend(sprintf('ch %d',chan_list(e)));
        end
    end
    if params.plot
        linkaxes(ah,'xy');
    end
end

meanEMGs = struct(...
    'Blocknames'    ,{data_array(:,2)},...
    'chan_list'     ,chan_list,...
    'EMGmean'       ,{EMGm},...
    'EMGsd'         ,{EMGsd},...
    'N'             ,N);


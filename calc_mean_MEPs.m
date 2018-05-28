function meanMEPs = calc_mean_MEPs(data_array,varargin)
% usage: meanMEPs = calc_mean_MEPs(EMGs,timeframe,[params])
%
%  This function returns the average EMG response for all data blocks in data_array,
%       calculated based on the parameters in params
%
%   inputs:
%       data_array  :  [nblocks x 2] cell array of data in ELF format (see convertTDT2ELformat.m)
%
%       params      :  (optional) none, one or many of these can be provided, any missing parameter will be
%                      set to its default value, indicated in brackets here below.
%                      Use either the ('param_name',param_value) pairs or a params structure with 'param_name' fields
%
%           'rectify'      :  [true] flag to indicate data has to be rectified.
%                                     if false, the peak-to-peak value of unrectified EMG data is returned
%
%           'median'       :  [false] logical flag to return median instead of mean
%
%           'emg_vec'      :  [] vector of emg channels to include. leave empty to include all.
%
%           'rem_baseline' :  [false] logic flag indicating whether to remove the average baseline
%                             EMG prior to stim onset from measured EMG response
%
%           'window'       :  [0 200] two-element vector to delimit the EMG response analysis time window (in milliseconds)
%
%   outputs:
%       meanMEPs = struct(...
%                   'Blocknames'    : string of block names (file names)
%                   'chan_list'     : array with emg channel numbers (same as EMG_vec)
%                   'MEPs'          : mean MEP measures over specified time window
%                   'sd'            : sd of mean MEPs over specified time window
%                   'N'             : number of MEPs that were averaged
%                   'median'        : wether or not the median was used instead of the mean for the calculation

%%%% Ethierlab 2018/05 -- CE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Argument handling

% defaults parameters
params = struct( ...
    'rectify'      ,true, ...
    'median'       ,false, ...
    'rem_baseline' ,false, ...
    'emg_vec'      ,[], ...
    'window'       ,[0 200]);

params = parse_input_params(params,varargin);

%% loop data blocks
if isempty(params.emg_vec)
    params.emg_vec = data_array{1,1}.snips.chan_list;
end

num_emgs   = length(params.emg_vec);
num_blocks = size(data_array,1);
mMEP       = nan(num_blocks,num_emgs);
sdMEP      = nan(num_blocks,num_emgs);
N          = nan(num_blocks,1); %number of snips

for b = 1:num_blocks
    
    N(b) = data_array{b,1}.snips.num_snips;
    
    for e = 1:num_emgs
  
        %extract data from cell array to 2D-matrix
        tmp_emg = data_array{b,1}.snips.data(:,data_array{b,1}.snips.chan_list==params.emg_vec(e));
        tmp_emg = vertcat(tmp_emg{:});
        
        % extract data over time window
        tmp_emg =  tmp_emg(:,data_array{b,1}.snips.timeframe>=params.window(1)/1000 & data_array{b,1}.snips.timeframe<=params.window(2)/1000);
        
        if params.rectify
            %calculate mean EMG over time window for each stimulus individually
            tmp_emg  = abs(tmp_emg);
            tmp_resp = mean(tmp_emg,2);
            tmp_sd   = std(tmp_resp);
        else
            %calculate peak-to-peak value during time window for each stimulus individually
            tmp_resp = range(tmp_emg,2);
            tmp_sd   = sd(tmp_resp);
        end
        
        % calculates mean (or median) of all responses to all stimuli
        if params.median
            tmp_resp = median(tmp_resp);
        else
            tmp_resp = mean(tmp_resp);
        end
        
        mMEP(b,e)  = tmp_resp;
        sdMEP(b,e) = tmp_sd;
    end
end

meanMEPs = struct(...
    'Blocknames'    ,{data_array(:,2)},...
    'chan_list'     ,params.emg_vec,...
    'MEPs'          ,{mMEP},...
    'sd'            ,{sdMEP},...
    'N'             ,N,...
    'median'        ,params.median);

function MEPs = calc_mean_MEPs(data_array,varargin)
% usage: MEPs = calc_mean_MEPs(EMGs,timeframe,[params])
%
%  This function returns the average EMG response for all data blocks in data_array,
%       calculated based on the parameters in params.
%               if rectify -> mean (or median) of response integral in mV*ms
%               else       -> mean (or median) of peak-to-peak response in mV
%
%   inputs:
%       data_array  :  [nblocks x 2] cell array of data in ELF format (see convertTDT2ELformat.m)
%
%       params      :  (optional) none, one or many of these can be provided, any missing parameter will be
%                      set to its default value, indicated in brackets here below.
%                      Use either the ('param_name',param_value) pairs or a params structure with 'param_name' fields
%
%           'emg_vec'      :  [] vector of emg channels to include. leave empty to include all.
%
%           'window'       :  [0 20] two-element vector to delimit the EMG response analysis time window (in milliseconds)
%           'amp_gain'     :  [1] scales the MEP values inversely proportionaly to amp_gain
%
%   outputs:
%       MEPs = struct(...
%                   'Blocknames'    : string of block names (file names)
%                   'chan_list'     : array with emg channel numbers (same as EMG_vec)
%                   'p2p'           : structure containing individual measures of peak-to-peak amplitude over time window
%                   'int'           : structure containing individual measures of integral of EMG over time window
%                   'base_mean'     : mean of the rectified EMG prior to stimulation
%                   'N'             : number of MEPs that were averaged
%                   'int_ave_mep'   : integral of averaged, then rectified meps

%%%% Ethierlab -- CE %% updated: 2018/07 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Argument handling

% defaults parameters
params = struct( ...
    'emg_vec'      ,[], ...
    'window'       ,[0 20],...
    'amp_gain'     , 1);

params = parse_input_params(params,varargin);

%% loop data blocks
if isempty(params.emg_vec)
    params.emg_vec = data_array{1,1}.snips.chan_list;
end

num_emgs   = length(params.emg_vec);
num_blocks = size(data_array,1);
p2p_meps   = cell(num_blocks,num_emgs);
p2p_mean   = nan(num_blocks,num_emgs);
p2p_sd     = nan(num_blocks,num_emgs);
int_meps   = cell(num_blocks,num_emgs);
int_mean   = nan(num_blocks,num_emgs);
int_sd     = nan(num_blocks,num_emgs);
base_mean  = nan(num_blocks,num_emgs);
N          = nan(num_blocks,1); %number of snips
int_ave_mep= nan(num_blocks,1); %integral of averaged, rectified meps

for b = 1:num_blocks
    
    N(b) = data_array{b,1}.snips.num_snips;
    fs = data_array{b,1}.snips.fs;
    
    for e = 1:num_emgs
  
        %extract data from cell array to 2D-matrix
        tmp_emg = data_array{b,1}.snips.data(:,data_array{b,1}.snips.chan_list==params.emg_vec(e));
        tmp_emg = vertcat(tmp_emg{:});
        
        %convert to mV
        tmp_emg = tmp_emg.*1000/params.amp_gain;
        
        % response and baseline windows
        resp_idx = data_array{b,1}.snips.timeframe>=params.window(1)/1000 & data_array{b,1}.snips.timeframe<=params.window(2)/1000;
        base_idx = data_array{b,1}.snips.timeframe < 0;       

        % peak-to-peak MEPs
        p2p_meps{b,e} = range(tmp_emg(:,resp_idx),2); 
        p2p_mean(b,e) = mean(p2p_meps{b,e});
        p2p_sd(b,e)   = std(p2p_meps{b,e});
      
<<<<<<< Updated upstream
%        % rectify 
%        tmp_emg = abs(tmp_emg);

        % rectify and filter EMG
        tmp_emg = EMGs_rect_filt(tmp_emg',fs)';
=======
        % rectify
        tmp_emg = abs(tmp_emg);
        
%              %remove baseline
%             tmp_emg = tmp_emg - mean(mean(tmp_emg(:,base_idx)));
>>>>>>> Stashed changes

        % integral of rectified average MEPs (baseline emg not removed)
        int_meps{b,e} = sum(tmp_emg(:,resp_idx),2)*1000/fs; % also convert to mV*ms
        int_mean(b,e) = mean(int_meps{b,e});
        int_sd(b,e)   = std(int_meps{b,e});
        
                
        % calculate mean of all traces for that probe
        tmp_emg = mean(tmp_emg,1);
        
        int_ave_mep(b,e) = sum(tmp_emg(:,resp_idx),2)*1000/fs; % integral in mV*ms
        
        %baseline mean
        base_mean(b,e) = mean(mean(tmp_emg(:,base_idx))); 

    end
end

MEPs = struct(...
    'Blocknames'        ,{data_array(:,2)},...
    'chan_list'         ,params.emg_vec,...
    'p2p'               ,struct('meps',{p2p_meps},'mean',p2p_mean,'sd',p2p_sd),...
    'integral'          ,struct('meps',{int_meps},'mean',int_mean,'sd',int_sd),...
    'integral_ave'      ,int_ave_mep,...
    'base_mean'         ,base_mean,...
    'amp_gain'          ,params.amp_gain,...
    'MEPs_window'   ,params.window,...
    'N'                 ,N);

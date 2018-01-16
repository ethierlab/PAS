% FUNCTION: TDT_preproc.m
% C Ethier, W Ting, 2017
% Purpose: To preprocess TDT structure for later analysis.
% Features:
% 1. Specify the analysis' desired time range.
% 2. Specify the number of TDT channel data acquired.
% 3. Aligns data points with a time axis relative to stimulation.
% 4. EMG signal rectification and mean calculation.
% INPUTS: PRE_tdtstructure, POST_tdtstructure, userlower, userupper (see
% other functions for input descriptions)
% OUTPUTS: mean_rect_EMGs (mean rectified EMG signals ready for further
% analysis); lowerbound (converted userlower into column number on
% time_axis); upperbound (converted userupper into column number on
% time_axis); num_chan (number of channels specified by TDT data);
% time_axis (horizontal vector with times concordant with the data points
% collected in the TDT data).

function processed_data = TDT_preproc ( tdt_struct, auto, rem_baseline_flag, userlower, userupper, analyzestimdur, EMG_vect, muscle_of_interest)

    % extract basic info from data structure
    StS_names = fieldnames(tdt_struct.snips);
    % Error handling for multiple strobe signals
    if length(StS_names) > 1 
        % if there are multiple names:
        warning('not implemented for multiple strobe signals yet'); 
        % print warning that multiple signals are not implemented yet
    end

    % obtain snip data and store in 'STS'
    StS = getfield(tdt_struct.snips,StS_names{1});
    % get epoch names from the epocs section from the TDT structure
    epoc_names =  fieldnames(tdt_struct.epocs);
    % compare 'epoc_names' and 'stim' to see if the strings are identical, and store the result [1] if they are the same and [0] if they are different in the variable 'stim_field'
    stim_field = strcmpi(epoc_names,'stim');
    blockname = strrep(tdt_struct.info.blockname,'_','');

    % obtain stim onset time
    stim_epoc  = getfield(tdt_struct.epocs,epoc_names{stim_field}); 
    % assign 'stim_onset1' to the onset time of the epoch
    stim_onset1= stim_epoc.onset(1,1);
    
    snip_onsets = unique(StS.ts);
    
    num_orig_chan = length(unique(StS.chan));
    
    %check if there was any snip and stim onset mismatch
    if length(stim_epoc.onset)~=length(snip_onsets)
        error('your data in %s sucks, different number of snips and epoch onsets fix it!',blockname);
    end
    if any(stim_epoc.onset-snip_onsets)>1
        error('timing mismatch (>1sec) between snips and epoch onsets in %s, fix it!',blockname);
    end
    
    %check if there was an extra snip recorded at the beginning of the file
    if stim_epoc.onset(1,1)-snip_onsets(1) > 1
        warning('extra snip detected at file onset - removed first snip!');
        % there is a greater than one second difference between beginning
        % of the first snip and first stim onset. remove first snip
        StS.ts      = StS.ts(num_orig_chan+1:end,:);
        StS.data    = StS.data(num_orig_chan+1:end,:);
        StS.chan    = StS.chan(num_orig_chan+1:end,:);
        StS.sortcode= StS.sortcode(num_orig_chan+1:end,:);
    end
    
    % initialize variables and counters
    % chan_list     = unique(StS.chan); 
    num_chan      = length(EMG_vect);
    [num_rows, num_data_pts]  = size(StS.data);  
    num_stim       = num_rows/num_orig_chan;
   
    % calculate the required time bin duration by taking 
    % the inverse of the sampling frequency, and store it in the variable
    % 'time_bin'
    time_bin  = 1/tdt_struct.streams.EMGs.fs; 
    % calculate the pre-stim time
    pre_stim_t = StS.ts(1,1)-stim_onset1;
    % reframe data collected into time since stim
    time_axis = pre_stim_t:time_bin:(pre_stim_t+(num_data_pts*time_bin)-time_bin);
    
    stim_onset = find(time_axis>=0,1,'first');

    % Take user specified lower and upper bound times and find the column
    % numbers where these are found.
    lowerbound = find(time_axis>=userlower,1,'first');
    upperbound = find(time_axis<=userupper,1,'last');

    if analyzestimdur == 1
        analyzetimeframe = stim_onset:find(time_axis<=(tdt_struct.epocs.Stim.offset(1)-tdt_struct.epocs.Stim.onset(1)),1,'last');
        % analyzetime_idx = time_axis<=
    else
        analyzetimeframe = lowerbound:upperbound;
    end
    
    % establish initial array of logicals for 'valid_stims' and 'valid_UNRECT_stims'  
    valid_stims = true(num_stim,1);
    valid_UNRECT_stims = true(num_stim,1);
    
    counter = 1;
    
    for ch = 1:num_chan  
        
        % channel ID will be assigned a value of 1 if 'ch' == the channel number in this loop iteration 
        ch_idx = StS.chan(:,1)==ch;
        % calculate the mean rectified EMG signal for all channels
        all_evoked_EMGs = abs(StS.data(ch_idx,:));
        baseline_mean = mean(all_evoked_EMGs(:,1:stim_onset),2);
        
        % calculate the mean UN RECTIFIED EMG signal for all channels
        all_UNRECT_evoked_EMGs = StS.data(ch_idx,:);
        baseline_UNRECT_mean = mean(all_UNRECT_evoked_EMGs(:,1:stim_onset),2);
        
        if ch == muscle_of_interest && ~auto
            
            [valid_stims] = PAS_validate_EMG_responses2(all_evoked_EMGs, time_axis, baseline_mean, valid_stims, muscle_of_interest, tdt_struct); 
            
            % Construct a questdlg with three options
            choice = questdlg('Keep the same trial selections for UNRECTIFIED EMGs?', ...
                'Keep or Restart', ...
                'KEEP THE SAME','START FRESH','KEEP THE SAME');
            
            switch choice
                case 'KEEP THE SAME'
                    valid_UNRECT_stims = valid_stims;
                    sprintf('Trial validation applied to rectified EMGs now applied to unrectified data!')
                case 'START FRESH'
                    sprintf('Now starting independent trial validation for unrectified EMGs...')
                    [valid_UNRECT_stims] = PAS_validate_EMG_responses2(all_UNRECT_evoked_EMGs, time_axis, baseline_mean, valid_stims, muscle_of_interest, tdt_struct); 
                    sprintf('Independent Trial Validation has been applied to unrectified data!')
            end
            
        end
        
        % REMOVE BASELINE on ALL TRIALS PRIOR TO FILTERING BASED ON
        % VALIDATION
        if rem_baseline_flag
            all_evoked_EMGs = rem_baseline(stim_onset,all_evoked_EMGs);
            all_UNRECT_evoked_EMGs = rem_baseline(stim_onset,all_UNRECT_evoked_EMGs); 
        end
        
        if counter % TODO: run for every muscle
            % RECORD of UNFILTERED TRIALS DATA
            uncollapsed_unfiltered_rect_EMGs = all_evoked_EMGs;
            uncollapsed_unfiltered_UNRECT_EMGs = all_UNRECT_evoked_EMGs;
            counter = 2;
        end
        
        % FILTER TRIALS BASED ON VALIDATION % TODO: change term filtered TO VALIDATED
        uncollapsed_filtered_rect_EMGs   = all_evoked_EMGs(valid_stims,:);
        uncollapsed_filtered_UNRECT_EMGs = all_UNRECT_evoked_EMGs(valid_UNRECT_stims,:);
        
        % COLLAPSE ACROSS TRIALS BY CALCULATING SDs, used to plot error
        % bars in bar graphs % TODO: removed collapsed/uncollapsed every
        sd_collapsed_rect_EMGs(:,ch)     = std(uncollapsed_filtered_rect_EMGs,0,1)';
        sd_collapsed_UNRECT_EMGs(:,ch)   = std(uncollapsed_filtered_UNRECT_EMGs,0,1)';

        % COLLAPSE ACROSS TIME BY CALCULATING THE MEANS across
        % analyzetimeframe, used to do stats and plot bar graphs
        evoked_collapsed_EMGs(valid_stims,ch)        = mean(uncollapsed_filtered_rect_EMGs(:,analyzetimeframe),2);
        evoked_collapsed_UNRECT_EMGs(valid_stims,ch) = mean(uncollapsed_filtered_UNRECT_EMGs(:,analyzetimeframe),2);

        % COLLAPSE ACROSS TRIALS BY CALCULATING THE MEANS across trials,
        % used to plot EMG traces
        mean_collapsed_EMGs(:,ch)        = mean(uncollapsed_filtered_rect_EMGs,1);
        mean_collapsed_UNRECT_EMGs(:,ch) = mean(uncollapsed_filtered_UNRECT_EMGs,1);

        trialstarttime = tdt_struct.info.starttime;

    end
    
    evoked_collapsed_EMGs = evoked_collapsed_EMGs(valid_stims,:);
    evoked_collapsed_UNRECT_EMGs = evoked_collapsed_UNRECT_EMGs(valid_UNRECT_stims,:);
        
    % OUTPUT FINAL SUMMARY DATA STRUCTURE
    
    processed_data = struct( 'uncollapsed_unfiltered_rect_EMGs', uncollapsed_unfiltered_rect_EMGs,...
                             'uncollapsed_unfiltered_UNRECT_EMGs', uncollapsed_unfiltered_UNRECT_EMGs,...
                             'uncollapsed_filtered_rect_EMGs', uncollapsed_filtered_rect_EMGs,...
                             'uncollapsed_filtered_UNRECT_EMGs', uncollapsed_filtered_UNRECT_EMGs,...
                             'sd_collapsed_rect_EMGs', sd_collapsed_rect_EMGs,...
                             'sd_collapsed_UNRECT_EMGs', sd_collapsed_UNRECT_EMGs,...
                             'evoked_collapsed_EMGs', evoked_collapsed_EMGs,...
                             'evoked_collapsed_UNRECT_EMGs', evoked_collapsed_UNRECT_EMGs,...
                             'mean_collapsed_EMGs', mean_collapsed_EMGs,...
                             'mean_collapsed_UNRECT_EMGs', mean_collapsed_UNRECT_EMGs,...
                             'baseline_mean',    baseline_mean,...
                             'baseline_UNRECT_mean', baseline_UNRECT_mean, ...
                             'time_axis',        time_axis,...
                             'blockname',        blockname,...
                             'trialstarttime',   trialstarttime,...
                             'num_chan',         num_chan,...
                             'analyzetimeframe', analyzetimeframe);                  

end


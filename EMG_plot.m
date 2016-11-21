% INPUT: PRE_tdtstructure, POST_tdtstructure
% OUTPUT: (plot with EMG values averaged across all trials, pre and post overlaid) 

function [ ] = EMG_plot (PRE_tdtstructure, POST_tdtstructure)

    StS_names = fieldnames(PRE_tdtstructure.snips);
    % assign the variable StS_names to field names extracted from the snip
    % segments in the TDT data. 

    StS_pre = getfield(PRE_tdtstructure.snips,StS_names{1});
    StS_post = getfield(POST_tdtstructure.snips,StS_names{1});
    % obtain field names from the TDT dataset
    
    chan_list     = unique(StS_pre.chan); % assign to var 'chan_list' the unique order of channels in the recorded data
    num_chan      = length(chan_list); % determine the number of unique channnels and assign to var 'num_chan'
    num_data_pts  = size(StS_pre.data,2); % determine the number of data points in the data point by obtaining the size of row STS-data in the second column

    mean_rect_EMGs_pre = nan(num_data_pts,num_chan); % create an array called 'mean_rect_EMGs_pre' which is the size num_data_pts x num_chan 
    mean_rect_EMGs_post = nan(num_data_pts,num_chan); % create an array called 'mean_rect_EMGs_post' which is the size num_data_pts x num_chan

    for ch = 1:num_chan % start for loop for channel 1 to the total number of channels:
    ch_idx = StS_pre.chan(:,1)==ch; % channel ID will be assigned a value of 1 if 'ch' == the channel number in this loop iteration 
    %mean_rect_EMGs(:,ch) = mean(abs(StS.data(ch_idx,:)),1)'; % this was
    %commented out, but it is the same as the line below, except that the
    %absolute value of all trials was calculated before the mean was taken.
    mean_rect_EMGs_pre(:,ch) = abs(mean(StS_pre.data(ch_idx,:),1))'; % calculate the mean rectified EMG signal for all channels, by taking 
    mean_rect_EMGs_post(:,ch) = abs(mean(StS_pre.data(ch_idx,:),1))'; % calculate the mean rectified EMG signal for all channels, by taking 
    end % end for loop

    epoc_names =  fieldnames(PRE_tdtstructure.epocs); % get epoch names from the epocs section from the TDT structure
    stim_field = strcmpi(epoc_names,'stim'); % compare 'epoc_names' and 'stim' to see if the strings are identical, and store the result [1] if they are the same and [0] if they are different in the variable 'stim_field'
    stim_epoc  = getfield(PRE_tdtstructure.epocs,epoc_names{stim_field});
    stim_onset1= stim_epoc.onset(1,1);
    % assign 'stim_onset1' to the onset time of the epoch
    time_bin  = 1/PRE_tdtstructure.streams.EMGs.fs; 
    % calculate the required time bin duration by taking 
    % the inverse of the sampling frequency, and store it in the variable
    % 'time_bin'
    pre_stim_t= StS_pre.ts(1,1)-stim_onset1;

    time_axis = pre_stim_t:time_bin:(pre_stim_t+(num_data_pts*time_bin)-time_bin); 
    % calculate and calibrate the x axis to time in seconds, by creating a
    % vector containing numbers from 'pre_stim_t' to
    % '(pre_stim_t+(num_data_pts*time_bin)-time_bin)', with equally spaced
    % intervals of 'time_bin'. 
    % The endpoint of the vector was calculated by taking the number of data
    % points, multiplying it by 'time_bin', adding it to the first data point,
    % and subtracting from 'time_bin'. But why the last part??


    ymax = max(max(mean_rect_EMGs_pre)); % the maximum y value will equal the maximum of the maximum of mean_rect_EMGs across all channels
    for ch=1:num_chan % for loop, from channel 1 to the total number of channels
    figure; % a figure is desired, initiate base plot
    plot(time_axis,mean_rect_EMGs_pre(:,ch)); % make a plot of pre EMG data, with time_axis on the abscissa and mean_rect_EMGs_pre on the ordinate
    hold on % hold the plot so that the post data can be overlaid on top
    plot(time_axis,mean_rect_EMGs_post(:,ch)); % make a plot of the post EMG data, with time_axis on the abscissa and mean_rec_EMGs_post on the ordinate
    % vector on the abscissa, and the 'mean_rect_EMGs' vector on the
    % ordinate, with the additional stipulation that all rows should be
    % included in the column denoted by the channel selected in the
    % current iteration of the for loop
    ylim([-ymax/10 ymax]);
    % set the limit of the y-axis to be bounded between the negative of
    % the ymax variable divided by 10, and ymax. 
    xlabel('time (s)'); ylabel('mean rect EMG (uV?)');
    % label the x axis to be time in seconds, and the y label to be
    % mean rectified EMG signal in uV
    title(strrep(sprintf('mean rect EMG ch %d, file %s',ch,PRE_tdtstructure.info.blockname),'_','\_'));
    % plot the title of the graph as 'mean rect EMG channel number file
    % name block name and two spaces. 
    end % end channel for loop

end

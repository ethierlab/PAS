% Script to perform pre-post inferential statistics of TDT
% 4-channel EMG data (snips, paired t test)
% (C) 2017 Feb; C Ethier, W Ting
% For additional assistance consult the individual function headers
function result_struct = MASTER_pre_post(pre_data, post_data)
%% Part I: Run Once Every Time there is  New Analysis

    % Import TDT Data from User Specified Directory and Place in a TDT Structure
    %[matdata, num_data_files, save_path] = TDT_import(  );
 
%% Part II: Run Every Time an Analysis is Needed

    % Allows the user to specify desired initial parameters
    [ userlower, userupper, EMG_vect, rem_baseline_flag, analyzestimdur, analyzeallflag ] = PAS_initparams( );
    
    % Allows the user the specify the channel numbers via a text config
    % file.
    % [ chspec ] = PAS_chspec();

    % Proprocesses the data and removes baseline signal if flagged.
    [ mean_rect_EMGs_pre, sd_rect_EMGs_pre, time_axis, evoked_EMGs_pre, blockname_pre, num_chan ]       = TDT_preproc ( pre_data, rem_baseline_flag, userlower, userupper, analyzestimdur);
    [ mean_rect_EMGs_post, sd_rect_EMGs_post , time_axis, evoked_EMGs_post, blockname_post, num_chan ]  = TDT_preproc ( post_data, rem_baseline_flag, userlower, userupper, analyzestimdur);

    % Completes Two-Tailed T Test
    [ ttestresults ] = PAS_ttest ( evoked_EMGs_pre, evoked_EMGs_post );

    % Summarizes data in terms of means and standard error of the means
    [ EMG_prevalues_meanSEM , EMG_postvalues_meanSEM ] = PAS_datasummary ( evoked_EMGs_pre, evoked_EMGs_post );

    % Plot bar graph 
    PAS_bar ( EMG_prevalues_meanSEM, EMG_postvalues_meanSEM, rem_baseline_flag, blockname_pre, blockname_post, num_chan );

    % Create a summary results table
    % [ PASTable ] = PAS_resultstable ( ttestresults, EMG_prevalues_meanSEM, EMG_postvalues_meanSEM );
  
    % Plot EMG values on time axis for each channel
    EMG_plot ( mean_rect_EMGs_pre, sd_rect_EMGs_pre, mean_rect_EMGs_post, sd_rect_EMGs_post, time_axis, blockname_pre, blockname_post, EMG_vect );

    %     Save analysis workspace as PASanalysis.mat in the working directory
    %     save('PASanalysis.mat');

    result_struct = struct('ttest_results',ttestresults,...
                           'mean_EMG_pre', mean_rect_EMGs_pre,...
                           'sd_EMG_pre',sd_rect_EMGs_pre,...
                           'mean_EMG_post',mean_rect_EMGs_post,...
                           'sd_EMG_post',sd_rect_EMGs_post,...
                           'time_axis',time_axis,...
                           'block_name_pre',blockname_pre,...
                           'block_name_post',blockname_post);
                       
end
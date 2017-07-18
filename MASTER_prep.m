%% MASTER_analysis
% Examples of function calls to analyze data.

%% Section 1: Data Preparation
% Import the data
[ save_path, num_data_files, tdt_struct ] = TDT_import();

% Obtain initial parameters from user
[ userlower, userupper, EMG_vect, rem_baseline_flag, analyzestimdur, analyzeallflag ] = PAS_initparams( );

% Run for custom pre-capture and post-capture time extracted from streams
tdt_struct.snips.StS1 = snipper(tdt_struct, startsec, endsec);

% Generate structure with summary results
name_LRparam = TDT_preproc(tdt_struct, rem_baseline_flag, userlower, userupper, analyzestimdur, EMG_vect, 1);

% Experimental designs with unilateral data collection can be combined as such
agg = [pre1sp, pre2sp, post1sp, post2sp, post3sp];

% Experiments with bilateral data collection, total sessions > 2 should be combined as such
Lagg = [BL_L1, inter_L2, inter_L3, inter_L4, inter_L5, inter_L6, inter_L7, inter_L8, PostPAS_L9, ProbeL10, ProbeL11, ProbeL12, ProbeL13, ProbeL14];
Ragg = [BL_R1, inter_R2, inter_R3, inter_R4, inter_R5, inter_R6, inter_R7, inter_R8, PostPAS_R9, ProbeR10, ProbeR11, ProbeR12, ProbeR13, ProbeR14];

% Experiments with bilateral data collection, total sessions = 2 should be combined as such
Laggprepost110 = [BL_L110, PostPAS_L110];
Raggprepost110 = [BL_R110, PostPAS_R110];


%% Section 2: Plotting

Laggprepost110 = [BL_L110, PostPAS_L110];
Raggprepost110 = [BL_R110, PostPAS_R110];

[ superaggregate, max_matrix ] = maximizer ( Lagg, Ragg );

% For generating the EMG plots, use separately
[ superaggregatetemp, max_matrix ] = maximizer ( Laggprepost100, Raggprepost100 ); 

% For performing the statistics, combine all. 
[ superaggregate ] = [Laggprepost090, Raggprepost090, Laggprepost100, Raggprepost100, Laggprepost110, Raggprepost110 ];

[ maxtempmatrix, max_matrix ] = maximizer_unilateral ( agg );

EMG_plot ( superaggregate, 1, ['auto'], 0, 0, 11, 12); 

EMG_plot ( agg, 1, [-0.1e-3 1.0e-4], 0); 

EMG_plot ( superaggregate, 3, [-0.1e-3 1.4135e-4], 0); % For Ch3 Threshold % maybe use varargin for specifying max matrix 

EMG_plot ( agg, 3, [-0.1e-3 0.0809], 0); % for unilaterial Ch3 Threshold

PAS_bar ( rem_baseline_flag, EMG_vect, agg );

PAS_bar ( rem_baseline_flag, Laggprepost090 ); 
PAS_bar ( rem_baseline_flag, Raggprepost ); 

PAS_bar ( rem_baseline_flag, Lagg );
PAS_bar ( rem_baseline_flag, Ragg );

% aggregated_data = cat(3, pre1.evoked_EMGs,pre2.evoked_EMGs,post1.evoked_EMGs,post2.evoked_EMGs,post3.evoked_EMGs);

% EMG_plot ( aggregated_data, EMG_vect, num_sess );
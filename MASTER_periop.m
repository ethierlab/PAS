% //MASTER_periop
% //This script is an automated workflow to process data from 
%  imported TDT_data to data figures
%  For post-operative analyses use MASTER_postop permitting fine-tuned
%  modifications of individual functions to suit needs

save_path = uigetdir('Where are the MAT files?');
cd(save_path)
% Load Init Params
disp('Loading Initial Parameters...')
load initparams.mat

% Extract filenames and create empty array structures
% [ mat_filenames ] = extractor( save_path );
mat_files = dir([save_path filesep '*.mat']);
num_target_structures = size(mat_files, 1);
MasterDataset = cell(num_target_structures,2);
% Lagg = [];
% Ragg = [];

% Processing TDT Structures
disp('Processing TDT Structures...')
for n = 1:num_target_structures
    
    loaded_file = load(mat_files(n).name);
    
    % TO DO: PRESENT A LIST OF SESSIONS TO THE USER AND ASK HIM TO SELECT
    % THE ONES CORRESPONDING TO LEFT CORTEX STIMULATION
    current_structure = load(mat_files(n).name);
    
    % tdt_struct = getfield(loaded_file, current_structure);
    tdt_struct = getfield(current_structure, mat_files(n).name(1:end-4));
    
    MasterDataset{n,1} = tdt_struct.info.blockname;
    MasterDataset{n,2} = TDT_preproc ( tdt_struct, auto, rem_baseline_flag, userlower, userupper, analyzestimdur, EMG_vect, 1);

end

% Cleanup
disp('Cleaning Up...')
clear analyzeallflag; 
clear analyzestimdur;
clear auto;
clear current_structure;
clear loaded_file;
clear mat_files;
clear n;
clear num_target_structures;
clear rem_baseline_flag;
clear save_path;
clear tdt_struct;
clear userlower;
clear userupper;
clear EMG_vect;

% Save data structure
disp('Saving Backup...')
save('backup.mat')

% mat_filenames = MasterDataset(:,1);
% [ Laggarray, Raggarray ] = filesort( mat_filenames );
% L_num_files = size(Laggarray,1);
% R_num_files = size(Raggarray,1);

% Populate TDT Structures in Left and Right Data Containers
% for i=1:size(Laggarray,1)
%     struct_of_interest = Laggarray(i,1);
%     index_soi = str2double(Laggarray(i,2));
%     Lagg=[Lagg, A{index_soi,2}];
% end

% index_soi = str2double(Laggarray(:,2));
% Lagg= MasterDataset{index_soi,2};
% 
% for i=1:size(Raggarray,1)
%     struct_of_interest = Raggarray(i,1);
%     index_soi = str2double(Raggarray(i,2));
%     Ragg=[Ragg, MasterDataset{index_soi,2}];
% end

% Plot bar graphs
% disp('Plotting Bar Graphs...')

% PAS_bar ( rem_baseline_flag, EMG_vect, Lagg );
% PAS_bar ( rem_baseline_flag, EMG_vect, Ragg );

% Template do not delete
% for i=1:numel(Laggarray)   
%     Lagg=[Lagg,eval(Laggarray{i})];
% end

% clear tdt_struct;

% Generate superaggregate and determine absolute maxima and minima
% superaggregate = [Lagg Ragg];
% [ abs_max, abs_min, mintempmatrix, maxtempmatrix ] = maximizer ( superaggregate, varargin );
% 
% % Plot Autoscaled EMGs for Response Shape
% disp('Plotting EMGs...')
% EMG_plot ( 1, superaggregate, EMG_vect, 'auto', 'auto', 'auto', 0, 0, 0, 0, 0 );
% 
% % Plot Syncscaled EMGs for Absolute Response Amplitude 
% EMG_plot ( 1, superaggregate, EMG_vect, 'auto', 'auto', [abs_min;abs_max], 0, 0, 0, 0, 0 );

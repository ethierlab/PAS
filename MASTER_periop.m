%% MASTER_periop
%% This script is an automated workflow to process data from 
%  raw TDT_data to data figures, for use during experiments only.
%  For post-operative analyses use MASTER_postop permitting fine-tuned
%  modifications of individual functions to suit needs

% Import Data
disp('Importing Data...')
[ save_path, num_data_files, tdt_struct ] = TDT_import();

% Load Init Params
disp('Loading Initial Parameters...')
load initparams.mat

% Extract filenames and create empty array structures
[ mat_filenames ] = extractor( save_path );
cd(save_path);
num_target_structures = size(mat_filenames, 1);
A = cell(num_target_structures,2);
Lagg = [];
Ragg = [];

% Processing TDT Structures
disp('Processing TDT Structures...')
for n = 1:num_target_structures

    clear('tdt_struct');
    current_file = mat_filenames(n);
    current_file = char(current_file);
    hotpotato = load(current_file);
    
    current_structure = current_file(1:end-4);
    
    tdt_struct = getfield(hotpotato, current_structure);
    
    A{n,1} = tdt_struct.info.blockname;
    A{n,2} = TDT_preproc ( tdt_struct, auto, rem_baseline_flag, userlower, userupper, analyzestimdur, EMG_vect, 1);
end

mat_filenames = A(:,1);
[ Laggarray, Raggarray ] = filesort( mat_filenames );
L_num_files = size(Laggarray,1);
R_num_files = size(Raggarray,1);

% Populate TDT Structures in Left and Right Data Containers
for i=1:size(Laggarray,1)
    struct_of_interest = Laggarray(i,1);
    index_soi = str2double(Laggarray(i,2));
    Lagg=[Lagg, A{index_soi,2}];
end

for i=1:size(Raggarray,1)
    struct_of_interest = Raggarray(i,1);
    index_soi = str2double(Raggarray(i,2));
    Ragg=[Ragg, A{index_soi,2}];
end

% Plot bar graphs
disp('Plotting Bar Graphs...')
EMG_vect = [1,2];

PAS_bar ( rem_baseline_flag, EMG_vect, Lagg );
PAS_bar ( rem_baseline_flag, EMG_vect, Ragg );

% Template do not delete
% for i=1:numel(Laggarray)   
%     Lagg=[Lagg,eval(Laggarray{i})];
% end

clear tdt_struct;

% Generate superaggregate and determine absolute maxima and minima
superaggregate = [Lagg Ragg];
[ abs_max, abs_min ] = maximizer ( superaggregate );
% 
% % Plot Autoscaled EMGs for Response Shape
% disp('Plotting EMGs...')
% EMG_plot ( 1, superaggregate, EMG_vect, 'auto', 'auto', 'auto', 0, 0, 0, 0, 0 );
% 
% % Plot Syncscaled EMGs for Absolute Response Amplitude 
% EMG_plot ( 1, superaggregate, EMG_vect, 'auto', 'auto', [abs_min;abs_max], 0, 0, 0, 0, 0 );

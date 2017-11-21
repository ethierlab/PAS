function [ MEP_vect, data_dir ] = MEP_stimresp_curve(  )
    % MEP_analysis: Takes raw MEP data and plots a stimulus-response curve from the data 
    prompt = {'Enter MEP Stimulation Intensity Vector:'};
    dlg_title = 'Experimental Params';
    num_lines = 1;
    
    params = inputdlg(prompt,dlg_title,num_lines);
    MEP_vect = str2num(params{1});

    folderpath = uigetdir('','Directory where the Processed MEP Data is stored');
    data_dir = dir(folderpath);
    
    cd(data_dir)
    
    [ mep_filenames ] = extractor( data_dir ); 
    
    num_target_structures = size(mat_filenames, 1);
    
    disp('Processing MEP Structures...')

    A{};
    
    for n = 1:num_target_structures

        clear('tdt_struct');
        current_file = mat_filenames(n);
        current_file = char(current_file);
        hotpotato = load(current_file);

        current_structure = current_file(1:end-4);

        mep_struct = getfield(hotpotato, current_structure);

        A{n,1} = mep_struct.info.blockname;
        A{n,2} = TDT_preproc ( mep_struct, auto, rem_baseline_flag, userlower, userupper, analyzestimdur, EMG_vect, 1);
        
    end
    
end
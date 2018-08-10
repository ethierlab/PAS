function PAS_plot_bar(MEPs,mep_idx,emg_vec,bar_data_select)
% usage: PAS_plot_bar(meanMEPs,mep_idx,emg_vec)
%
%  This function, meant to be called from PAS_analyzer.m, plots a bar graph of mean MEPs with 2*SEM error bars
%  The whole meanMEPs structure from PAS_analyzer has to be provided, along with a 'mep_idx' vector of blocks
%  and a 'emg_vec' vector of emg chanels to include in the plot
%
%   inputs:
%       MEPs = struct(...
%                   'Blocknames'    : string of block names (file names)
%                   'chan_list'     : array with emg channel numbers (same as EMG_vec)
%                   'p2p'           : structure containing individual measures of peak-to-peak amplitude over time window
%                   'int'           : structure containing individual measures of integral of EMG over time window
%                   'base_mean'     : mean of the rectified EMG prior to stimulation
%                   'N'             : number of MEPs that were averaged
%           (see calc_mean_MEPs.m)
%
%      mep_idx       : which blocks to include in bar plot
%      emg_vec       : which emgs to plot
%      bar_data_select: {'p2p', 'integral' or 'int_ave'} string to select which MEP measure to use in bar plot
%
%
%%%% Ethierlab 2018/05 -- CE % updated: 2018/07 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


blocknames = MEPs.Blocknames(mep_idx,:);

if isempty(emg_vec)
    emg_vec = MEPs.chan_list;
end
num_emgs = length(emg_vec);

for e = 1:num_emgs
    figure;
    e_idx = MEPs.chan_list==emg_vec(e);
    
    switch bar_data_select
        case 'p2p'
            mMEPs   = MEPs.p2p.mean(mep_idx,e_idx);
            seMEPs = MEPs.p2p.sd(mep_idx,e_idx)./sqrt(MEPs.N(mep_idx));
        case 'integral'
            
            mMEPs   = MEPs.integral.mean(mep_idx,e_idx);
            seMEPs = MEPs.integral.sd(mep_idx,e_idx)./sqrt(MEPs.N(mep_idx));
        case 'int_ave'
            mMEPs = MEPs.integral_ave(mep_idx,e_idx);
            seMEPs = zeros(size(mMEPs));
    end
    
    barwitherr(seMEPs,mMEPs);
    
    set(gca,'XTick', 1:length(mMEPs));
    set(gca,'XTickLabel',strrep(blocknames,'_','\_'));
    set(gca,'XTickLabelRotation',45);
    
    pretty_fig;
    
    switch bar_data_select
        case 'p2p'
            units = '(mV)';
            leg1  = 'p2p MEP';
        case 'integral'
            units = '(mV*ms)';
            leg1  = 'MEP Integral';
        case 'int_ave'
            units = '(mV*ms)';
            leg1  = 'ave MEP Integral';
    end
    
    ylabel([' Mean MEPs' units]);
    title(strrep(sprintf('MEPs for Ch %d',emg_vec(e)),'_','\_'));
    legend({leg1,'SEM'});
    
end



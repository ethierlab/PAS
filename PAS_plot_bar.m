function PAS_plot_bar(meanMEPs,mep_idx,emg_vec)
% usage: PAS_plot_bar(meanMEPs,mep_idx,emg_vec)
%
%  This function, meant to be called from PAS_analyzer.m, plots a bar graph of mean MEPs with 2*SEM error bars
%  The whole meanMEPs structure from PAS_analyzer has to be provided, along with a 'mep_idx' vector of blocks
%  and a 'emg_vec' vector of emg chanels to include in the plot
%
%   inputs:
%       meanMEPs = struct(...
%                   'Blocknames'    : string of block names (file names)
%                   'chan_list'     : array with emg channel numbers (same as EMG_vec)
%                   'MEPs'          : mean MEP measures over specified time window
%                   'sd'            : sd of mean MEPs over specified time window
%                   'N'             : number of MEPs that were averaged
%                   'median'        : wether or not the median was used instead of the mean for the calculation
%           (see calc_mean_MEPs.m)
%
%
%%%% Ethierlab 2018/05 -- CE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


blocknames = meanMEPs.Blocknames(mep_idx,:);

if isempty(emg_vec)
    emg_vec = meanMEPs.chan_list;
end
num_emgs = length(emg_vec);

for e = 1:num_emgs
    figure;
    e_idx = meanMEPs.chan_list==emg_vec(e);
    
    mMEPs = meanMEPs.MEPs(mep_idx,e_idx);
    seMEPs= meanMEPs.sd(mep_idx,e_idx)./sqrt(meanMEPs.N(mep_idx));

    barwitherr(seMEPs,mMEPs);
    
    set(gca,'XTickLabel',strrep(blocknames,'_','\_'));
    title(strrep(sprintf(''),'_','\_'));
    pretty_fig;
    
    xtickangle(45);
    
    if meanMEPs.median
        mode = 'median';
    else
        mode = 'mean';
    end
    if meanMEPs.integral
        units = '(mV*ms)';
        leg1  = 'MEP integral';
    else
        units = '(mV)';
        leg1  = 'p2p MEP';
    end
    
    ylabel([mode ' MEP ' units]);
    title(sprintf('Comparing MEPs for ch %d',emg_vec(e)));
    legend({leg1,'SEM'});
    
end



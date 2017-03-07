% FUNCTION: EMG_plot.m
% C Ethier, W Ting, Feb 2017
% Purpose: Plot figures with time of data point on the abscissa and
% EMG data (normed if applicable) on the ordinate, one channel per figure, and pre and post data overlaid on top of each other 
% INPUTS: PRE_tdtstructure, POST_tdtstructure, mean_norm_rect_EMGs, norm,
% lowerbound, upperbound
% OUTPUTS: [Figures: EMG plots]

function [ ] = EMG_plot ( aggregated_data, EMG_vect, num_sess ) % processed data is a three dimensional array generated by command line concatenation 

    num_chan = length(EMG_vect);
    
    for ch_idx=1:num_chan 
        figure; 
        
        ch = EMG_vect(ch_idx);
        
        for sess = 1:num_sess
            plot(aggregated_data(1).time_axis, aggregated_data(ch+(sess-1)*num_chan).mean_rect_EMGs(:,ch));
            hold on;
        end

        % ylim([-ymax/10 ymax]);
        legend('pre1','pre2','post1','post2','post3');
        
        % label the x axis to be time in seconds, and the y label to be
        % mean rectified EMG signal in V
        % Labels appropriately based on whether normed or non normed data is
        % used
        xlabel('time (s)'); ylabel('Mean Rectified EMG Signal (V)');     
        title(strrep(sprintf('Mean Rect EMG Ch %d',ch),'_','\_'));
        
        % Save Figures to File
        % set(gcf,'renderer','painters');
        % saveas(gcf, [blockname_pre blockname_post '_ch' num2str(ch) '_EMG.svg']);
        % savefig(gcf, [blockname_pre blockname_post '_ch' num2str(ch) '_EMG.fig']);

    end

end

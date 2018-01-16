% FUNCTION: EMG_plot.m
%
% GOAL: Visualize EMG data collected over a pair of sessions (pre-post) or
% over a series of sessions.
%
% USAGE:
%   EMG_plot ( panel, aggregatedData, emgVect, xLimit, xRange, yRange, unrectFlag, acuteFlag, acutePreIndex, acutePostIndex, save, varargin )
%
% USAGE EXAMPLES:
%   EMG_plot ( 1, Lagg, 2, 'auto', 'auto', [-0.5e-5 3e-5], 0, 0, 0, 0, 1 )
%   Plots all rectified EMGs from left side cortical stimulation,
%   Channel 2 in a paneled figure, with auto x-range but restricted y-range
%   from -0.5e-5 to 3e-5 Volts, and save the resulting images
%
%   EMG_plot ( 0, Ragg, 1, 'auto', 'auto', 'auto', 0, 1, 3, 4, 1 )
%   Plots all rectified EMGs from right side cortical stimulation, Channel
%   1 in separate figures, with auto x- and y-range. Only plot sessions 3
%   and 4 from aggregatedData, and save the resulting figures on disk
%
% PARAMETERS:
%   panel: if =1, plots EMGs for each session in a multi-panel figure,
%   sorted in alpha order by laterality; elsif =0, plots each figure
%   independently
%
%   aggregatedData: data structure as output by TDT_preproc.m and combined
%   (optional). Use as appropriate for analyzing EMGs from left cortical or
%   right cortical stimulation
%
%   emgVect: specify the EMG channels to plot
%
%   xLimit: if =1, EMG plots will obey the x-axis limits imposed by xrange
%
%   xRange: specify [x y] to limit the x-range of the EMG plot
%
%   yRange: specify [x y] to limit the y-range of the EMG plot - if 'auto'
%   is supplied MATLAB will decide the best fit for the data in each plot
%
%   unrectFlag: if =1, the unrectified data will be plotted for all. =0 for
%   rectified
%
%   acuteFlag: if =1, the two following parameters take into effect to
%   specify the two curves to plot in a pre-post overlaid fashion.. =0 to
%   plot all sessions
%
%   acutePreIndex: specify r indicating the index of the structure to be
%   plotted in blue
%
%   acutePostIndex: specify r indicating the index of the structure to be
%   plotted in red
%
%   save: if =1, will save vector and bitmap versions of resulting figures
%   in current directory, =0 for just viewing
%
%   varargin: enter in a variable number of arguments the desired sessions
%   to plot.
%
% OUTPUT: EMG plot .fig (optional raster format output)
%
% AUTHORS: C Ethier, W Ting 2017

function [ ] = EMG_plot ( aggregatedData, EMG_vect, panel, xLimit, xRange,...
    yRange, unrectFlag, acuteFlag, acutePreIndex, acutePostIndex, save, varargin )

    num_chan = length(EMG_vect);
    num_sess = length(aggregatedData);
    set(gcf,'renderer','painters');

    % Need to iterate over all channels so that EMG_vect can filter
    % depending on user preferences

    for ch_idx=1:num_chan
        ch = EMG_vect(ch_idx);

        % Plot two EMG curves, one on top of the other (pre-post)
        % This independent section simplifies plotting a specific
        % pre and post trace on top of one another, because the rest of the
        % function deals with all sessions at the same time.

        %%
        if acuteFlag == 1

            plot(aggregatedData(1).time_axis, ...
                aggregatedData(acutePreIndex).mean_collapsed_EMGs(:,ch),'b');
            hold on;
            plot(aggregatedData(1).time_axis, ...
                aggregatedData(acutePostIndex).mean_collapsed_EMGs(:,ch),'r');
            hold off;

            xlabel('Time (s)'); ylabel('Mean Rectified EMG Signal (V)');

            if xLimit == 1
                xlim(xRange);
            end

            ylim(yRange);
            legend(aggregatedData(acutePreIndex).blockname, ...
                aggregatedData(acutePostIndex).blockname);
            title(strrep(sprintf('Mean Rect EMG Ch %d',ch),'_','\_'));

            if save == 1
                saveas(gcf, ['Ch' num2str(ch) '_'...
                    aggregatedData(acutePreIndex).blockname '_' ...
                    aggregatedData(acutePostIndex).blockname '_EMG.svg']);
                savefig(gcf, ['Ch' num2str(ch) '_' ...
                    aggregatedData(acutePreIndex).blockname '_' ...
                    aggregatedData(acutePostIndex).blockname '_EMG.fig']);
            end

            break;

        end
        %%

        % Plot all EMG curves. This has different options depending on the
        % parameters specified at runtime.

        if nargin > 11
            
            desired_sessions = cell2mat(varargin);
            
            for i = desired_sessions
                desired_data(i,1) = {aggregatedData{i,2}.mean_collapsed_EMGs};
            end
            
            [ abs_max, abs_min ] = maximizer ( desired_data, EMG_vect, desired_sessions );
            
        else
            
            desired_sessions = 1:num_sess;
            yrange = 'auto';
            
        end

        for sess = desired_sessions

            figure;

            % This subsection is for plotting unrectified data and saving
            % that instead

            if unrectFlag == 1

                plot(aggregatedData(sess).time_axis, ...
                    aggregatedData(sess).mean_collapsed_UNRECT_EMGs(:,ch));
                xlabel('Time (s)'); ylabel('Mean UNRECTIFIED EMG Signal (V)');
                ylim(yRange);
                legend(aggregatedData(sess).blockname);
                title(strrep(sprintf('Mean Rect EMG Ch %d',ch),'_','\_'));

                if save == 1
                    saveas(gcf, [aggregatedData(sess).blockname '_ch' ...
                        num2str(ch) '_UNRECT_EMG.svg']);
                    savefig(gcf, [aggregatedData(sess).blockname '_ch' ...
                        num2str(ch) '_UNRECT_EMG.fig']); % '_sess' num2str(sess)
                end

            % This subsection is for plotting rectified data in multi-panel
            % figure.

            elseif panel == 1

                % The next few lines are to format the dimensions of the
                % overall subplot more aesthetically

                total_plots         = num_sess;

                total_plots_factors = total_plots + 1;

                divisors = 1:(total_plots_factors);
                divisors = divisors(~(rem(total_plots_factors, divisors)));

                number_of_divisors          = size(divisors,2);
                subplot_dimensions_index_y  = number_of_divisors / 2;
                subplot_dimensions_index_x  = subplot_dimensions_index_y + 1;

                subplot_dimensions_y = divisors(subplot_dimensions_index_y);
                subplot_dimensions_x = divisors(subplot_dimensions_index_x);

                % There is iteration over the total number of sessions as
                % required for the subplotting function.

                for i = 1:total_plots
                    subplot(subplot_dimensions_y,subplot_dimensions_x,i);
                    plot(aggregatedData(i).time_axis, ...
                        aggregatedData(i).mean_collapsed_EMGs(:,ch));
                    xlabel('Time (s)'); ylabel('Mean Rectified EMG Signal (V)');
                    ylim(yRange);
                    legend(aggregatedData(i).blockname);
                    yrange_check = string(yRange);

                    % The y-axis labels change depending on the desired
                    % initial parameters

                    if yrange_check == 'auto'
                        title(strrep(sprintf('AUTOscaled Ch %d',ch),'_','\_'));
                    else
                        title(strrep(sprintf('SYNCscaled Ch %d',ch),'_','\_'));
                    end
                end

                % This break is here so that the subplot function doesn't run
                % more than once, and because we would have included all
                % the sessions already

                break;

            else

                plot(aggregatedData{sess, 2}.time_axis, aggregatedData{sess, 2}.mean_collapsed_EMGs(:,EMG_vect));
                xlabel('Time (s)'); ylabel('Mean Rectified EMG Signal (V)');
                ylim(yRange);

                if abs_min | abs_max
                    ylim([abs_min, abs_max]);
                else
                    ylim('auto');
                end

                legend(aggregatedData{sess, 2}.blockname);
                title(strrep(sprintf('Mean Rectified EMG Ch %d',ch),'_','\_'));

                if save == 1
                    saveas(gcf, [aggregatedData{sess, 2}.blockname ...
                        '_Ch' num2str(ch) '_EMG.svg']);
                    savefig(gcf, [aggregatedData{sess, 2}.blockname ...
                        '_Ch' num2str(ch) '_EMG.fig']);
                end

            end

        end

    end

end

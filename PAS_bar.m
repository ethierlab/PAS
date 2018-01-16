% FUNCTION: PAS_bar.m
% C Ethier, W Ting, 2017
% Purpose: Plot a summary bar graph with channel number (nested pre-post)
% on the abscissa and mean EMG values on the ordinate (normed data if
% applicable, error bars = +/- SEM
% INPUTS: EMG_prevalues_meanSEM, EMG_postvalues_meanSEM, norm
% OUTPUTS: [Figure: A bar graph]

function PAS_bar ( EMG_vect, aggregated_data, varargin )
    % Where varargin is a comma-delimited vector of desired sessions to
    % for PAS_bar to plot
    
    % Initiate figure base
    figure;
    num_sess = length(aggregated_data);
    num_emgs = aggregated_data{1,2}.num_chan;

    % mean_evoked_EMG = nan(num_sess,num_emgs);
    % sem_evoked_EMG = nan(num_sess,num_emgs);
    
    for s = 1:num_sess
        mean_evoked_EMG(s,:) = mean(aggregated_data{s,2}.evoked_collapsed_EMGs(:,EMG_vect));
        sem_evoked_EMG(s,:)  = 2*std(aggregated_data{s,2}.evoked_collapsed_EMGs(:,EMG_vect))/sqrt(size(aggregated_data{s,2}.evoked_collapsed_EMGs(:,EMG_vect),1));
    end

    desired_sessions = cell2mat(varargin);
    
    if nargin > 3 
        barwitherr(sem_evoked_EMG(cell2mat(varargin),:), mean_evoked_EMG(cell2mat(varargin),:));
    else
        barwitherr(sem_evoked_EMG, mean_evoked_EMG);
    end
    
    set(gca,'XTicklabel',{char(strrep({aggregated_data{desired_sessions,1}},'_','\_'))});
    
    % write appropriate title overlay depending on what is plotted.
    title(strrep(sprintf(''),'_','\_'));
    
%     if rem_baseline_flag == 1
%         xlabel('Session'); ylabel('Mean (baseline removed) Rectified EMG Response, 2SEM) (V)');
%     elseif rem_baseline_flag == 0
%         xlabel('Within Day Session'); ylabel('Mean Rectified EMG Response, 2SEM (V)');
%     end
% 
%     num_sesh = nargin - 1;
%     % Generate paired labels. 
%     x1 = nan(num_sesh,1);
%     for i = 1:num_sesh
%         x1(i,1) = i;
%     end
%     
%     hold on;
%     b = bar(mean_evoked_EMG,'FaceColor','w','LineWidth',0.5);
    % b{1}.FaceColor='w';
    
    % For ACUTE ANALYSIS DIFFERENT BAR COLORS
%       b = bar(y,'FaceColor','b','LineWidth',0.5);
%       b(1).FaceColor='b';
%       b(2).FaceColor='r';
    % // ACUTE ANALYSIS DIFFERENT BAR COLORS
%     
%     if nargin == 3
%         x1 = repmat(x1,1,2);
%     elseif nargin == 6
%         x1 = repmat(x1,1,6);
%     end
%     
%     %size(varargin{1},2);
%     
%     errorbarxoffset = 0.5;
%     hold on;

%     % plot bar graph with facecolor, edgecolor and linewidth params
%     bar(y,'EdgeColor',[0 0 0],'LineWidth',0.5);
%     hold on;
%     b = bar(y,'EdgeColor',[0 0 0],'LineWidth',0.5);
    
    % plot error bar overlays with SEMs
%     errorbar((x1(:,1)-errorbarxoffset),y(:,1), 2 * EMG_prevalues_meanSEM(2,:),'.');
%     errorbar((x1(:,2)+errorbarxoffset),y(:,2), 2 * EMG_postvalues_meanSEM(2,:),'.');
    
%     if nargin == 3 % THIS IS THE PRE-POST ACUTE PROTOCOL
%     % pair pre and post mean and SEM summary variables
%         errorbar((x1(:,1) -  0.335),y(:,1), [2*preSEM(1,1), 2*postSEM(1,1)]', '.');
%         errorbar((x1(:,1) -  0.20),y(:,2), [2*preSEM(1,2), 2*postSEM(1,2)]', '.');
%         errorbar((x1(:,1) -  0.065),y(:,3), [2*preSEM(1,3), 2*postSEM(1,3)]', '.');
%         errorbar((x1(:,1) +  0.065),y(:,4), [2*preSEM(1,4), 2*postSEM(1,4)]', '.');
%         errorbar((x1(:,1) +  0.20),y(:,5), [2*preSEM(1,5), 2*postSEM(1,5)]', '.');
%         errorbar((x1(:,1) +  0.335),y(:,6), [2*preSEM(1,6), 2*postSEM(1,6)]', '.');
%     elseif nargin == 6 % THIS IS THE CHRONIC PAS PROTOCOL
%         errorbar((x1(:,1) -  0.335),y(:,1), [2*pre1SEM(1,1), 2*pre2SEM(1,1), 2*post1SEM(1,1), 2*post2SEM(1,1), 2*post3SEM(1,1)]', '.');
%         errorbar((x1(:,1) -  0.20),y(:,2), [2*pre1SEM(1,2), 2*pre2SEM(1,2), 2*post1SEM(1,2), 2*post2SEM(1,2), 2*post3SEM(1,2)]', '.');
%         errorbar((x1(:,1) -  0.065),y(:,3), [2*pre1SEM(1,3), 2*pre2SEM(1,3), 2*post1SEM(1,3), 2*post2SEM(1,3), 2*post3SEM(1,3)]', '.');
%         errorbar((x1(:,1) +  0.065),y(:,4), [2*pre1SEM(1,4), 2*pre2SEM(1,4), 2*post1SEM(1,4), 2*post2SEM(1,4), 2*post3SEM(1,4)]', '.');
%         errorbar((x1(:,1) +  0.20),y(:,5), [2*pre1SEM(1,5), 2*pre2SEM(1,5), 2*post1SEM(1,5), 2*post2SEM(1,5), 2*post3SEM(1,5)]', '.');
%         errorbar((x1(:,1) +  0.335),y(:,6), [2*pre1SEM(1,6), 2*pre2SEM(1,6), 2*post1SEM(1,6), 2*post2SEM(1,6), 2*post3SEM(1,6)]', '.');
%     end

%     l = cell(1,2);
%     l{1}='Pre PAS'; l{2}='Post PAS';    
%     legend(b,l);
%      
%     SEMlabel = 'E. bars = +/-2.0 SEM';
%     dim = [.62 .5 .3 .3];
%     annotation('textbox',dim,'String',SEMlabel,'FitBoxToText','on');
         
    h = legend(string(EMG_vect));
    v = get(h,'title');
    set(v,'string','EMG Channel Number');
    
 % uncomment to save
        % savefig(gcf, [aggregated_data(1).blockname 'bar.fig']);
        % saveas(gcf, [aggregated_data(1).blockname 'bar.svg']);

end
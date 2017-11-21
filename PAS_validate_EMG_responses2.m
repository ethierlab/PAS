function [valid_stims] = PAS_validate_EMG_responses2(all_evoked_EMGs, time_axis, baseline_mean, valid_stims, muscle_of_interest, tdt_struct)
%Plots individual trials of EMG responses and presents a space for user to enter a vector, indicating which trial to take out

figure;

%trialvect = true([size(all_evoked_EMGs,1),ch]);
set(gcf,'renderer','painters');
%Calculate the baseline standard deviation from the 16 values of
%baseline_mean prior to stimulation. Stays the same regardless of
%whether baseline was removed or not.
% baseline_m2SD = mean(baseline_mean) + 2*(std(baseline_mean,0,1));
breakflag = 0;
med1sd= median(baseline_mean)+1*std(baseline_mean);
trialvect = baseline_mean < med1sd;

% autoflagvector = trialvect;
% manualvector = nan(size(trialvect));
% notevector = cell(size(trialvect));

trialvect = and(valid_stims,trialvect);

for tr = 1:size(all_evoked_EMGs,1)
    
    if trialvect(tr)
        plot(time_axis,all_evoked_EMGs(tr,:),'b');
    else    
        plot(time_axis,all_evoked_EMGs(tr,:),'r');
    end
    
    title(['stim number: ' num2str(tr)]);
    
    BLSD = (baseline_mean(tr)-median(baseline_mean))/std(baseline_mean);
    ChannelLabel = ['Ch ' sprintf('%d, %.2f SD',muscle_of_interest,BLSD)];
    % dim = [.62 .5 .3 .3];
    %annotation('textbox',dim,'String',ChannelLabel,'FitBoxToText','on');
    legend(ChannelLabel);
    
    % Construct a questdlg with three options
    choice = MFquestdlg( [0.4, 0.3], 'Would you like to keep this trial?', ...
        'Trial Validation', ...
        'KEEP','DISCARD','AUTO/Break','KEEP');
        
    switch choice
        case 'KEEP'
            selection = 'TRU';
            sprintf('Trial %d KEPT', tr)
%             manualvector(tr) = true;
%             if autoflagvector(tr) ~= manualvector(tr)
%                 warning('DEVIANT DETECTED')
%                 x = inputdlg('Indicate why you deviated from autoflag','Trial Notes', [1 50]);
%                 if isempty(x) == 1
%                     notevector(tr,ch) = cellstr('NA'); 
%                 elseif isempty(x) == 0
%                     notevector(tr,ch) = x;
%                 end
%             end
            trialvect(tr) = true;
            trialindex = sprintf('trial_%d',tr);
            
            saveas(gcf, [pwd '\supervisedlearning\block_' tdt_struct.info.blockname '_' trialindex '_selection_' selection '_EMG.png']);
            
        case 'DISCARD'
            selection = 'FAL';
            sprintf('Trial %d DISCARDED', tr)
%             manualvector(tr) = false;
%             if autoflagvector(tr,ch) ~= manualvector(tr)
%                 warning('DEVIANT DETECTED')
%                 x = inputdlg('Indicate why you deviated from autoflag','Trial Notes', [1 50]);
%                 if isempty(x) == 1
%                     notevector(tr,ch) = cellstr('NA');
%                 elseif isempty(x) == 0
%                     notevector(tr,ch) = x;
%                 end
%             end
            trialvect(tr) = false;
            
            trialindex = sprintf('trial_%d',tr)
            selection = selection
            saveas(gcf, [pwd '\supervisedlearning\block_' tdt_struct.info.blockname '_' trialindex '_selection_' selection '_EMG.png']);
            
        case 'AUTO/Break'
            breakflag = 1;
            break;
    end
    
    if breakflag == 1
        break;
    end
    
    %             prompt = {'Exclude this Trial?'};
    %             dlg_title = 'Trial Exclusion';
    %             num_lines = 1;
    %             defaultans = {''};
    %             params = inputdlg(prompt,dlg_title,num_lines,defaultans);
    %             excludethistrial = params{1};
    
end

warning('Trial Validation Applied!');
valid_stims = and(valid_stims,trialvect);


% trial_validation_summary = struct('autoflagvect',   autoflagvector, ...
%     'manualvect', manualvector, ...
%     'notevect', {notevector});

% all_evoked_EMGs = all_evoked_EMGs(trialvect,:);
end

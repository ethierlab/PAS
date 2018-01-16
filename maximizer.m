function [ abs_max, abs_min ] = maximizer ( superaggregate, EMG_vect, desired_sessions )
% MAXIMIZER This function performs vertical concatenation on left and
% right side aggregated data and extracts the maximum value in each set of
% EMG values. 

num_sess = size(superaggregate,1);

% num_sess_Lagg = size(Lagg, 2);
% num_sess_Ragg = size(Ragg, 2);
% num_chan_Lagg = size(Lagg(1).mean_collapsed_EMGs,2);
% num_chan_Ragg = size(Ragg(1).mean_collapsed_EMGs,2);
% 
% if num_sess_Lagg ~= num_sess_Ragg
%     warning('The number of sessions on the left side is not equal to that on the right!');
% elseif num_sess_Lagg == num_sess_Ragg
%     num_sess = 2*num_sess_Lagg;
% end
% 
% if num_chan_Lagg ~= num_chan_Ragg
%     warning('The number of channels on the left side is not equal to that on the right!');
% elseif num_chan_Lagg == num_chan_Ragg
%     num_chan = num_chan_Lagg;
% end

for sess = desired_sessions
    mintempmatrix(sess,:) = min(superaggregate{sess,1}(:,EMG_vect));
    maxtempmatrix(sess,:) = max(superaggregate{sess,1}(:,EMG_vect));
end

abs_max = max(maxtempmatrix);
abs_min = min(mintempmatrix);

end
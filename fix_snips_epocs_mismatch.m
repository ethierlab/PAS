function tdt_struct = fix_snips_epocs_mismatch(tdt_struct)
% this fixes mismatches between snips and epocs
% in order to work, there must be a field called tdt_struct.epocs.Stim
% there should also be only one snips field, whatever the name (e.g.tdt_struct.snips.Sts1)
% also, this function creates a "timeframe" vector in the snips structure, the time for each data bin relative to stim

epocs_ts     = unique(tdt_struct.epocs.Stim.onset);
snips_name   = fieldnames(tdt_struct.snips);
snips_ts     = unique(tdt_struct.snips.(snips_name{1}).ts);

num_ep    = length(epocs_ts);
num_sn    = length(snips_ts);
num_ch    = length(unique(tdt_struct.snips.(snips_name{1}).chan));
man_fix   = false;
snips_i   = 1:num_sn;
epocs_i   = 1:num_ep;
fix_flag  = false;

if num_ep ~= num_sn
    warning('snip-epocs mismatch for block %s detected',tdt_struct.info.blockname);
    fix_flag = true;
    
    max_l = max(num_ep,num_sn);
    sn_ep = nan(max_l,3);
    
    sn_ep(:,1)        = 1:max_l;
    sn_ep(1:num_sn,2) = snips_ts;
    sn_ep(1:num_ep,3) = epocs_ts;
    
    %display original snips and epocs
    disp('original data:');
    fprintf('\tnum\tsnips\tepocs\n');
    disp(sn_ep);
    
    %try to find the problem
    if num_sn > num_ep
        %there are more snips
        %align snips-epocs to minimize difference
        num_extra_s = num_sn-num_ep;
        m_diff = nan(1,num_extra_s);
        for i=0:num_extra_s
            m_diff(i+1) = mean(abs(epocs_ts-snips_ts(1+i:end-num_extra_s+i)));
        end
        best_match = find(m_diff == min(m_diff));
        snips_i    = best_match:best_match+num_ep-1;
    else
        %there are more epocs
        %align snips-epocs to minimize difference
        num_extra_e = num_ep-num_sn;
        m_diff = zeros(1,num_extra_e);
        for i=0:num_extra_e
            m_diff(i+1) = mean(abs(epocs_ts(1+i:end-num_extra_e+i)-snips_ts));
        end
        best_match = find(m_diff == min(m_diff));
        epocs_i    = best_match:best_match+num_sn-1;
    end
    
    num_sn_ep = length(epocs_i);
    new_sn_ep = [ (1:num_sn_ep)' snips_ts(snips_i) epocs_ts(epocs_i)];
    
    %display tentatively aligned snips and epocs
    disp('Auto-fixing...');
    fprintf('\tnum\tsnips\tepocs\n');
    disp(new_sn_ep);
    
    reply = input('Does that look right? Y/N [Y]:','s');
    if isempty(reply)
        reply = 'Y';
    end
    
    switch upper(reply)
        case 'Y'
            disp('Awesome!');
        otherwise
            disp('Darn... you fix it then!')
            man_fix = true;
    end
    
elseif any( (epocs_ts-snips_ts)>1)
    warning('long snip-epocs intervals detected in block %s ',tdt_struct.info.blockname);
    fix_flag = true;
    
    sn_ep = [ (1:num_ep)' snips_ts epocs_ts];
    
    %display original snips and epocs
    disp('original data:');
    fprintf('\tnum\tsnips\tepocs\n');
    disp(sn_ep);
    
    reply = input('Does that look right? Y/N [Y]:','s');
    if isempty(reply)
        reply = 'Y';
    end
    
    switch upper(reply)
        case 'Y'
            disp('Ok then!');
        otherwise
            disp('Darn... we should fix it then!')
            man_fix = true;
    end
end

%manual fix
while man_fix
    disp('---');
    disp('original data:');
    fprintf('\tnum\tsnips\tepocs\n');
    disp(sn_ep);
    
    snips_i = input(sprintf('Which snips do you want to keep? [1:%d] :',num_sn));
    if isempty(snips_i)
        snips_i = 1:num_sn;
    end
    epocs_i = input(sprintf('Which epocs do you want to keep? [1:%d] :',num_ep));
    if isempty(epocs_i)
        epocs_i = 1:num_ep;
    end
    if length(epocs_i)~=length(snips_i)
        disp('Hey, pay attention! There should be the same number of snips and epocs!');
        disp('start over');
    else
        num_sn_ep = length(epocs_i);
        new_sn_ep = [ (1:num_sn_ep)' snips_ts(snips_i) epocs_ts(epocs_i)];
        
        %display aligned snips and epocs
        disp('Manual-fixing...');
        fprintf('\tnum\tsnips\tepocs\n');
        disp(new_sn_ep);
        
        reply = input('Now does that look right? Y/N [Y]:','s');
        if isempty(reply)
            reply = 'Y';
        end
        
        switch upper(reply)
            case 'Y'
                disp('Awesome!');
                man_fix = false;
            otherwise
                disp('Darn... try again!')
        end
    end
    
end

if fix_flag
    % overwrite good snips
    valid_sn = false(1,num_sn);
    valid_sn(snips_i) = true;
    valid_sn = reshape(repmat(valid_sn,num_ch,1),[],1);
    
    tdt_struct.snips.(snips_name{1}).ts       = tdt_struct.snips.(snips_name{1}).ts(valid_sn,:);
    tdt_struct.snips.(snips_name{1}).data     = tdt_struct.snips.(snips_name{1}).data(valid_sn,:);
    tdt_struct.snips.(snips_name{1}).chan     = tdt_struct.snips.(snips_name{1}).chan(valid_sn,:);
    tdt_struct.snips.(snips_name{1}).sortcode = tdt_struct.snips.(snips_name{1}).sortcode(valid_sn,:);
    
    %overwrite good epocs
    valid_ep = false(1,num_ep);
    valid_ep(epocs_i) = true;
    
    tdt_struct.epocs.Stim.onset  = tdt_struct.epocs.Stim.onset(valid_ep,:);
    tdt_struct.epocs.Stim.offset = tdt_struct.epocs.Stim.offset(valid_ep,:);
    tdt_struct.epocs.Stim.data   = tdt_struct.epocs.Stim.data(valid_ep,:);
end

%% Create timeframe

num_bins = size(tdt_struct.snips.(snips_name{1}).data,2);
snip_on  = tdt_struct.snips.(snips_name{1}).ts(1);
epoc_on  = tdt_struct.epocs.Stim.onset(1);

tdt_struct.snips.(snips_name{1}).timeframe  = (0:num_bins-1)/tdt_struct.snips.(snips_name{1}).fs+snip_on-epoc_on;




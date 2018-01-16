
function fixed_data = fix_snip_epoch_mismatch(tdt_struct, good_epoc_idx, good_snip_idx)

    fixed_data = tdt_struct;

    StS           = tdt_struct.snips.StS1;
    epoc     = tdt_struct.epocs.Stim;
    num_chan = length(unique(StS.chan));

    snip_i = zeros(1,num_chan*length(good_snip_idx));

    for i = 1:length(good_snip_idx)
       snip_i( (i-1)*num_chan+1:i*num_chan) = (good_snip_idx(i)-1)*num_chan+1:good_snip_idx(i)*num_chan;
    end

    StS.ts      = StS.ts(snip_i,:);
    StS.data    = StS.data(snip_i,:);
    StS.chan    = StS.chan(snip_i,:);
    StS.sortcode= StS.sortcode(snip_i,:);
    
    epoc.data   = epoc.data(good_epoc_idx,:);
    epoc.onset  = epoc.onset(good_epoc_idx,:);
    epoc.offset = epoc.offset(good_epoc_idx,:);

    fixed_data.snips.StS1 = StS;
    fixed_data.epocs.Stim = epoc;
    
end
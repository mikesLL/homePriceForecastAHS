function [ risk_idx, risk_idx2 ] = gen_risk_idx_quart(param, city_str, ds_use, newhouse_flat )

save('save_gen_risk_idx');

%%
%load newhouse_flat;

newhouse_flat_years = unique(newhouse_flat.PUFYEAR);
newhouse_flat_years = sort(newhouse_flat_years);
%param.SMSA = 4480;
risk_idx = zeros(length(ds_use),1);
risk_idx2 = zeros(length(ds_use),1);

%param.LTI = .35;        % may want to load up an estimate of this; time-varying LTI?
%param.LTI = .45;

param.LTI = .4;
param.max_mult = 40;
param.min_mult = 10;
param.Y_CC = 50000;

%%
%ds_use.APR = ds_use.APR / 100.0;
%%
for id = 1:length(ds_use)
    param.CURR_YEAR = ds_use.YEAR(id); %2013;
    %[ds_id, val] = find(param.CURR_YEAR == newhouse_flat_years, 1, 'first');
    [ds_id, val] = find(newhouse_flat_years <= param.CURR_YEAR, 1, 'last');
    param.CURR_YEAR = newhouse_flat_years(ds_id);
    
    if ( ~isempty(ds_id) )
    %if ( ~isempty(ds_id) && ( ds_use.QUARTER(id) == 1 ) ) 
        % find risk index for current city
        param.APR = ds_use.APR(id);  %.04;
        param.P_HR = 1.0*ds_use.RENT(id);
        param.med_val = ds_use.PRICE(id); %500000;
        
        [a1_ds, a2_ds] = clean_newhouse( param, newhouse_flat );
        %[a1_ds, a2_ds] = clean_newhouse( param, newhouse_flat );
        %PMT = 12.0*a2_ds.PMT;
        
        fprintf('City: %s, renters: %d, owners: %d \n', char(city_str), length(a1_ds), length(a2_ds) );
        N_nat_buyers = sum( .35/param.APR*a1_ds.ZINC2 >= param.med_val  );
        %N_nat_buyers = sum( .25/param.APR*a1_ds.ZINC2 >= param.med_val  );
        
        [ WCF, N_dcfp, N_cfp ] = gen_WCF_lite(param, a2_ds );
        
        N_at_risk_sellers1 = length(a2_ds) - N_cfp;
        N_at_risk_sellers2 = length(a2_ds) - N_dcfp;
        
        if strcmp(param.CFUSE, 'CFP')
            r_idx = N_at_risk_sellers1 / N_nat_buyers;
            %r_idx = N_at_risk_sellers1 / ( length(a2_ds) );
            %r_idx = N_at_risk_sellers1 / ( length(a1_ds) + length(a2_ds) );
        else
            r_idx = N_at_risk_sellers2 / N_nat_buyers;
            %r_idx = N_at_risk_sellers2 / length(a2_ds);
        end
        
        r_idx = N_at_risk_sellers2 / length(a2_ds);
        r_idx2 = N_nat_buyers / length(a2_ds);
        risk_idx(id) = r_idx;
        risk_idx2(id) = r_idx2;
    else
        risk_idx(id) = -9;    % invalid / not-found marker
        risk_idx2(id) = -9;    % invalid / not-found marker
    end
end
%{
%% second pass for interpolation
for id = 1:length(ds_use)
    if ( risk_idx(id) <= -9 )
        if (id <= 4) %if (id == 1)
            %risk_idx(id) = risk_idx(id + 4);
        end
        
        if (id >= length(ds_use) - 3)    %if (id == length(ds_use))
            risk_idx(id) = risk_idx(id - 4);   
        end
        
        if (id > 4) && ( id < (length(ds_use) - 3) )      %if (id > 1) && ( id < length(ds_use) )
            %if (risk_idx( id - 1) >= 0) && (risk_idx( id+1 ) >= 0.0 )
                %risk_idx(id) = .5*( risk_idx( id - 1) + (risk_idx( id+1 ) ) );
                %risk_idx(id) =  risk_idx( id - 1) ;
            %end
            
            %if (risk_idx( id - 4) >= 0) && (risk_idx( id+4 ) >= 0.0 )
            %    risk_idx(id) = .5*( risk_idx( id - 4) + (risk_idx( id + 4 ) ) );
            %end
            
            if (risk_idx( id - 4) >= 0) && (risk_idx( id+4 ) >= 0.0 ) && ( ds_use.QUARTER(id) == 1 )
                %risk_idx(id) = .5*( risk_idx( id - 1) + (risk_idx( id + 4 ) ) );
                risk_idx(id) = risk_idx( id - 1);
                risk_idx(id + 1) = risk_idx(id);
                risk_idx(id + 2) = risk_idx(id);
                risk_idx(id + 3) = risk_idx(id);
            end

        end
        
    end
end
%}
%%
val = 0.0;
for i=1:length(risk_idx)
    if risk_idx(i) <= -8
        risk_idx(i) = val;
    else
        val = risk_idx(i);
    end
    
end

%%
val = 0.0;
for i=1:length(risk_idx2)
    if risk_idx2(i) <= -8
        risk_idx2(i) = val;
    else
        val = risk_idx2(i);
    end
    
end

%%
risk_idx = max(risk_idx, 0.01);
risk_idx2 = max(risk_idx2, 0.01);

end


%risk_idx_tmp = risk_idx;
%for id = 2: ( length(ds_use) - 1 ) 
%    risk_idx_tmp(id) = 1/3*( risk_idx_tmp(id - 1) + risk_idx_tmp(id) + risk_idx_tmp(id + 1) );
%end
%risk_idx = risk_idx_tmp;

%{
for id = 2:( length(ds_use) - 1 )
    if ( risk_idx(id) <= -9 )
        if (risk_idx( id - 1) >= 0) && (risk_idx( id+1 ) >= 0.0 )
            risk_idx(id) = .5*( risk_idx( id - 1) + (risk_idx( id+1 ) ) );
            %risk_idx(id) =  risk_idx( id - 1) ;
        end
        
    end
end
%}


%%
%param.SMSA = 0000;
%if strcmp(city_str, 'LAX')
%    param.SMSA = 4480;
%else
%    param.SMSA = 4480;
%end


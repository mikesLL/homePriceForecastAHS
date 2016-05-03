function [ ds_pool ] = gen_risk_idx( param, dsreadin_codes, ds_pool, newhouse_flat )

N_cities = max(dsreadin_codes.city_id);

for city_id = 1:N_cities
    city_str = dsreadin_codes.city_str(city_id);
    param.SMSA = dsreadin_codes.SMSA1(city_id);
    param.SMSA2 = dsreadin_codes.SMSA2(city_id);
    param.SMSA3 = dsreadin_codes.SMSA3(city_id);
    param.SMSA4 = dsreadin_codes.SMSA4(city_id);
    param.SMSA5 = dsreadin_codes.SMSA5(city_id);
    
    i_beg = find( ds_pool.city_id == city_id, 1, 'first');
    i_end = find( ds_pool.city_id == city_id, 1, 'last');
    
    [test_vec, test_vec2] = gen_risk_idx_city(param, city_str, ds_pool(i_beg: i_end,:), newhouse_flat);
    ds_pool.risk_idx(i_beg:i_end) = test_vec;
    ds_pool.risk_idx2(i_beg:i_end) = test_vec2;
end

end


function [ risk_idx, risk_idx2 ] = gen_risk_idx_city(param, city_str, ds_use, newhouse_flat )

addpath('results');
save('results/save_gen_risk_idx');

newhouse_flat_years = unique(newhouse_flat.PUFYEAR);
newhouse_flat_years = sort(newhouse_flat_years);
risk_idx = zeros(length(ds_use),1);
risk_idx2 = zeros(length(ds_use),1);

param.LTI = .4;
param.max_mult = 40;
param.min_mult = 10;
param.Y_CC = 50000;

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
        
        %[ WCF, N_dcfp, N_cfp ] = gen_WCF_lite(param, a2_ds );
        [ WCF, N_dcfp, N_cfp ] = gen_NEGEQ(param, a2_ds );
        
        N_at_risk_sellers1 = length(a2_ds) - N_cfp;
        N_at_risk_sellers2 = length(a2_ds) - N_dcfp;
        
        r_idx = N_at_risk_sellers2 / length(a2_ds);
        r_idx2 = N_nat_buyers / length(a2_ds);
        risk_idx(id) = r_idx;
        risk_idx2(id) = r_idx2;
    else
        risk_idx(id) = -9;    % invalid / not-found marker
        risk_idx2(id) = -9;    % invalid / not-found marker
    end
end


end
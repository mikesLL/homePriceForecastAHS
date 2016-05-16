%{
gen_micro.m

Generate microdata-based variables from AHS data

Copyright A. Michael Sharifi, 2016

%}


function [ ds_pool ] = gen_micro( param, dsreadin_codes, ds_pool, newhouse_flat )

addpath('results');
save('results/save_gen_micro');

param.LTI = .4;
param.max_mult = 40;
param.min_mult = 10;
param.Y_CC = 50000;

N_cities = max(dsreadin_codes.city_id);

for city_id = 1:N_cities
    city_str = dsreadin_codes.city_str(city_id);
    param.SMSA = dsreadin_codes.SMSA1(city_id);
   
    i_beg = find( ds_pool.city_id == city_id, 1, 'first');
    i_end = find( ds_pool.city_id == city_id, 1, 'last');
    
    [vec1, vec2] = ...
        gen_micro_city(param, city_str, ds_pool(i_beg: i_end,:), newhouse_flat);
    
    ds_pool.risk_idx(i_beg:i_end) = vec1;
    ds_pool.risk_idx2(i_beg:i_end) = vec2;
end

end


function [ vec1, vec2 ] = gen_micro_city(param, city_str, ds_use, newhouse_flat )

addpath('results');
save('results/save_gen_micro_city');

newhouse_flat_years = unique(newhouse_flat.PUFYEAR);
newhouse_flat_years = sort(newhouse_flat_years);

vec1 = zeros(length(ds_use),1);
vec2 = zeros(length(ds_use),1);
vec3 = zeros(length(ds_use),1);
vec4 = zeros(length(ds_use),1);

%%
for id = 1:length(ds_use)
    param.CURR_YEAR = ds_use.YEAR(id); %2013;
    ds_id = find(newhouse_flat_years <= param.CURR_YEAR, 1, 'last');
    param.CURR_YEAR = newhouse_flat_years(ds_id);
    
    if ( ~isempty(ds_id) )
        param.APR = ds_use.APR(id);  
        param.P_HR = 1.0*ds_use.RENT(id);
        param.med_val = ds_use.PRICE(id); 
        
        [a1_ds, a2_ds] = clean_newhouse( param, newhouse_flat );
      
        fprintf('City: %s, renters: %d, owners: %d \n', ...
            char(city_str), length(a2_ds), length(a1_ds) );
        
        N_nat_buyers = sum( .35/param.APR*a2_ds.ZINC2 >= param.med_val  );
        [ N_negeq, N_paid_off ] = gen_micro_vars(param, a1_ds );

        N_at_risk_sellers2 = N_paid_off / length(a2_ds) ;
       
        vec1(id) = N_nat_buyers/length(a1_ds);
        vec2(id) = N_negeq/length(a1_ds);
    else
        vec1(id) = -9;    % invalid / not-found marker
        vec2(id) = -9;    % invalid / not-found marker
    end
end


end
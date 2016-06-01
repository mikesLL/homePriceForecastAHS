%{
gen_micro.m
1. newhouse_flat is a flat file which contains AHS public-use microdata for
1988-2014
2. gen_micro.m constructs microdata-based variables of interest using newhouse_flat

Copyright A. Michael Sharifi, 2016

%}


function [ ds_use ] = gen_micro( param, dsreadin_codes, ds_use, newhouse_flat )

addpath('results');
save('results/gen_micro_save');

param.LTI = .4;
param.max_mult = 40;
param.min_mult = 10;
param.Y_CC = 50000;

ds_use.md1 = zeros(length(ds_use),1);  % md1: potential homebuyers
ds_use.md2 = zeros(length(ds_use),1);  % md2: negative equity
ds_use.md3 = zeros(length(ds_use),1);  % md3: paid-off homes
ds_use.md4 = zeros(length(ds_use),1);  % md4: single-family rentals

ds_use.md5 = zeros(length(ds_use),1);  % md5: negative equity, cash-flow positive
ds_use.md6 = zeros(length(ds_use),1);  % md6: negative equity, cash-flow negative
ds_use.md7 = zeros(length(ds_use),1);  % md7: median pmt to income: new originations

N_cities = max(dsreadin_codes.city_id);

for city_id = 1:N_cities
    city_str = dsreadin_codes.city_str(city_id);
    param.SMSA = dsreadin_codes.SMSA1(city_id);
   
    i_beg = find( ds_use.city_id == city_id, 1, 'first');
    i_end = find( ds_use.city_id == city_id, 1, 'last');
    
    [md1, md2, md3, md4, md5, md6, md7 ] = ...
        gen_micro_city(param, city_str, ds_use(i_beg: i_end,:), newhouse_flat);
   
    ds_use.md1(i_beg:i_end) = md1;
    ds_use.md2(i_beg:i_end) = md2;
    ds_use.md3(i_beg:i_end) = md3;
    ds_use.md4(i_beg:i_end) = md4;
    
    ds_use.md5(i_beg:i_end) = md5;
    ds_use.md6(i_beg:i_end) = md6;
    ds_use.md7(i_beg:i_end) = md7;
end

end


function [md1, md2, md3, md4, md5, md6, md7 ] = gen_micro_city(param, city_str, ds_use, newhouse_flat )

addpath('results');
save('results/save_gen_micro_city');

newhouse_flat_years = unique(newhouse_flat.PUFYEAR);
newhouse_flat_years = sort(newhouse_flat_years);

md1 = zeros(length(ds_use),1);
md2 = zeros(length(ds_use),1);
md3 = zeros(length(ds_use),1);
md4 = zeros(length(ds_use),1);

md5 = zeros(length(ds_use),1);
md6 = zeros(length(ds_use),1);
md7 = zeros(length(ds_use),1);

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
        N_sfr_rent = sum( a2_ds.NUNITS <= 1 );
        
        [ N_negeq, N_paid_off, N_negeq_cfp, N_negeq_cfn, med_pmt_inc ] = ...
            gen_micro_vars(param, a1_ds );

        md1(id) = N_nat_buyers/length(a1_ds);
        md2(id) = N_negeq/length(a1_ds);
        md3(id) = N_paid_off / length(a1_ds);
        md4(id) = N_sfr_rent / length(a1_ds);
        md5(id) = N_negeq_cfp / length(a1_ds);
        md6(id) = N_negeq_cfn / length(a1_ds);
        md7(id) = med_pmt_inc;
    else
        md1(id) = -9;    % invalid / not-found marker
        md2(id) = -9;    % invalid / not-found marker
        md3(id) = -9;
        md4(id) = -9;
        md5(id) = -9;
        md6(id) = -9;
        md7(id) = -9;        
    end
end


end
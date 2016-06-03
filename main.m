%{
main.m loads housing-related data using fetch_data_fn and then for each 
city computes h-step forecast and with out-of-sample RMSE. 
Script computes forecasts with and without access to microdata.

Copyright A. Michael Sharifi 2016

Dependencies:
fetch_data.m: script loads housing data from FRED; stores results as fetch_data_save.m
%}

clear all;
addpath('load_data');
load fetch_data_save;    % load housing data from fetch_data.m
param = gen_param; % load parameters

%%
N_cities = max(ds_use.city_id);
N_stats = 40;                                                  % max number of stats computed

table2 = dataset( zeros( N_stats,1 ), 'VarNames', 'city1' );   % RMSE
table2 = repmat(table2,1,N_cities);
table2.Properties.VarNames = dsreadin_codes.city_str';
table3 = table2;                                               % RMSE (normalized)
table2_md = table2;                                            % RMSE w/micro vars 
table3_md = table2;                                            % RMSE (normalized) w/micro vars

%%
y_ds_store{N_cities} = dataset;                               % forecasts
y_ds_md_store{N_cities} = dataset;                            % forecasts w/micro data

%%
for city_id = 1:N_cities
    city_str = char( dsreadin_codes.city_str(city_id) );
    fprintf( 'city_id = %d,  city_str = %s \n', city_id, city_str ); 
   
    % estimate models without use microdata
    micro_flag = 0; 
    
    % forecast, RMSE results for 1 particular city
    [y_ds, y_res, coeff_ds] = gen_fore(param, city_id, ds_use, micro_flag );  
    
    % store results
    table2(1:length(y_res), city_id) = dataset(y_res);
    table3(1:length(y_res), city_id) = dataset(y_res ./ y_res(1) );
    y_ds_store{city_id} = y_ds;
    
    % estimate models with microdata
    micro_flag = 1; 
    
    % fore, RMSE results for 1 particular city
    [y_ds_md, y_res_md, coeff_ds_md] = gen_fore(param, city_id, ds_use, micro_flag ); 
    
    % store results
    table2_md(1:length(y_res_md), city_id) = dataset(y_res_md);
    table3_md(1:length(y_res_md), city_id) = dataset(y_res_md ./ y_res_md(1) );
    y_ds_md_store{city_id} = y_ds_md;
end

%%
save('results/main_save');


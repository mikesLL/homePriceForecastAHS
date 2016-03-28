%{
fetch_data.m
Script to read in data on largest housing markets from FRED 

Copyright A. Michael Sharifi

%}
fromdate = '01/01/1986';   % beginning of date range for historical data
todate = '01/01/2014';     % ending of date range for historical data

addpath('readin');

load dsreadin_codes;
load smsa_table;
load newhouse_flat;
load dsreadin_macro_data;

c = fred('https://research.stlouisfed.org/fred2/');     % connection to FRED Data

N_cities = max(dsreadin_codes.city_id);
ds_in{N_cities} = dataset;

for city_id = 1:N_cities  %11:14    % = 1: N_cities
    
    fprintf('load city_id %d \n', city_id);
    param.city_id = city_id;
    param.rent2014 = dsreadin_codes.rent2014(city_id);
    param.price2014 = dsreadin_codes.price2014(city_id);
    param.seriesStr = dsreadin_codes.city_str{city_id};
    series_codes = dsreadin_codes(city_id,:);
    
    ds_in0 = fetch_fred_quart(c, param, fromdate, todate, series_codes );
    ds_in0.spy_ret_fut = dsreadin_macro_data.spy_ret_fut;
    ds_in0.spy_ret = dsreadin_macro_data.spy_ret;
    ds_in0.spy_yield = dsreadin_macro_data.spy_yield;
    ds_in{city_id} = ds_in0;
   
end

ds_pool = vertcat(ds_in{:});   % ds_pool now contains pooled data for all cities

close(c);

save('fetch_data_save.mat');



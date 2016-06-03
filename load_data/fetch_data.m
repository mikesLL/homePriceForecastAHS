%{
fetch_data.m
script reads in housing market data from FRED and then loads AHS Microdata
Copyright A. Michael Sharifi, 2016

variables:
1. ds_use: dataset stores composite data across cities and times
2. ds_use.ret_qli, i=0,...,7: i'th lagged quarterly hpa (return)
3. ds_use.mdj, j=1,...,7: j'th microdata-based variable

%}
%addpath('readin');   % contains readin codes
%addpath('results');  % directory to store results

fromdate = '01/01/1986';   % beginning date for historical data
todate = '01/01/2014';     % ending date for historical data

load dsreadin_codes;       % dsreadin_codes store metro level series from FRED
load newhouse_flat;        % newhouse_flat store AHS microdata

load dsreadin_macro_data; % macro data
c = fred('https://research.stlouisfed.org/fred2/');     % connection to FRED Data

N_cities = max(dsreadin_codes.city_id);
ds_in{N_cities} = dataset;

%% cycle through cities
for city_id = 1:N_cities  % 
    
    % load current price, rent, and series codes
    fprintf('load city_id %d \n', city_id);
    param.city_id = city_id;
    param.rent2014 = dsreadin_codes.rent2014(city_id);
    param.price2014 = dsreadin_codes.price2014(city_id);
    param.seriesStr = dsreadin_codes.city_str{city_id};
    series_codes = dsreadin_codes(city_id,:);
    
    % fetch_data_fred: fetch relevant data from FRED
    ds_in0 = fetch_data_fred(c, param, fromdate, todate, series_codes );    
    
    % load macro/national data manually
    ds_in0.spy_ret_fut = dsreadin_macro_data.spy_ret_fut;
    ds_in0.spy_ret = dsreadin_macro_data.spy_ret;
    ds_in0.spy_yield = dsreadin_macro_data.spy_yield;
    ds_in0.inf_exp = dsreadin_macro_data.inf_exp;
    ds_in0.inf_act = dsreadin_macro_data.inf_act;
    ds_in0.tbill1yr = dsreadin_macro_data.tbill1yr;
    ds_in0.apr30yr = dsreadin_macro_data.apr30yr;
    ds_in0.tbond10yr = dsreadin_macro_data.tbond10yr;
    
    ds_in{city_id} = ds_in0;
end

ds_use = vertcat(ds_in{:});   % ds_pool now contains pooled data for all cities
close(c);

%% augment ds_use with microdata from newhouse_flat
ds_use = gen_micro( param, dsreadin_codes, ds_use, newhouse_flat );

%% save results
%save('results/fetch_data_save.mat');
save('fetch_data_save.mat');



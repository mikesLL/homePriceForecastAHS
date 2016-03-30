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

newhouse_flat.INTC = zeros(length( newhouse_flat ) ,1 );   %INTC: interest rate combination

idx_int1 = ( newhouse_flat.INT > 0.0 );
newhouse_flat.INTC( idx_int1 ) = 1.0 / 10000.0 * newhouse_flat.INT( idx_int1 );

idx_int2 = ( newhouse_flat.INTW > 0.0 );
newhouse_flat.INTC( idx_int2 ) = 1.0 / 100.0 * newhouse_flat.INTW( idx_int2 ) + 0.125 /100.0 * newhouse_flat.INTF( idx_int2 );

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

ds_use = vertcat(ds_in{:});   % ds_pool now contains pooled data for all cities

close(c);

%% generate the risk indices
ds_use.risk_idx = zeros(length(ds_use),1);
ds_use.risk_idx2 = zeros(length(ds_use),1);
ds_use = gen_risk_idx_fn( param, dsreadin_codes, ds_use, newhouse_flat );

save('fetch_data_save.mat');



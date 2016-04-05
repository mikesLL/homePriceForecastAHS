%{
fetch_data.m
Script loads AHS Microdata and read in housing markets data from FRED 

Copyright A. Michael Sharifi, 2016

%}
addpath('readin');
addpath('results');

fromdate = '01/01/1986';   % beginning date for historical data
todate = '01/01/2014';     % ending date for historical data

load dsreadin_codes; % dsreadin_codes store metro level series from FRED
load newhouse_flat; % newhouse_flat store AHS microdata
load dsreadin_macro_data; % macro data
c = fred('https://research.stlouisfed.org/fred2/');     % connection to FRED Data

newhouse_flat.INTC = zeros(length( newhouse_flat ) ,1 );   %INTC: interest rate combination

% compute mortgage rates from AHS data
idx_int1 = ( newhouse_flat.INT > 0.0 );
newhouse_flat.INTC( idx_int1 ) = 1.0 / 10000.0 * newhouse_flat.INT( idx_int1 );

idx_int2 = ( newhouse_flat.INTW > 0.0 );
newhouse_flat.INTC( idx_int2 ) = 1.0 / 100.0 * newhouse_flat.INTW( idx_int2 ) + 0.125 /100.0 * newhouse_flat.INTF( idx_int2 );


N_cities = max(dsreadin_codes.city_id);
ds_in{N_cities} = dataset;

for city_id = 1:N_cities  %11:14    % = 1: N_cities
    
    fprintf('load city_id %d \n', city_id);
    param.city_id = city_id;
    param.rent2014 = dsreadin_codes.rent2014(city_id);
    param.price2014 = dsreadin_codes.price2014(city_id);
    param.seriesStr = dsreadin_codes.city_str{city_id};
    series_codes = dsreadin_codes(city_id,:);
    
    ds_in0 = fetch_data_fred(c, param, fromdate, todate, series_codes );
    ds_in0.spy_ret_fut = dsreadin_macro_data.spy_ret_fut;
    ds_in0.spy_ret = dsreadin_macro_data.spy_ret;
    ds_in0.spy_yield = dsreadin_macro_data.spy_yield;
        
    % new cols here
    ds_in0.inf_exp = dsreadin_macro_data.inf_exp;
    ds_in0.inf_act = dsreadin_macro_data.inf_act;
    ds_in0.tbill1yr = dsreadin_macro_data.tbill1yr;
    ds_in0.apr30yr = dsreadin_macro_data.apr30yr;
    ds_in0.tbond10yr = dsreadin_macro_data.tbond10yr;
    
    ds_in{city_id} = ds_in0;
   
end

ds_use = vertcat(ds_in{:});   % ds_pool now contains pooled data for all cities
close(c);

%% generate the risk indices
ds_use.risk_idx = zeros(length(ds_use),1);
ds_use.risk_idx2 = zeros(length(ds_use),1);
ds_use = gen_risk_idx( param, dsreadin_codes, ds_use, newhouse_flat );

save('results/fetch_data_save.mat');



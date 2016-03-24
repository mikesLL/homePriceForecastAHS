function [ ds_pool ] = fetch_data_fn( param, dsreadin_codes, dsreadin_macro_data, fromdate, todate, c) 

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
end


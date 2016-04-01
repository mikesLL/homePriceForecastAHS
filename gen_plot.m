function gen_plot(param, ds_use, city_id, city_str )

idx1 = all([ ds_use.city_id == city_id, ds_use.YEAR >= param.year_beg, ...
    ds_use.YEAR <= param.year_end] , 2 );

figure; plot(ds_use.YEAR(idx1),ds_use.risk_idx(idx1));
%title( strcat(city_str,': Negative Equity Homeowners') );

figure; plot(ds_use.YEAR(idx1), ds_use.risk_idx2(idx1));
%title( strcat(city_str,': Potential Buyers') );

figure; plot(ds_use.YEAR(idx1), ds_use.PRICE(idx1));
%title( strcat(city_str,': Price') );


end


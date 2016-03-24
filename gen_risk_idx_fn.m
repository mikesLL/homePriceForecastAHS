function [ ds_pool ] = gen_risk_idx_fn( param, dsreadin_codes, ds_pool, newhouse_flat )

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
    
    [test_vec, test_vec2] = gen_risk_idx_quart(param, city_str, ds_pool(i_beg: i_end,:), newhouse_flat);
    ds_pool.risk_idx(i_beg:i_end) = test_vec;
    ds_pool.risk_idx2(i_beg:i_end) = test_vec2;
end

end


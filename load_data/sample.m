load fetch_data_save;

%% display sample datasets
%LAX homeowner incomes in 2005
idx_LAX_2005 = all([ newhouse_flat.SMSA == 4480, ...
    newhouse_flat.PUFYEAR == 2005, newhouse_flat.TENURE==1],2);
fprintf('2005 mean LAX inc: %f\n', mean(newhouse_flat.ZINC2(idx_LAX_2005)));

ds_lax = newhouse_flat(idx_LAX_2005,:);

%SDG homeowner incomes in 2005
idx_SDG_2005 = all([ newhouse_flat.SMSA == 7320, ...
    newhouse_flat.PUFYEAR == 2005, newhouse_flat.TENURE==1],2);
fprintf('2005 mean SDG inc: %f\n', mean(newhouse_flat.ZINC2(idx_SDG_2005)));

%SFR homeowner incomes in 2005
idx_SFR_2005 = all([ newhouse_flat.SMSA == 7360, ...
    newhouse_flat.PUFYEAR == 2005, newhouse_flat.TENURE==1],2);
fprintf('2005 mean SFR inc: %f\n', mean(newhouse_flat.ZINC2(idx_SFR_2005)));



% Rents for other cities, observed in June from years 2002 - 2014

idx_CIT = all([ ismember( ds_use.city_id, [9, 3, 17, 2, 7, 1] ), ...
    ds_use.YEAR >= 2002, ds_use.YEAR <= 2014, ds_use.QUARTER == 2 ] , 2);
ds_use_CIT = ds_use(idx_CIT,[1,3,5,6,7,12,13,14,15]);

ds_use_CIT.lagged_ret = ds_use_CIT.ret_ql0 + ds_use_CIT.ret_ql1 + ...
    ds_use_CIT.ret_ql2 + ds_use_CIT.ret_ql3;
    
%, ds_use.YEAR(idx_CIT) ];
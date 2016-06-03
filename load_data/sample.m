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
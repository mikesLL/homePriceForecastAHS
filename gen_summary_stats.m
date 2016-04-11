function [ table ] = gen_summary_stats( ds_use, dsreadin_codes )

N_cities2 = max(ds_use.city_id);
table = dataset;
table.city_str = (dsreadin_codes.city_str);
table.ret_mean = zeros(N_cities2,1);
table.ret_std = zeros(N_cities2,1);
table.ret_min = zeros(N_cities2,1);
table.ret_max = zeros(N_cities2,1);

for i = 1:N_cities2
    idx_use = all([ ds_use.city_id == i, ds_use.YEAR >= ...
        param.year_beg, ds_use.YEAR <= param.year_end ], 2);
    table.ret_mean(i) = mean(ds_use.RET(idx_use));
    table.ret_std(i) = std(ds_use.RET(idx_use));
    table.ret_min(i) = min(ds_use.RET(idx_use));
    table.ret_max(i) = max(ds_use.RET(idx_use));
end


end


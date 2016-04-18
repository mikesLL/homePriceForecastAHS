%{
gen_summary_stats.m
This program reads in param (parameters), ds_use, and dsreadin_codes
and prints a table of summary statistics associated with each city

Copyright A. Michael Sharifi, 2016
%}

function [ table, table_pool ] = gen_summary_stats(param, ds_use, dsreadin_codes )

addpath('results');
save('results/summary_stats_save');

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

N_reg = 3; % number of regions
ds_use.reg_id = zeros(length(ds_use),1);
west_id = [2, 10, 12, 14]; % LAX, SFR, SEA, SDG
cent_id = [3, 4, 5, 11, 13, 16, 17]; % CHI, DFW, HOUST, DET, MINN, STL, DEN 
east_id = [1, 6, 7, 8, 9, 15]; %NYM, PHI, MIA, ATL, BOS, TMPA

idx_reg(:,1) = ismember( ds_use.city_id, west_id );
idx_reg(:,2) = ismember( ds_use.city_id, cent_id );
idx_reg(:,3) = ismember( ds_use.city_id, east_id );


table_pool = dataset;
table_pool.reg_str = {'west'; 'central'; 'east'};
table_pool.ret_mean = zeros(N_reg,1);
table_pool.ret_std = zeros(N_reg,1);
table_pool.ret_min = zeros(N_reg,1);
table_pool.ret_max = zeros(N_reg,1);
table_pool.RP_mean = zeros(N_reg,1);

table_pool.gamma0 = zeros(N_reg,1);
table_pool.gamma1 = zeros(N_reg,1);
table_pool.alpha = zeros(N_reg,1);
table_pool.rho = zeros(N_reg,1);
table_pool.theta = zeros(N_reg,1);
table_pool.sigma_err = zeros(N_reg,1);

for i = 1:N_reg
    idx_use = all([ idx_reg(:,i) , ds_use.YEAR >= ...
        param.year_beg, ds_use.YEAR <= param.year_end_pool ], 2);
    table_pool.ret_mean(i) = mean(ds_use.RET(idx_use));
    table_pool.ret_std(i) = std(ds_use.RET(idx_use));
    table_pool.ret_min(i) = min(ds_use.RET(idx_use));
    table_pool.ret_max(i) = max(ds_use.RET(idx_use));
    table_pool.RP_mean(i) = mean( ds_use.RP(idx_use) );
    
    y = log(ds_use.RENT(idx_use));  % step1: estimate cointegrating vector
    X = log(ds_use.PRICE(idx_use));
    stats = regstats(y,X,'linear');
    gamma0 = stats.tstat.beta(1); 
    gamma1 = stats.tstat.beta(2);
    
    err = y - stats.yhat; % step 2: calc residual
    
    % step 3: estimate other parameters
    y = ds_use.RET_fut(idx_use) - ds_use.inf_act(idx_use);
    X = [ds_use.RET(idx_use) - ds_use.inf_act(idx_use), err]; 
    stats2 = regstats(y,X,'linear');
    
    table_pool.gamma0(i) = gamma0;
    table_pool.gamma1(i) = gamma1;
    table_pool.alpha(i) = stats2.beta(1);
    table_pool.rho(i) = stats2.beta(2);
    table_pool.theta(i) = stats2.beta(3);

end


end


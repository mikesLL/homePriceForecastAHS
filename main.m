%{
main.m
this script loads housing-related data using fetch_data_fn and then for each city computes h-step
forecast and for each forecast computes OOS RMSE
Then incorporates forecast into an mean-variance optimization problem and
evaluates performance

Copyright A. Michael Sharifi 2016

Dependencies:
fetch_data.m: script which loads housing data from FRED;
results are stored as fetch_data_save.m
%}

clear all;
param = gen_param; % load parameters
load fetch_data_save; % load housing data from fetch_data.m

%%
N_cities = max(ds_use.city_id);
N_stats = 40;                       % max number of stats computed

% table2: RMSE 
% table3: RMSE (normalized)
% table2_mf: RMSE w/ micro vars
% table3_mf: RMSE (normalized) w/ micro vars
table2 = dataset( zeros( N_stats,1 ), 'VarNames', 'city1' );
table2 = repmat(table2,1,N_cities);
table2.Properties.VarNames = dsreadin_codes.city_str';
table3 = table2;
table2_mf = table2;
table3_mf = table2;

table4 = dataset( zeros(N_cities,1) );   %mu, std for portfolio with and without micro vars
table4 = repmat(table4, 1, 5);
table4.Properties.VarNames = {'mu0', 'std0', 'mu1', 'std1', 'cer' };

%%
city_id = 2;
%gen_plot(param, ds_use, city_id, 'LAX');

util_diff = zeros(N_cities,1);
util0_store = zeros(N_cities,1);
util1_store = zeros(N_cities,1);
mv_gamma = 4;

%%
save('main_mid1_save');
y_ds_store{N_cities} = dataset;
y_ds_mf_store{N_cities} = dataset;

%%
for city_id = 1:N_cities
    disp(city_id);
    
    micro_flag = 0;  % do not use microdata
    [y_ds, y_res] = gen_fore( city_id, ds_use, micro_flag ); % fore, RMSE results for 1 particular city
    table2(1:length(y_res), city_id) = dataset(y_res);
    table3(1:length(y_res), city_id) = dataset(y_res ./ y_res(1) );
    y_ds_store{city_id} = y_ds;
    
    micro_flag = 1;  % use microdata
    [y_ds_mf, y_res_mf] = gen_fore( city_id, ds_use, micro_flag ); % fore, RMSE results for 1 particular city
    table2_mf(1:length(y_res_mf), city_id) = dataset(y_res_mf);
    table3_mf(1:length(y_res_mf), city_id) = dataset(y_res_mf ./ y_res_mf(1) );
    y_ds_mf_store{city_id} = y_ds_mf;
    
    mu_h_flag = 1;
    port_ds = gen_port(param, city_id, ds_use, y_ds, mu_h_flag, mv_gamma );
    port_ds_mf = gen_port(param, city_id, ds_use, y_ds_mf, mu_h_flag, mv_gamma );
    
    table4.mu0(city_id) = port_ds.mean_est(96);
    table4.std0(city_id) = port_ds.std_est(96);
    table4.mu1(city_id) = port_ds_mf.mean_est(96);
    table4.std1(city_id) = port_ds_mf.std_est(96);
    v0 = table4.mu0(city_id)-mv_gamma/2.0*(table4.std0(city_id).^2);
    v1 = table4.mu1(city_id)-mv_gamma/2.0*(table4.std1(city_id).^2);
    table4.cer(city_id) = v1 - v0;
    
    util0 = port_ds.util(96);
    util1 = port_ds_mf.util(96);
    disp( [util0 util1] );
    util0_store( city_id ) = util0;
    util1_store( city_id ) = util1;
    util_diff( city_id ) = util1 - util0;
end

save('main_save');


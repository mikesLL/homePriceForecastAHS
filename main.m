%{
main.m
loads data using fetch_data quart and then for each city computes h-step
forecast and for each forecast computes OOS RMSE
Then incorporates forecast into an mean-variance optimization problem and
evaluates performance
%}
clear all

load dsreadin_codes;
load smsa_table;
load newhouse_flat;
load dsreadin_macro_data;

param = gen_param;

c = fred('https://research.stlouisfed.org/fred2/');     % connection to FRED Data
fromdate = '01/01/1986';   % beginning of date range for historical data
todate = '01/01/2014';     % ending of date range for historical data

if true
    %% fetch data
    ds_use = fetch_data_fn( param, dsreadin_codes, dsreadin_macro_data, fromdate, todate, c);
else
    load fetch_data_save;
end

%% generate the risk indices
ds_use.risk_idx = zeros(length(ds_use),1);
ds_use.risk_idx2 = zeros(length(ds_use),1);
ds_use = gen_risk_idx_fn( param, dsreadin_codes, ds_use, newhouse_flat );

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

% table4: mu, std for portfolio with and without micro vars
table4 = dataset( zeros(N_cities,1) );
table4 = repmat(table4, 1, 5);
table4.Properties.VarNames = {'mu0', 'std0', 'mu1', 'std1', 'cer' };

% table5_mvgamma: stores entire table for each gamma value
table4_mvgamma{20} = table4;

%%
city_id = 2;
gen_plot(param, ds_use, city_id, 'LAX');

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

%%
%{
port_ret_store0{17} = zeros(100,1);
port_ret_store1{17} = zeros(100,1);
port_ret_store2{17} = zeros(100,1);

X_opt_store0{17} = zeros(100,4);
X_opt_store1{17} = zeros(100,4);
X_opt_store2{17} = zeros(100,4);
%}

%{
table44 = dataset;
table44.mu0 = zeros(N_cities,1);
table44.std0 = zeros(N_cities,1);
table44.mu1 = zeros(N_cities,1);
table44.std1 = zeros(N_cities,1);
table44.cer = zeros(N_cities,1);
table44_mvgamma{20} = table44.cer;
%}

%{
% want to be able to get rid of thse soon
N_pred = 14;            % number of predictor variables w/ microdata
N_pred0 = N_pred - 2;   % number of predictor variables w/o microdata
N_naive = 2;            % number naive forecasts
N_combo = 5;            % number combination forecasts
N_tot = N_pred + N_naive + N_combo; % number all forecasts w/microdata
N_tot0 = N_tot - 2;
%}
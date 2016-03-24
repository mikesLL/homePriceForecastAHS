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

if false
    fetch_data;   %fetch_data_quart;   %fetch_data;
else
    load fetch_data_save;
end

ds_use = ds_pool;

%% fetch data
ds_use = fetch_data_fn( param, dsreadin_codes, dsreadin_macro_data, fromdate, todate, c);

%% generate the risk indices
ds_use.risk_idx = zeros(length(ds_use),1);
ds_use.risk_idx2 = zeros(length(ds_use),1);
ds_use = gen_risk_idx_fn( param, dsreadin_codes, ds_use, newhouse_flat );

%%
N_cities = max(ds_use.city_id);
N_stats = 40;                       % max number of stats computed

% table2: RMSE w/ micro vars
% table3: RMSE w/ micro vars (normalized)
% table2: RMSE
% table3: RMSE (normalized)
table2 = dataset( zeros( N_stats,1 ), 'VarNames', 'city1' );
table2 = repmat(table2,1,N_cities);
table2.Properties.VarNames = dsreadin_codes.city_str';
table3 = table2;
table2_mf = table2;
table3_mf = table2;

table44 = dataset;
table44.mu0 = zeros(N_cities,1);
table44.std0 = zeros(N_cities,1);
table44.mu1 = zeros(N_cities,1);
table44.std1 = zeros(N_cities,1);
table44.cer = zeros(N_cities,1);
table44_mvgamma{20} = table44.cer;

% table5: mu, std for portfolio with and without micro vars
table5 = dataset( zeros(N_cities,1) );
table5 = repmat(table5, 1, 5);
table5.Properties.VarNames = {'mu0', 'std0', 'mu1', 'std1', 'cer' };

% table5_mvgamma: stores entire table for each gamma value
table5_mvgamma{20} = table5;

%%
city_id = 2;
gen_plot(param, ds_use, city_id, 'LAX');

util_diff = zeros(N_cities,1);
util0_store = zeros(N_cities,1);
util1_store = zeros(N_cities,1);

port_ret_store0{17} = zeros(100,1);
port_ret_store1{17} = zeros(100,1);
port_ret_store2{17} = zeros(100,1);

X_opt_store0{17} = zeros(100,4);
X_opt_store1{17} = zeros(100,4);
X_opt_store2{17} = zeros(100,4);

mv_gamma = 4;

%%
% want to be able to get rid of thse soon
N_pred = 14;            % number of predictor variables w/ microdata
N_pred0 = N_pred - 2;   % number of predictor variables w/o microdata
N_naive = 2;            % number naive forecasts
N_combo = 5;            % number combination forecasts
N_tot = N_pred + N_naive + N_combo; % number all forecasts w/microdata
N_tot0 = N_tot - 2;

save('main_mid1_save');

y_ds_store{N_cities} = dataset;
y_ds_mf_store{N_cities} = dataset;

%%
for city_id = 1:N_cities
    micro_flag = 0;  % do not use microdata
    [y_ds, y_res] = gen_fore( city_id, ds_use, micro_flag ); % fore, RMSE results for 1 particular city
    table2(1:length(y_res), city_id) = dataset(y_res);
    table3(1:length(y_res), city_id) = dataset(y_res ./ y_res(1) );
    y_ds_store{city_id} = y_ds;
    
    micro_flag = 1;  % use microdata
    [y_ds_mf, y_res_mf] = gen_fore( city_id, ds_use, micro_flag ); % fore, RMSE results for 1 particular city
    idx  = find(y_ds.valid,1,'last');
    table2(1:length(y_res_mf), city_id) = dataset(y_res_mf);
    table3(1:length(y_res_mf), city_id) = dataset(y_res_mf ./ y_res_mf(1) );
    y_ds_mf_store{city_id} = y_ds_mf;
end

save('main_mid2_save');

%%
for city_id = 1:N_cities
    mu_h_flag = 1;
    mv_gamma = 4.0;
    port_ds = gen_weights(param, city_id, ds_use, y_ds, micro_flag, mu_h_flag, mv_gamma );
    
    
end

%%
for city_id = 1:N_cities
    
    %%
    micro_flag = 0;  % do not use microdata
    [y_ds, y_res] = gen_fore( city_id, ds_use, micro_flag ); % fore, RMSE results for 1 particular city
    table2(1:length(y_res), city_id) = dataset(y_res);
    table3(1:length(y_res), city_id) = dataset(y_res ./ y_res(1) );
    
    %%
    micro_flag = 1;  % use microdata
    [y_ds_mf, y_res_mf] = gen_fore( city_id, ds_use, micro_flag ); % fore, RMSE results for 1 particular city
    idx  = find(y_ds.valid,1,'last');
    table2(1:length(y_res_mf), city_id) = dataset(y_res_mf);
    table3(1:length(y_res_mf), city_id) = dataset(y_res_mf ./ y_res_mf(1) );
    
    
    %%
    tic;
    flag = 0; mu_h_flag = 1;
    [ y_city, y_1f, y_1f_RMSE, y_1f_combo, y_1f_combo_RMSE, ...
        sharpe_ratio0, util0, port_ret0, x_opt_store0   ] = ...        % generate 1-step forecasts; do not use risk_idx
        notes12_table2( city_id, ds_use, flag, mu_h_flag, mv_gamma );
    
    toc;
    disp(city_id);
    
    vec_f0 = [ y_1f_RMSE( end - 4, 1:(N_pred0 + N_naive ) ) ...
        y_1f_combo_RMSE(end-4, 1:N_combo) ]';
    
    %%
    tic;
    flag = 1; mu_h_flag = 1;
    [ y_city, y_1f, y_1f_RMSE, y_1f_combo, y_1f_combo_RMSE, ...
        sharpe_ratio1, util1, port_ret1, x_opt_store1 ] = ...        % generate 1-step forecasts; use risk_idx
        notes12_table2( city_id, ds_use, flag, mu_h_flag, mv_gamma );
    toc;
    
    %%
    tic;
    flag = 0; mu_h_flag = 0;
    [ ~, ~, ~, ~, ~, ~, ~, port_ret2, x_opt_store2 ] = ...        % generate 1-step forecasts; use risk_idx
        notes12_table2( city_id, ds_use, flag, mu_h_flag, mv_gamma );
    toc;
    
    %%
    port_ret_store0{city_id} = port_ret0;
    port_ret_store1{city_id} = port_ret1;
    port_ret_store2{city_id} = port_ret2;
    
    X_opt_store0{city_id} = x_opt_store0;
    X_opt_store1{city_id} = x_opt_store1;
    X_opt_store2{city_id} = x_opt_store2;
    
    table44.mu0(city_id) = mean(port_ret0(49:96));
    table44.std0(city_id) = std(port_ret0(49:96));
    table44.mu1(city_id) = mean(port_ret1(49:96));
    table44.std1(city_id) = std(port_ret1(49:96));
    table44.cer(city_id) = ( table44.mu1(city_id) - table44.mu0(city_id) ) - 4/2*( table44.std1(city_id) - table44.std1(city_id) );
    
    table44_mvgamma{mv_gamma} = table44;
    
    %%
    if false
        figure; hold on;
        plot(date_axis(49:96),port_ret0(49:96));
        plot(date_axis(49:96),port_ret1(49:96),'r');
        plot(date_axis(49:96),port_ret2(49:96),'g');
        legend('w/o MD', 'w/MD');
        title_str0 = strcat(dsreadin_codes.city_str(city_id),' Portfolio Returns');
        title(title_str0);
        
        figure;
        plot(date_axis(49:96),x_opt_store0(49:96,:));
        title_str1 = strcat(dsreadin_codes.city_str(city_id),' Portfolio Weights: w/o Microdata');
        title(title_str1);
        legend('X', 'H', 'M', 'RF');
        
        figure;
        title_str2 = strcat(dsreadin_codes.city_str(city_id),' Portfolio Weights: w/ Microdata');
        plot(date_axis(49:96),x_opt_store1(49:96,:));
        title(title_str2);
        legend('X', 'H', 'M', 'RF');
    end
    
    %%
    disp( [util0 util1] );
    util0_store( city_id ) = util0;
    util1_store( city_id ) = util1;
    util_diff( city_id ) = util1 - util0;
    
    vec = [ y_1f_RMSE( end - 4, 1:(N_pred + N_naive) ) ...
        y_1f_combo_RMSE(end-4, 1:N_combo) ]';
    
    vec2_f0 = vec_f0;
    vec2_f0(2:end) = vec_f0(2:end) ./ vec_f0(1);
    table2_f0(1: N_tot0, city_id) = dataset( vec_f0 );
    table3_f0(1: N_tot0, city_id) = dataset( vec2_f0 );
    
    vec2 = vec;
    vec2(2:end) = vec(2:end) ./ vec(1);
    table2(1: N_tot, city_id) = dataset( vec );
    table3(1: N_tot, city_id) = dataset( vec2 );
    
end

%%
foo0 = var(y_city(44:end) - y_1f(44:end,1) );
foo1 = var(y_city(44:end) - y_1f_combo(44:end,4));

%%
save('main_save');

% For this program, want to load up results and CITY BY CITY, estimate and
% test forecast combination model as in Rapach and Strauss (2007)

clear all

if false
    fetch_data_quart;   %fetch_data;
else
    load fetch_data_save;
end

%%
idx = (ds_pool.city_id == 1);
risk_idx = ds_pool.risk_idx(idx) ./ ds_pool.risk_idx2(idx);
plot(risk_idx);
%%
ds_use = ds_pool;
%ds_use.risk_idx = ds_use.risk_idx2;

N_cities = max(ds_pool.city_id);
N_use = 40;                       % max number of stats computed 

table2 = dataset( zeros( N_use,1 ), 'VarNames', 'city1' );
table2 = repmat(table2,1,N_cities);
table2.Properties.VarNames = dsreadin_codes.city_str';
table3 = table2;
table2_f0 = table2;
table3_f0 = table2;

table44 = dataset;
table44.mu0 = zeros(N_cities,1);
table44.std0 = zeros(N_cities,1);
table44.mu1 = zeros(N_cities,1);
table44.std1 = zeros(N_cities,1);
table44.cer = zeros(N_cities,1);
table44_mvgamma{20} = table44.cer;

%%
city_id = 2;
idx1 = ( ds_use.city_id == city_id);
figure; plot(ds_use.YEAR(idx1),ds_use.risk_idx(idx1));
title('LAX: at-risk homeowners');

figure; plot(ds_use.YEAR(idx1), ds_use.risk_idx2(idx1));
title('LAX: potential buyers');

figure; plot(ds_use.YEAR(idx1), ds_use.PRICE(idx1));
title('LAX: price');

util_diff = zeros(N_cities,1);
util0_store = zeros(N_cities,1);
util1_store = zeros(N_cities,1);

port_ret_store0{17} = zeros(100,1);
port_ret_store1{17} = zeros(100,1);
port_ret_store2{17} = zeros(100,1);

X_opt_store0{17} = zeros(100,4);
X_opt_store1{17} = zeros(100,4);
X_opt_store2{17} = zeros(100,4);

date_axis = ds_use.YEAR(idx1) + .25*(ds_use.QUARTER(idx1) - 1);

mv_gamma = 4;
%%
for city_id = 1:N_cities
    %%
    N_pred = 14; %13;
    N_pred0 = N_pred - 2;
    N_naive = 2;
    N_combo = 5;
    N_tot = N_pred + N_naive + N_combo;
    N_tot0 = N_tot - 2;
    
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

%%
figure;
hold on;
for city_id = 1:N_cities
    idx_use = (ds_use.city_id == city_id);
    plot(ds_use.risk_idx(idx_use));
    
end

%%
%ds_pool.risk_idx2 = zeros(length(ds_pool),1);

%table4 = gen_tabe4;


%% normalize table2 relative to AR benchmark
%table3 = table2;
%table3(2:end,:) = table2(2:end,:) ./ table2(1,:);

%%
%{
ROW 1: AR Benchmark

%}

%% NOTES:
%{
DO NOT NEED A HOLDOUT PERIOD:
1. Simple AR1 Forecast
2. Forecast Combination: Mean 
3. Forecast Combination: Median
4. Forecast Combination: Truncated Mean

NEED A HOLDOUT PERIOD:
1. Forecast Combination: Weighted Average (inv RMSE)
2. Forecast Combination: C(K,PB) Cluster Algo

TBH, combination forecast looks FABULOUS
Q: what would you need to do a full holdout period?
1. Estimate beta for 1:t_est
2. Gen 1-step 
3. Compare 1-step to realization for 1 period
%}

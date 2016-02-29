% heart of the project
% main input should be a particular city
% main output should be AR RMSE, and RMSE of each predictor and combination
% for a particular city
% relative to the passed in RMSE

% main inputs are city_id, a particular city you want to use and 
% ds_use, the full dataset 
function [ y_city, y_1f, y_1f_RMSE, y_1f_combo, y_1f_combo_RMSE   ] = notes12_table2_new( city_id, ds_use )

save('notes12_table2_save.mat');

%% construct city-unique dataset
h_step = 1;
t_begin = 10;  %t_begin = 12;

idx_use = min ( ( ds_use.YEAR >= 1988) , (ds_use.YEAR <= 2012 ) );
idx_use2 = (ds_use.city_id == city_id) ;  % set == 6 for LAX
idx_use = min(idx_use, idx_use2);

if true
    X_city = [ds_use.RET(idx_use) ds_use.RP(idx_use) ds_use.risk_idx(idx_use) ...
        ds_use.APR(idx_use) ds_use.POPCHG(idx_use) ds_use.PCICHG(idx_use) ...
        ds_use.PI_ratio(idx_use) ds_use.NU2POP(idx_use) ds_use.EMPCHG(idx_use) ...
        ds_use.LFCHG(idx_use) ds_use.URATE(idx_use) ];
else
    X_city = [ds_use.RET(idx_use) ds_use.RP(idx_use) ...
        ds_use.APR(idx_use) ds_use.POPCHG(idx_use) ds_use.PCICHG(idx_use) ];
end

y_city = ds_use.RET_fut(idx_use);

%% construct estimation period; estimate then evaluate benchmark
N_pred = size(X_city,2);      % number of predictors to use (including AR bench); AR will be index 1
N_naive = 2;                  % N1: hist mean, N2: lagged ret            
N_combo = 5;

y_1f = zeros(length(y_city), N_pred + N_naive );       % store y 1-step forecast
y_1f_RMSE = zeros(length(y_city), N_pred + N_naive);

y_1f_combo = zeros(length(y_city), N_combo );          % store y 1-step forecast combinations
y_1f_combo_RMSE = zeros(length(y_city), N_combo);

err2_cum = zeros(N_pred + N_naive, 1);

%%
for t_use = t_begin : ( length(y_city)- h_step )
    t_est = t_use - h_step;  % 1-step forecast; 
    for i=1:N_pred  % generate the simple predictors 
        pred = unique([1 i]);
        stats_i = regstats(y_city(1:t_est),X_city(1:t_est,pred),'linear');
        
        y_1f(t_use,i) = [1.0 X_city(t_use,pred)] * stats_i.beta; 
    end  
    
    y_1f(t_use, N_pred + 1) = mean(X_city(1:t_est, 1 ) );        %naive: historical mean
    y_1f(t_use, N_pred + 2) = X_city(t_est, 1 );                 %naive: lagged ret 
    
    
    y_1f_combo(t_use,1) = 1/N_pred* sum(y_1f(t_use,:)) ;         %forecast combo: average weight 
    y_1f_combo(t_use, 2) = median( y_1f(t_use,:) );              %forecast combo: median
    
    y_1f_sort = sort( y_1f(t_use,:) );
    y_1f_combo(t_use, 3) = mean(y_1f_sort(2:end-1) );            %forecast combo: truncate mean
    
    weights2 = zeros(N_pred + N_naive,1);
    
    % new code here    
    for i=1:( N_pred + N_naive )
        err2_cum(i) = sum( (y_city(t_begin:t_use) - y_1f(t_begin:t_use,i)).^2 );
    end
    
    if t_use >= (t_begin + 1)
        for i=1:( N_pred + N_naive )
            weights2(i) = (  err2_cum(i)^-1 ) / sum( err2_cum .^ -1 );
        end
        
        y_1f_combo(t_use, 4) = y_1f(t_use,:) * weights2;
        
        [ val, idx ] = sort( err2_cum );
        y_1f_combo(t_use, 5) = mean( y_1f(t_use, idx(1:4) ) );
    
    end
   
    for i=1:(N_pred + N_naive)
        y_1f_RMSE(t_use,i) = rmse( y_city(t_begin:t_use), y_1f(t_begin:t_use,i) );        
    end
    
    for i = 1:N_combo
        y_1f_combo_RMSE(t_use,i) = rmse( y_city(t_begin:t_use), y_1f_combo(t_begin:t_use,i) );
    end
end


end


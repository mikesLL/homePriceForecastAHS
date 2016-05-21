%{
gen_fore.m
input: city, dataset, flag, gamma
output: forecast, forecast combo, RMSE, portfolio weights
%}

% heart of the project
% main input should be a particular city
% main output should be AR RMSE, and RMSE of each predictor and combination
% relative to the passed in RMSE

% city_id: city index
% ds_use: incoming dataset
% micro_flag: flag to use microdata

% y_city: home price appreciation associated with city
% y_1f: forecasts
% y_l1f_RMSE: RMSE
% y_lf_combo: combination forecasts
% y_1f_combo: RMSE

function [ y_ds, y_res, coeff_ds ] = gen_fore( city_id, ds_use, micro_flag )

%addpath('results');
save('gen_fore_save.mat');   % TODO: delete this when running model

%% micro_flag = flag;
idx_use = all([ ds_use.YEAR >= 1988, ds_use.YEAR <= 2012, ds_use.city_id == city_id  ], 2);

%X_city_fund =  [ ds_use.RET(idx_use) ds_use.RP(idx_use) ds_use.PI_ratio(idx_use)];

X_city_fund =  [ ds_use.ret_ql0(idx_use) ds_use.RP(idx_use) ds_use.PI_ratio(idx_use)];

X_city_micro =  [ ds_use.md1(idx_use), ds_use.md2(idx_use) ...                                 % proportion at-risk households
                  ds_use.md3(idx_use), ds_use.md4(idx_use) ...
                  ds_use.md5(idx_use), ds_use.md6(idx_use) ...
                  ds_use.md7(idx_use) ];
            
X_city_other = [ ds_use.APR(idx_use) ds_use.POPCHG(idx_use) ds_use.PCICHG(idx_use) ...
    ds_use.NU2POP(idx_use) ds_use.EMPCHG(idx_use) ...
    ds_use.LFCHG(idx_use) ds_use.URATE(idx_use) ...
    ds_use.spy_ret(idx_use) ds_use.spy_yield(idx_use) ];

if micro_flag
    X_city = [X_city_fund, X_city_micro, X_city_other];
else
    X_city = [X_city_fund, X_city_other];
end

y_ds = dataset;
y_ds.RET_fut = ds_use.RET_fut(idx_use);

y_city = ds_use.RET_fut(idx_use);

N_pred = size(X_city,2);                               % number of predictors to use (including bench); bench will be index 1
N_naive = 2;
N_combo = 5;

y_ds.fore = zeros(length(y_ds), N_pred);
y_ds.fore_naive = zeros(length(y_ds), N_naive );
y_ds.fore_combo = zeros(length(y_ds), N_combo );

y_ds.fore_RMSE = zeros(length(y_ds), N_pred);
y_ds.fore_naive_RMSE = zeros(length(y_ds), N_naive );
y_ds.fore_combo_RMSE = zeros(length(y_ds), N_combo );

y_ds.valid = zeros(length(y_ds),1);
%% construct estimation period
err2_cum = zeros(N_pred, 1);

%%
h_step = 4; % h-step: 4 quarters
h_hold = 4; % holdout period
t_begin = 60; % begin halfway into dataset
t_end = length(y_city)- h_step;

%% ceofficient dataset
coeff_ds = dataset;
coeff_ds.rho = zeros(length(y_city),N_pred);
coeff_ds.beta = zeros(length(y_city),N_pred);

%%
for t_use = t_begin:t_end
    t_est = t_use - h_step;  % 1-step forecast: information set
    
    for i=1:N_pred  % generate the simple predictors
        pred = unique([1 i]);
        
        stats_i = regstats(y_city(1:t_est),X_city(1:t_est,pred),'linear');  
        
        stats_i_midas = reg_midas( y_city(1:t_est), X_city_fund(1:t_est,1), X_city(1:t_est,i) );
        %stats_i_midas = reg_midas( y_city(1:t_est), X_city(1:t_est,i) );
          
        coeff_ds.rho(t_est,i) = stats_i.beta(2);
        
        if i>=2
            coeff_ds.beta(t_est,i) = stats_i.beta(3);
        end
        
        y_ds.fore(t_use,i) = [1.0 X_city(t_use,pred)] * stats_i.beta;
      
    end
    
    y_ds.fore_naive(t_use,1) = mean(X_city(1:t_use, 1 ) );           % naive: historical mean
    y_ds.fore_naive(t_use,2) = X_city(t_use, 1 );                    % naive: lagged return
    
    y_ds.fore_combo(t_use,1) = 1/N_pred* sum(y_ds.fore(t_use,:)) ;   % forecast combo: average weight
    y_ds.fore_combo(t_use,2) =  median( y_ds.fore(t_use,:) );        % forecast combo: median
    
    y_1f_sort = sort( y_ds.fore(t_use,:) );
    y_ds.fore_combo(t_use,3) = mean(y_1f_sort(2:end-1) );            % forecast combo: truncate mean
    
    weights2 = zeros(N_pred,1);
    
    if t_use >= (t_begin + h_hold)   %t_use >= (t_begin + h_step)
        y_ds.valid(t_use) = 1;
        for i=1:N_pred
            err2_cum(i) = sum( (y_city(t_begin:t_est) - y_ds.fore(t_begin:t_est,i)).^2 );
        end
        
        for i=1:N_pred
            weights2(i) = (  err2_cum(i)^-1 ) / sum( err2_cum .^ -1 );
        end
        
        y_ds.fore_combo(t_use,4) = y_ds.fore(t_use,:) * weights2;
        
        [ ~, idx ] = sort( err2_cum );
        y_ds.fore_combo(t_use, 5) = mean( y_ds.fore(t_use, idx(1:4) ) );
        
        for i=1:N_pred
            y_ds.fore_RMSE(t_use,i) = rmse( y_city(t_begin + h_step:t_use), y_ds.fore(t_begin + h_step:t_use,i) );
        end
        
        for i=1:N_naive
            y_ds.fore_naive_RMSE(t_use,i) = rmse( y_city(t_begin + h_step:t_use), y_ds.fore_naive(t_begin + h_step:t_use,i) );
        end
        
        for i=1:N_combo
            y_ds.fore_combo_RMSE(t_use,i) = rmse( y_city(t_begin + h_step:t_use), y_ds.fore_combo(t_begin + h_step:t_use,i) );
        end
    end
end

y_res =  [ y_ds.fore_RMSE(t_end,:) y_ds.fore_naive_RMSE(t_end,:) y_ds.fore_combo_RMSE(t_end,:)]';

end


function r=rmse(data,estimate)
% Function to calculate root mean square error from a data vector or matrix 
% and the corresponding estimates.
% Usage: r=rmse(data,estimate)
% Note: data and estimates have to be of same size
% Example: r=rmse(randn(100,100),randn(100,100));

% delete records with NaNs in both datasets first
I = ~isnan(data) & ~isnan(estimate); 
data = data(I); estimate = estimate(I);

r=sqrt(sum((data(:)-estimate(:)).^2)/numel(data));

end

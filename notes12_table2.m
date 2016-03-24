%{
notes12_table2.m

input: city, dataset, flag, gamma
output: forecast, forecast combo, RMSE, portfolio weights
%}
% heart of the project
% main input should be a particular city
%main output should be AR RMSE, and RMSE of each predictor and combination
% relative to the passed in RMSE
function [ y_city, y_1f, y_1f_RMSE, y_1f_combo, y_1f_combo_RMSE, sharpe_ratio, util, port_ret, x_opt_store ] = ...
    notes12_table2( city_id, ds_use, flag, mu_h_flag, mv_gamma )

save('notes12_table2_save.mat');

%% construct city-unique dataset
%city_id = 2;

h_step = 4; 
h_hold = 4; % holdout period
%t_begin = 20;
t_begin = 45;
%t_begin = 45;
%t_begin = 60;

idx_use = and ( ( ds_use.YEAR >= 1988) , (ds_use.YEAR <= 2012 ) );
idx_use2 = (ds_use.city_id == city_id) ;  % set == 6 for LAX
idx_use = min(idx_use, idx_use2);

year_use = ds_use.YEAR(idx_use2);

if flag
    X_city = [ds_use.RET(idx_use) ...
        ds_use.RP(idx_use) ds_use.PI_ratio(idx_use) ...
        ds_use.risk_idx(idx_use) ./ ds_use.risk_idx2(idx_use) ...
        ds_use.risk_idx(idx_use) ...%ds_use.risk_idx2(idx_use) ... 
        ds_use.APR(idx_use) ds_use.POPCHG(idx_use) ds_use.PCICHG(idx_use) ...
        ds_use.NU2POP(idx_use) ds_use.EMPCHG(idx_use) ...
        ds_use.LFCHG(idx_use) ds_use.URATE(idx_use) ...
        ds_use.spy_ret(idx_use) ds_use.spy_yield(idx_use)];    
else
    %X_city = [ds_use.RET(idx_use)];
        X_city = [ds_use.RET(idx_use) ...
        ds_use.RP(idx_use) ds_use.PI_ratio(idx_use) ...
        ds_use.APR(idx_use) ds_use.POPCHG(idx_use) ds_use.PCICHG(idx_use) ...
        ds_use.NU2POP(idx_use) ds_use.EMPCHG(idx_use) ...
        ds_use.LFCHG(idx_use) ds_use.URATE(idx_use) ...
        ds_use.spy_ret(idx_use) ds_use.spy_yield(idx_use)];
end

%%
X_apr = ds_use.APR(idx_use);
X_rp = ds_use.RP(idx_use);
X_spy_ret = ds_use.spy_ret(idx_use);
X_spy_ret_fut = ds_use.spy_ret_fut(idx_use);
X_spy_yield = ds_use.spy_yield(idx_use);
y_city_fut = ds_use.RET_fut(idx_use);
y_city = ds_use.RET_fut(idx_use);
%y_city = ds_use.RET(idx_use);
%y_city = ds_use.RET_fut(idx_use);

%% construct estimation period; estimate then evaluate benchmark
N_pred = size(X_city,2);                               % number of predictors to use (including bench); bench will be index 1

N_naive = 2;
N_combo = 5;

y_1f = zeros(length(y_city), N_pred + N_naive );       % store y 1-step forecast
y_1f_RMSE = zeros(length(y_city), N_pred + N_naive);

y_1f_combo = zeros(length(y_city), N_combo );          % store y 1-step forecast combinations
y_1f_combo_RMSE = zeros(length(y_city), N_combo);

y_1f_combo_var = zeros(length(y_city), 1 );
%mv_gamma = 4; %2; %4; %8;  %4;
risk_weight = zeros(length(y_city), 1 );
port_ret = zeros(length(y_city), 1 );

err2_cum = zeros(N_pred + N_naive, 1);
x_opt_store = zeros( length(y_city) ,4);
%%
%for t_use = t_begin : (t_begin + 10)
t_end = length(y_city)- h_step;
%t_end = 80;
%for t_use = t_begin : ( length(y_city)- h_step )
for t_use = t_begin : t_end
    %disp(t_use);
    t_est = t_use - h_step;  % 1-step forecast; 
    
    %%
    for i=1:N_pred  % generate the simple predictors 
        pred = unique([1 i]);
        
        if false % this version uses SIC to select variable lags
            [beta_sic, lags1_opt, lags2_opt] = gen_beta_sic(y_city(1:t_est),X_city(1:t_est,pred));
            if ( size(pred,2) == 2 )
                X_lag_mat = [ lagmatrix(X_city(1:t_use,1),(0:lags1_opt)) lagmatrix(X_city(1:t_use,i),(0:lags2_opt)) ];
            else
                X_lag_mat = lagmatrix(X_city(1:t_use,1),(0:lags1_opt));
            end
            X_use2 = X_lag_mat(t_use,:);
            y_1f(t_use,i) = [1.0 X_use2] * beta_sic;
            
            %if true %or(lags1_opt >0, lags2_opt>0)
            %if ( mod(t_use,10) == 0 )
            %    disp([i lags1_opt, lags2_opt]);
            %end
        else    % this version uses fixed lags
            stats_i = regstats(y_city(1:t_est),X_city(1:t_est,pred),'linear');
            y_1f(t_use,i) = [1.0 X_city(t_use,pred)] * stats_i.beta;
        end
        %% impose min / max returns
        y_1f(t_use,i) = max( y_1f(t_use,i), -1.0 );
        y_1f(t_use,i) = min( y_1f(t_use,i), 1.0 );
        
    end  
    %%
    y_1f(t_use, N_pred + 1) = mean(X_city(1:t_use, 1 ) );        %naive: historical mean
    y_1f(t_use, N_pred + 2) = X_city(t_use, 1 );                 %naive: lagged ret 
    %y_1f(t_use, N_pred + 1) = mean(X_city(1:t_est, 1 ) );       %naive: historical mean
    %y_1f(t_use, N_pred + 2) = X_city(t_est, 1 );                %naive: lagged ret 
    
    y_1f_combo(t_use, 1) = 1/N_pred* sum(y_1f(t_use,:)) ;        %forecast combo: average weight 
    y_1f_combo(t_use, 2) = median( y_1f(t_use,:) );              %forecast combo: median
    
    y_1f_sort = sort( y_1f(t_use,:) );
    y_1f_combo(t_use, 3) = mean(y_1f_sort(2:end-1) );            %forecast combo: truncate mean
    
    weights2 = zeros(N_pred + N_naive,1);
    
    % new code here
    if t_use >= (t_begin + h_hold)   %t_use >= (t_begin + h_step)
        for i=1:( N_pred + N_naive )
            %err2_cum(i) = sum( (y_city(t_begin:t_use) - y_1f(t_begin:t_use,i)).^2 );
            %err2_cum(i) = sum( (y_city(t_begin:t_est) - y_1f(t_begin:t_est,i)).^2 );
            err2_cum(i) = sum( (y_city(t_begin:t_est) - y_1f(t_begin:t_est,i)).^2 );
            
            %beta_mult = .98 .^( (t_est - t_begin + 1) : -1: 1 );
            %err2_cum(i) = sum( beta_mult.* (y_city(t_begin - h_step:t_est - h_step) - y_1f(t_begin:t_est,i)).^2 );
        end
    end
    
    %if t_use >= (t_begin + 1)
    if t_use >= (t_begin + h_hold) %t_use >= (t_begin + h_step)
        for i=1:( N_pred + N_naive )
            weights2(i) = (  err2_cum(i)^-1 ) / sum( err2_cum .^ -1 );
        end
        
        y_1f_combo(t_use, 4) = y_1f(t_use,:) * weights2;
        
        [ val, idx ] = sort( err2_cum );
        y_1f_combo(t_use, 5) = mean( y_1f(t_use, idx(1:4) ) );
    
    end
    
    if t_use >= (t_begin + h_hold) %t_use >= (t_begin + h_step)
        for i=1:(N_pred + N_naive)
            %y_1f_RMSE(t_use,i) = rmse( y_city(t_begin:t_use), y_1f(t_begin:t_use,i) );
            y_1f_RMSE(t_use,i) = rmse( y_city(t_begin + h_step:t_use), y_1f(t_begin + h_step:t_use,i) );
        end
        
        for i = 1:N_combo
            y_1f_combo_RMSE(t_use,i) = rmse( y_city(t_begin + h_step:t_use), y_1f_combo(t_begin + h_step:t_use,i) );
            %y_1f_combo_var(t_use,i)
        end
        
         rf = .01;
         %y_1f_combo_var(t_use, 1) = ...
         %    var( y_city(t_begin + h_step:t_use) - y_1f_combo(t_begin + h_step:t_use,4) - rf  );

         i_combo_use = 4;
         y_1f_combo_var(t_use, 1) = ...
             var( y_city(t_begin + h_step:t_use) - y_1f_combo(t_begin + h_step:t_use,i_combo_use) - .5*X_apr(t_begin + h_step:t_use ) );

         
         %risk_weight(t_use) = 1 / mv_gamma * y_1f_combo(t_use,4) / y_1f_combo_var(t_use, 1)  ;
         %risk_weight(t_use) = 1 / mv_gamma * (y_1f_combo(t_use,4) - rf ) / y_1f_combo_var(t_use, 1)  ;
         %risk_weight(t_use) = 1 / mv_gamma * (y_1f_combo(t_use,4) - .5*X_apr(t_use) ) / y_1f_combo_var(t_use, 1)  ;
         risk_weight(t_use) = 1 / mv_gamma * (.95*y_1f_combo(t_use,i_combo_use) + .9*X_rp(t_use) - .5*X_apr(t_use) ) / y_1f_combo_var(t_use, 1)  ;
         risk_weight(t_use) = min(risk_weight(t_use), 10.0 );
         risk_weight(t_use) = max(risk_weight(t_use), 0.0 );
         
         %X_apr = ds_use.APR(idx_use);
         %X_rp = ds_use.RP(idx_use);
         %X_spy_ret_fut = ds_use.spy_ret_fut(idx_use);
         %X_spy_yield = ds_use.spy_yield(idx_use);
         %y_city_fut = ds_use.RET_fut(idx_use);
         %y_city = ds_use.RET_fut(idx_use);
         %MU = [.07 .20 .02 .0]';   % stocks, house, mortgage
         y_1f_var_est = ( y_city(t_begin + h_step:t_use) - y_1f_combo(t_begin + h_step:t_use,i_combo_use)  );
         spy_var_est = X_spy_ret(t_begin + h_step:t_use);
         
         y_1f_var_est = y_city(1:t_use)  ;
         spy_var_est = X_spy_ret(1:t_use);
         OMEGA_tmp = cov([spy_var_est, y_1f_var_est]); 
         OMEGA = zeros(4,4);
         OMEGA(1:2,1:2) = OMEGA_tmp;
         
         mu_x = .065; % + X_spy_yield(t_use);
         t_cost = .00; 
         %mu_h = .95*y_1f_combo(t_use,i_combo_use) + .9*X_rp(t_use);
         %mu_h = .8*y_1f_combo(t_use,i_combo_use) + .8*X_rp(t_use);
         mu_h = y_1f_combo(t_use,i_combo_use) + X_rp(t_use) - t_cost;
        
         if ( mu_h_flag == 0 )
             mu_h = 0;
         end
         
         mu_apr = .8*X_apr(t_use);
         mu_rf = 0.0; %.5*mu_apr;
         MU = [mu_x mu_h mu_apr mu_rf ]';
         %OMEGA = [.22 .01 .0 .0; 
         %        .01 .04 .0 .0; 
         %          .0 .0 .0 .0;
         %        .0 .0 .0 .0;];
         x_opt = gen_MVw( MU, OMEGA, mv_gamma );
         x_opt_store(t_use,:) = x_opt;
         
         %{  
            imagine something like this: 
            MU as above (ex-ante returns)
            ret_MU = MU;
            ret_realized = [.01 .04 .05 .02 ];
            port_ret(t_use) = x_opt * ret_realized;
            so it looks like i need: stock returns and future stock
            returns; might as well get dividend yield
         %}
         
         %port_ret(t_use) = risk_weight(t_use) * y_city(t_use) + ( 1.0 - risk_weight(t_use) )*.5*X_apr(t_use) ;
         ret_exante = [X_spy_ret_fut(t_use) + X_spy_yield(t_use), y_city(t_use) + X_rp(t_use) - .15, .7*X_apr(t_use), .5*X_apr(t_use)    ];
         
         %if ( flag == 0 )
         %    x_opt = [1 0 0 0];             
         %end
         port_ret(t_use) = x_opt * ret_exante';
         %port_ret(t_use) = risk_weight(t_use) * ( .95*y_city(t_use) + .9*X_rp(t_use) ) + ( 1.0 - risk_weight(t_use) )*.5*X_apr(t_use) ;
    end
    
end

sharpe_ratio = mean( port_ret(45:t_end) ) / ( std( port_ret(45:t_end) )  );
util = mean( port_ret(45:t_end) ) - mv_gamma / 2 *  var( port_ret(45:t_end) ) ;

end


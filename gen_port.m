%{
gen_port.m

use home price forecast to generate portfolio weights
evaluate portfolio

input: city, dataset, flag, gamma
output: forecast, forecast combo, RMSE, portfolio weights

port_ds should include:
sharpe_ratio, util, port_ret, x_opt_store

Copyright A. Michael Sharifi 2016
%}
function [ port_ds ] = gen_port(param, city_id, ds_use, y_ds, mu_h_flag, mv_gamma )
addpath('results');
save('results/gen_port_save');

%%
i_combo_use = param.i_combo_use;
port_ds = dataset;
port_ds.mean_est = zeros(length(y_ds),1);
port_ds.std_est = zeros(length(y_ds),1);
port_ds.sharpe_ratio = zeros(length(y_ds),1);
port_ds.sharpe_ratio = zeros(length(y_ds),1);
port_ds.util = zeros(length(y_ds),1);
port_ds.port_ret = zeros(length(y_ds),1);
port_ds.x_opt = zeros(length(y_ds),5);
port_ds.valid = zeros(length(y_ds),1);

idx_use = all ([ ds_use.city_id == city_id, ds_use.YEAR >= param.year_beg , ds_use.YEAR <= param.year_end ] ,2 );
X_rp = ds_use.RP(idx_use);
X_spy_ret = ds_use.spy_ret(idx_use);
X_spy_ret_fut = ds_use.spy_ret_fut(idx_use);
X_spy_yield = ds_use.spy_yield(idx_use);

%% adding new stuff here!
X_inf_exp = ds_use.inf_exp(idx_use);
X_inf_act = ds_use.inf_act(idx_use);

X_apr = param.mort_eff .* ds_use.apr30yr(idx_use);
X_bond = ds_use.tbond10yr(idx_use);
X_bill = ds_use.tbill1yr(idx_use);

%%
t_begin = find(y_ds.valid,1,'first');
t_end = find(y_ds.valid,1,'last');

h_step = param.h_step;
mu_h = 0;
%mu_x = .065; % + X_spy_yield(t_use);
%t_cost = .00;
%OMEGA = zeros(4,4);

%%
for t_use = (t_begin + h_step + 1) : t_end
    t_est = t_use - h_step;
    port_ds.valid(t_use) = 1;
    
    %% adding work here
    % home price process and residuals
    y_exp = y_ds.fore_combo(t_begin:t_est, i_combo_use) + X_rp(t_begin:t_est) - param.tau - X_inf_exp(t_begin:t_est);
    y_act = y_ds.RET_fut(t_begin:t_est) + X_rp(t_begin:t_est ) - param.tau - X_inf_act(t_begin:t_est);
    y_resid = y_act - y_exp;
    
    % mortgage process and residuals
    mort_exp = X_apr(t_begin:t_est) - X_inf_exp(t_begin:t_est);    % observed mortgage rate - expected inflation
    mort_act = X_apr(t_begin:t_est) - X_inf_act(t_begin:t_est);    % observed mortgage rate - actual inflation
    mort_resid = mort_act - mort_exp;
    
    % stock return process and residuals
    spy_exp = mean(X_spy_ret)*ones(size(y_exp)) + X_spy_yield(t_begin:t_est) - X_inf_exp(t_begin:t_est);
    spy_act = X_spy_ret(t_begin:t_est) + X_spy_yield(t_begin:t_est) - X_inf_act(t_begin:t_est);
    spy_resid = spy_act - spy_exp;
    
    % tbond process and residuals
    tbond_exp = X_bond(t_begin:t_est) - X_inf_exp(t_begin:t_est);   % tfor now: assume tbill rate is around morgage rate; tbill rate - expected inflation
    tbond_act = X_bond(t_begin:t_est) - X_inf_act(t_begin:t_est);    % tbill rate - realized inflation
    tbond_resid = tbond_act - tbond_exp;
    
    % tbill process and residuals
    tbill_exp = X_bill(t_begin:t_est) - X_inf_exp(t_begin:t_est);   % tfor now: assume tbill rate is around morgage rate; tbill rate - expected inflation
    tbill_act = X_bill(t_begin:t_est) - X_inf_act(t_begin:t_est);    % tbill rate - realized inflation
    tbill_resid = tbill_act - tbill_exp;
   
    % estimate covariance
    OMEGA = cov([y_resid, mort_resid, spy_resid, tbond_resid, tbill_resid  ]);
    
    %%
    if ( mu_h_flag >= 1 )  % enter current year home price forecast
        mu_h = y_ds.fore_combo(t_use,i_combo_use) + X_rp(t_use) - param.tau - X_inf_exp(t_use);
    end
    
    mu_apr =  X_apr(t_use) - X_inf_exp(t_use);
    mu_spy = mean(ds_use.spy_ret(1:t_use)) - X_inf_exp(t_use);
    mu_tbond = X_bond(t_use) - X_inf_exp(t_use);
    mu_tbill = X_bill(t_use) - X_inf_exp(t_use);
   
    MU = [mu_h mu_apr mu_spy mu_tbond mu_tbill ]';
    
    port_ds.x_opt(t_use,:) = gen_MVw( MU, OMEGA, mv_gamma, param.H_MAX );
    
    ret_exante = [  y_ds.RET_fut(t_use) + X_rp(t_use) - X_inf_act(t_use) , ...
                    X_apr(t_use) - X_inf_act(t_use), ...
                    X_spy_ret_fut(t_use) + X_spy_yield(t_use) - X_inf_act(t_use), ...
                    X_bond(t_use) - X_inf_act(t_use), ...
                    X_bill(t_use) - X_inf_act(t_use)];
    
    port_ds.port_ret(t_use) = port_ds.x_opt(t_use,:) * ret_exante';
    
    idx_use2 = (port_ds.valid == 1);
    port_ds.mean_est(t_use) = mean( port_ds.port_ret(idx_use2) );
    port_ds.std_est(t_use) = std( port_ds.port_ret(idx_use2) );
    port_ds.sharpe_ratio(t_use) = port_ds.mean_est(t_use) / port_ds.std_est(t_use);
    port_ds.util(t_use) = port_ds.mean_est(t_use) - mv_gamma / 2.0 * port_ds.std_est(t_use).^2;

    port_ds.util(t_use) = mean( port_ds.port_ret(idx_use2) ) - mv_gamma / 2.0 * var( port_ds.port_ret(idx_use2) ) ;
end

end



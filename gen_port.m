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
save('gen_weights_save');

%%
port_ds = dataset;
port_ds.mean_est = zeros(length(y_ds),1);
port_ds.std_est = zeros(length(y_ds),1);
port_ds.sharpe_ratio = zeros(length(y_ds),1);
port_ds.sharpe_ratio = zeros(length(y_ds),1);
port_ds.util = zeros(length(y_ds),1);
port_ds.port_ret = zeros(length(y_ds),1);
port_ds.x_opt = zeros(length(y_ds),4);
port_ds.valid = zeros(length(y_ds),1);

rf = .01;
i_combo_use = 4;

idx_use = all ([ ds_use.city_id == city_id, ds_use.YEAR >= param.year_beg , ds_use.YEAR <= param.year_end ] ,2 );
X_apr = ds_use.APR(idx_use);
X_rp = ds_use.RP(idx_use);
X_spy_ret = ds_use.spy_ret(idx_use);
X_spy_ret_fut = ds_use.spy_ret_fut(idx_use);
X_spy_yield = ds_use.spy_yield(idx_use);

t_begin = find(y_ds.valid,1,'first');
t_end = find(y_ds.valid,1,'last');

h_step = 4;
mu_h = 0;
mu_x = .065; % + X_spy_yield(t_use);
t_cost = .00;
OMEGA = zeros(4,4);

%%
for t_use = (t_begin + h_step + 1) : t_end
    port_ds.valid(t_use) = 1;
    
    %compute home price forecast error variance
    y_1f_var_est = ( y_ds.RET_fut(t_begin:t_use) - y_ds.fore_combo(t_begin:t_use, i_combo_use) );
    spy_var_est = X_spy_ret(t_begin:t_use);
    
    OMEGA(1:2,1:2) = cov([spy_var_est, y_1f_var_est]);
    
    if ( mu_h_flag >= 1 )
        mu_h = y_ds.fore_combo(t_use,i_combo_use) + X_rp(t_use) - t_cost;
    end
    
    mu_apr = .8*X_apr(t_use);
    mu_rf = 0.0; %.5*mu_apr;
    MU = [mu_x mu_h mu_apr mu_rf ]';
    
    port_ds.x_opt(t_use,:) = gen_MVw( MU, OMEGA, mv_gamma );
    
    ret_exante = [X_spy_ret_fut(t_use) + X_spy_yield(t_use), ...
        y_ds.RET_fut(t_use) + X_rp(t_use) , ...
        .7*X_apr(t_use), .5*X_apr(t_use) ];
    
    port_ds.port_ret(t_use) = port_ds.x_opt(t_use,:) * ret_exante';
    
    idx_use2 = (port_ds.valid == 1);
    port_ds.mean_est(t_use) = mean( port_ds.port_ret(idx_use2) );
    port_ds.std_est(t_use) = std( port_ds.port_ret(idx_use2) );
    port_ds.sharpe_ratio(t_use) = port_ds.mean_est(t_use) / port_ds.std_est(t_use);
    port_ds.util(t_use) = port_ds.mean_est(t_use) - mv_gamma / 2.0 * port_ds.std_est(t_use).^2;

    port_ds.util(t_use) = mean( port_ds.port_ret(idx_use2) ) - mv_gamma / 2.0 * var( port_ds.port_ret(idx_use2) ) ;
end

end



%{
gen_weights.m

use home price forecast to generate portfolio weights
evaluate portfolio

input: city, dataset, flag, gamma
output: forecast, forecast combo, RMSE, portfolio weights

port_ds should include:
sharpe_ratio, util, port_ret, x_opt_store
%}

function [ port_ds ] = gen_weights(param, city_id, ds_use, y_ds, mu_h_flag, mv_gamma )

addpath('results');
save('results/gen_weights_save');
h_step = param.h_step;

%%TODO: add code for actual inflation and expected inflation
%%
port_ds = dataset;
port_ds.sharpe_ratio = zeros(100,1);
port_ds.util = zeros(100,1);
port_ds.port_ret = zeros(100,1);
port_ds.x_opt = zeros(100,4);
port_ds.valid = zeros(100,1);

y_1f_combo_var = zeros(100,1);
x_opt_store = zeros( length(y_ds) ,4);
rf = .01;
i_combo_use = 4;

idx_use = all ([ ds_use.city_id == city_id, ds_use.YEAR >= 1988 , ds_use.YEAR <= 2012 ] ,2 );
X_apr = ds_use.APR(idx_use);
X_rp = ds_use.RP(idx_use);
X_spy_ret = ds_use.spy_ret(idx_use);
X_spy_ret_fut = ds_use.spy_ret_fut(idx_use);
X_spy_yield = ds_use.spy_yield(idx_use);

t_begin = find(y_ds.valid,1,'first');
t_end = find(y_ds.valid,1,'last');

%%
for t_use = (t_begin + h_step + 1) : t_end
    port_ds.valid(t_use) = 1;
   
    %y_1f_combo_var(t_use, 1) = ...
    %    var( y_ds.RET_fut(t_begin + h_step:t_use) - y_ds.fore_combo(t_begin + h_step:t_use,i_combo_use) - .5*X_apr(t_begin + h_step:t_use ) ); 
    
    y_1f_var_est = ( y_ds.RET_fut(t_begin:t_use) - y_ds.fore_combo(t_begin:t_use, i_combo_use) );
    %TODO: adjust all of these by inflation
    % home price process
    y_mean = y_ds.fore_combo(t_begin:t_use, i_combo_use) + X_rp(t_begin:t_use) - param.tau;
    y_act = y_ds.RET_fut(t_begin:t_use) + X_rp(t_begin:t_use ) - param.tau;
    y_resid = y_act - y_mean;
    
    % stock return process
    spy_mean = mean(X_spy_ret)*ones(size(y_mean));
    spy_act = X_spy_ret(t_begin:t_use);
    spy_resid = spy_act - spy_mean;
    
    % mortgage process
    mort_mean = X_apr(t_begin:t_use) - .02;    % observed mortgage rate - expected inflation
    mort_act = X_apr(t_begin:t_use) - .025;    % observed mortgage rate - actual inflation
    mort_resid = mort_act - mort_mean;    
    
    % tbill process
    tbill_mean = X_apr(t_begin:t_use) - .02;   % tfor now: assume tbill rate is around morgage rate; tbill rate - expected inflation
    tbill_act = X_apr(t_begin:t_use) - .01;    % tbill rate - realized inflation
    tbill_resid = tbill_act - tbill_mean;
    
    OMEGA_tmp3 = cov([spy_resid, y_resid, mort_resid, tbill_resid]);

    
    spy_var_est = X_spy_ret(t_begin:t_use); 
    
    h_ret_est = y_1f_var_est + X_rp(t_begin:t_use) - param.tau;  % impose mean process: from forecast
    spy_var_est = X_spy_ret(t_begin:t_use);                      
    mort_var_est = X_apr(t_begin:t_use);
    bond_var_est = X_apr(t_begin:t_use);
    
    % want OMEGA_tmp to include elements from mortgage rates and bond rates
    OMEGA_tmp = cov([spy_var_est, y_1f_var_est]);
    OMEGA_tmp2 = cov([spy_var_est, y_1f_var_est, bond_var_est, mort_var_est  ]);
    OMEGA = zeros(4,4);
    OMEGA(1:2,1:2) = OMEGA_tmp;
    OMEGA = OMEGA_tmp2;
    
    mu_x = .065; % + X_spy_yield(t_use);
    t_cost = .00;
    
    if ( mu_h_flag == 0 )
        mu_h = 0;
    else
        mu_h = y_ds.fore_combo(t_use,i_combo_use) + X_rp(t_use) - t_cost;
    end
    
    mu_apr = .8*X_apr(t_use);
    mu_rf = 0.0; %.5*mu_apr;
    MU = [mu_x mu_h mu_apr mu_rf ]';
   
    x_opt = gen_MVw( MU, OMEGA, mv_gamma );
    x_opt_store(t_use,:) = x_opt;
    disp(x_opt);
    port_ds.x_opt(t_use,:) = x_opt;
    ret_exante = [X_spy_ret_fut(t_use) + X_spy_yield(t_use), y_ds.RET_fut(t_use) + X_rp(t_use) , .7*X_apr(t_use), .5*X_apr(t_use)    ];

    port_ds.port_ret(t_use) = x_opt * ret_exante';
    
    idx_use2 = (port_ds.valid == 1);
    port_ds.sharpe_ratio(t_use) = mean( port_ds.port_ret(idx_use2) ) /  std( port_ds.port_ret(idx_use2) ) ;
    port_ds.util(t_use) = mean( port_ds.port_ret(idx_use2) ) - mv_gamma / 2.0 * var( port_ds.port_ret(idx_use2) ) ;
end

end

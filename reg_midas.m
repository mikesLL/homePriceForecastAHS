%{
reg_midas
Given variable of interest y, own observations X1 (quarterly), and
predictor variable X2 (quarterly), reg_midas

gen_fore calls this function
inputs:
X1: own observations ( quarters )
X2: predictor variable ( quarters )
note that theta always takes on 7 parameters
%}

function [ theta, lags1_opt, lags2_opt ] = reg_midas( y, X1, X2 )
addpath('diag');
save('diag/reg_midas_save');

options = optimset('MaxFunEvals', 10000);
coeff_alpha = 0.0;     % trad'l parameters
coeff_rho = 0.0;
coeff_beta = 0.0;
theta_a11 = .01;       % MIDAS: own almon params
theta_a12 = -.0099;
theta_a21 = .01;       % MIDAS: predictor-variable almon params
theta_a22 = -.0099;

% theta0: starting value
theta0 = [coeff_alpha; coeff_rho; coeff_beta; ...
    theta_a11; theta_a12; theta_a21; theta_a22;  ];

bic_min = inf;
lags1_opt = 1;
lags2_opt = 1;

%% cycle through lags in X1 and X2
for lags1 = 1:8
    for lags2 = 1:8
        % generate lagmatrix: current obs is already lagged relative to
        % independent variable
        X1_use = lagmatrix( X1, (0:(lags1-1) ) );
        X2_use = lagmatrix( X2, (0:(lags2-1) ) );
        
        % drop nan entries based on max lag
        t_begin = max( lags1+1, lags2+1 );  
        X1_use = X1_use( t_begin:end, :);
        X2_use = X2_use( t_begin:end, :);
        y_use = y(t_begin:end);
        
        % numerically solve for theta
        [theta, rss] = ...
            fminsearch( @(theta) f_almon(theta, y_use, X1_use, X2_use, lags1, lags2 ), theta0, options );
        
        % calc bayesian information criterion
        n = length(y_use);
        k = 7;
        bic = n*log(rss/n) + k*log(n);
        
        % search for min bic
        if bic < bic_min
            bic_min = bic;
            lags1_opt = lags1;
            lags2_opt = lags2;
        end
    end
end

disp( [lags1_opt, lags2_opt] );
disp( bic_min );
end

%disp( [lags1_opt, lags2_opt] );
%disp( bic_min );


%{
%%
% first example
lags1 = 7;   % lags in own variable
lags2 = 3;   % lags in predictor variable

X1_use = lagmatrix( X1, (0:lags1) );
X2_use = lagmatrix( X2, (0:lags2) );

t_begin = max( lags1+1, lags2+1 );  % drop nan entries based on max lag
X1_use = X1_use( t_begin:end, :);
X2_use = X2_use( t_begin:end, :);
y_use = y(t_begin:end);

% free parameters
coeff_alpha = 0.0;     % trad'l parameters
coeff_rho = 0.0;
coeff_beta = 0.0;
theta_a11 = .01;       % MIDAS: own almon params
theta_a12 = -.0099;
theta_a21 = .01;       % MIDAS: predictor-variable almon params
theta_a22 = -.0099;

% theta: collect all free parameters
theta = [coeff_alpha; coeff_rho; coeff_beta; ...
    theta_a11; theta_a12; theta_a21; theta_a22;  ];

theta0 = theta;

options = optimset('MaxFunEvals', 10000);
[foo, val] = ...
    fminsearch( @(theta) f_almon(theta, y_use, X1_use, X2_use, lags1, lags2 ), theta0, options );

theta_a11 = foo(4);
theta_a12 = foo(5);
theta_a21 = foo(6);
theta_a22 = foo(7);
%}

%a1 = exp( theta_a11*(1:l1) + theta_a12*( (1:l1).^2 ) );
%w1 = a1 ./ sum(a1);

%a2 = exp( theta_a21*(1:l2) + theta_a22*( (1:l2).^2 ) );
%w2 = a2 ./ sum(a2);

%stats = regstats(y_use, [X1_use, X2_use]);
%stats_midas = reg_midas_param(y_use, X1_use, X2_use );

%{
for lags1 = 1:8
    for lags2 = 1:8
        %X1_use = lagmatrix( X1,[0:lags1] );
        %X2_use = lagmatrix(
    end
end
%}



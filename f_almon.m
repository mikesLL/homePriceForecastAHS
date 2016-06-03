%{
f_almon.m
inputs: 
theta: MIDAS regression parameters
y_use: 
%}

function [ rss, y_hat ] = f_almon( theta, y_use, X1_use, X2_use, lags1, lags2 )
%function [ y_hat ] = f_almon( theta, y_use, X1_use, X2_use, lags1, lags2 )


coeff_alpha = theta(1);  % retrieve parameters
coeff_rho = theta(2);
coeff_beta = theta(3);

theta_a11 = theta(4);
theta_a12 = theta(5);
theta_a21 = theta(6);
theta_a22 = theta(7);

l1 = lags1; % size(X1_use,2);  % calc lags in each X
l2 = lags2; % size(X2_use,2);

%l1 = lags1 + 1; % size(X1_use,2);  % calc lags in each X
%l2 = lags2 + 1; % size(X2_use,2);

a1 = exp( theta_a11*(1:l1) + theta_a12*( (1:l1).^2 ) );
w1 = a1 ./ sum(a1);

a2 = exp( theta_a21*(1:l2) + theta_a22*( (1:l2).^2 ) );
w2 = a2 ./ sum(a2);

A = X1_use * w1';
B = X2_use * w2';

y_hat = coeff_alpha + coeff_rho*A + coeff_beta*B;

rss = sum( (y_use - y_hat).^2 );   % residual sum squares

end


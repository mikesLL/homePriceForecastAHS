%{
gen_MVw.m

Copyright A. Michael Sharifi, 2016
%}

function [ x_opt ] = gen_MVw( MU, OMEGA, mv_GAMMA, H_MAX )

x0 = [.25 .25 .25 .25 .25]; % initial guess
fun = @(x) - (x*MU - mv_GAMMA / 2 * x * OMEGA * x'); % mean-variance objective fn

% Ax <= b constraints
A = [  -1 0 0 0 0; % house min
       1 0 0 0 0;  % house max
       -.8 -1 0 0 0; % mort min determined by x_h
       0 1 0 0 0; % mort max
       0 0 -1 0 0;  % stock min
       0 0 1 0 0;  % stock max
       0 0 0 -1 0; % tbond min
       0 0 0 0 -1; % tbill min
       1 1 1 1 1; ];
   
b = [ 0;  % house min
      8; % house max
      0;  % mort min
      0;  % mort max
      0;  % stock min
      1;  % stock max
      0;  % tbond min
      0;  % tbill min
      1; ];

opts = optimset('Display', 'off', 'Algorithm', 'active-set');
x_opt = fmincon(fun,x0,A,b,[],[],[],[],[],opts);

end


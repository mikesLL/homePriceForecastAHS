%{
gen_MVw.m
Input: MU (vector of expected returns), OMEGA( variance-covariance
matrix), mv_GAMMA (stdev preference weight), H_MAX (housing leverage constraint)
Output: x_opt (optimal risky asset weights)
Copyright A. Michael Sharifi, 2016
%}

function [ x_opt ] = gen_MVw( MU, OMEGA, mv_GAMMA, H_MAX, mu_h_flag )

x0 = [.25 .25 .25 .25 ]; % initial guess
fun = @(x) - (x*MU - mv_GAMMA / 2.0 * x * OMEGA * x'); % mean-variance objective fn

if mu_h_flag == 0
    H_MAX = 0.0;
end
    
% Ax <= b constraints
A = [  -1 0 0 0 ; % house min
        1 0 0 0 ;  % house max
      -.8 0 -1 0; % mort min determined by x_h
       0 0 1 0  ; % mort max
       0  -1 0 0 ;  % stock min
       0  1 0 0 ;  % stock max
       0 0 0 -1; % tbill min
       1 1 1 1 ; ];


b = [ 0;  % house min
      H_MAX; % house max
      0;  % mort min
      0;  % mort max
      0;  % stock min
      1;  % stock max
      0;  % tbill min
      1; ];

opts = optimset('Display', 'off', 'Algorithm', 'active-set');
x_opt = fmincon(fun,x0,A,b,[],[],[],[],[],opts);

end


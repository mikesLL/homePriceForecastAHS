%{
gen_param.m
load parameters

%}
function [ param ] = gen_param

param.CFUSE =  'DCFP'; %'CFP'; %'DCFP';  % = 'CFP';
param.LTI = .35;        % may want to load up an estimate of this; time-varying LTI?
param.max_mult = 40;
param.min_mult = 10;
param.Y_CC = 50000;

param.year_beg = 1988;
param.year_end = 2014;

param.tau = 0.06; %.15; % represents transactions costs
param.h_step = 4; % quarters; = 4 for 1 year and = 8 for 2 years
param.H_MAX = 10;
param.i_combo_use = 4;
param.mort_eff = .65;      % effective mortgage rate after interest tax deduction

end


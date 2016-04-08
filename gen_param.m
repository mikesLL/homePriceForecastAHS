%{
gen_param.m
load parameters

Copyright A. Michael Sharifi, 2016
%}
function [ param ] = gen_param

param.LTI = .35;        % impose maximum mortgage payment to income
param.Y_CC = 50000;

param.year_beg = 1988;
param.year_end = 2014;

param.tau = 0.06; % represents transactions costs
param.h_step = 4; % quarters; = 4 for 1 year and = 8 for 2 years
param.H_MAX = 10; % maximum house to net worth
param.i_combo_use = 4;
param.mort_eff = .66;      % effective mortgage rate after interest tax deduction

param.mv_gamma = 4;
end


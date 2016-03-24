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
end


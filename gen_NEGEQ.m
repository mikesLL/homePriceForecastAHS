%{
gen_NEGEQ.m

Copyright A. Michael Sharifi
%}

function [ WCF, N_dcfp, N_cfp, N_negeq_cfp, N_negeq_cfn ] = gen_NEGEQ(param, a2_ds )

%save('gen_NEGEQ_save');

TERM = a2_ds.TERM;
YRMOR = a2_ds.YRMOR;
AMMORT = a2_ds.AMMORT;
%a2_ds.RUNITS = max(a2_ds.RUNITS, .5);
%a2_ds.RUNITS = min(a2_ds.RUNITS, 1.5);

PMT = 12* a2_ds.PMT ./ a2_ds.RUNITS;
PMT2 = 12.0 .* a2_ds.PMT;

%a2_ds.INT = a2_ds.PMT ./ a2_ds.AMMORT;

CURR_YEAR = param.CURR_YEAR;

rent = .8*param.P_HR;
rent_i = a2_ds.VALUE ./ param.med_val .* rent;
%rent = .6*param.P_HR;

%T_LEFT = max(YRMOR + TERM - CURR_YEAR, 0.0);
%T_INTO = min(CURR_YEAR - YRMOR, 0.0);
T_LEFT = max(YRMOR + TERM - CURR_YEAR, 0.0);
%T_INTO = min(CURR_YEAR - YRMOR, 0.0);
T_INTO = max( CURR_YEAR - YRMOR, 0.0 );

%delta1 = 1.01 /( 1 + param.APR + .02 );
delta1 = 1.02 /( 1 + .055 );
%delta1 = .98;

%delta1 = 1 /( 1 + .08 );
%delta1 = 1.02 / (1 + param.APR );

delta1_mult = 1/(1-delta1);
delta2_mult = ( 1 - delta1.^(T_LEFT + 1) )./(1-delta1);
delta3_mult = delta1.^(T_LEFT + 1) ./ (1-delta1);

%mbal_idx = (TERM > 0);
%mbal_done_idx = (TERM <= 0);

mbal_idx = or( (TERM > 0), (T_LEFT > 0) );
mbal_done_idx = or ( (TERM <= 0), (T_LEFT <= 0 ) );

WCF = zeros(size(PMT));
WCF(mbal_done_idx) = delta1_mult.*rent;
WCF(mbal_idx) = delta2_mult(mbal_idx).*(rent - PMT(mbal_idx)) + delta3_mult(mbal_idx).*rent ;

MBAL = AMMORT./a2_ds.RUNITS.*( 1 + max(a2_ds.INT, 0.0) ).^T_INTO - T_INTO.*PMT;

idx1_bal = ( T_LEFT > 0 ) ;

MBAL2 = zeros(size(MBAL));
MBAL2_tmp = MBAL2;
%MBAL2_tmp(idx1_bal) = AMMORT(idx1_bal) .*( 1.0 + max(a2_ds.INT(idx1_bal), 0.0) ).^T_INTO(idx1_bal) - T_INTO(idx1_bal).*PMT2(idx1_bal);
MBAL2_tmp(idx1_bal) = AMMORT(idx1_bal) .*( 1.0 + max(a2_ds.INTC(idx1_bal), 0.0) ).^T_INTO(idx1_bal) - T_INTO(idx1_bal).*PMT2(idx1_bal);

MBAL2 = MBAL2_tmp;

N_dcfp = sum( param.med_val >= MBAL );
N_cfp = sum( param.med_val >= MBAL );

% for now, this is a measure of the number of agents who are negative equity
N_dcfp = sum( a2_ds.VALUE >= MBAL2 );   
N_cfp = sum( a2_ds.VALUE >= MBAL2);

% we would be interested in the number of agents who are both negative
% equity and cash-flow positive; my guess is this may actually put upward
% pressure on home prices

% try something like:
N_negeq_cfp = sum(  all( [ a2_ds.VALUE < MBAL2, rent_i >= PMT2 ], 2 ) ); 
N_negeq_cfn = sum( all( [ a2_ds.VALUE < MBAL2, rent_i < PMT2 ], 2 ) ); 


end

%{
gen_micro_vars.m

want to compute:
1. Number negative equity homeowners
2. Number of homeowners who have paid off their homes


Copyright A. Michael Sharifi
%}

function [ N_negeq, N_paid_off ] = gen_micro_vars(param, a1_ds )

%save('gen_micro_vars_save');

TERM = a1_ds.TERM;
YRMOR_est = a1_ds.YRMOR_est;
AMMORT = a1_ds.AMMORT;

PMT = 12.0 .* a1_ds.PMT;
CURR_YEAR = param.CURR_YEAR;

T_LEFT = max(YRMOR_est + TERM - CURR_YEAR, 0.0);    % years left on mortgage
T_INTO = max( CURR_YEAR - YRMOR_est, 0.0 );             % years into mortgage

mbal_idx = ( T_LEFT > 0 ) ;

MBAL = zeros(size(TERM));                           % note that this imposes zeros MBAL if term is not found
MBAL(mbal_idx) = AMMORT(mbal_idx) .*( 1.0 + max(a1_ds.INT_est(mbal_idx), 0.0) ).^T_INTO(mbal_idx) - T_INTO(mbal_idx).*PMT(mbal_idx);

N_negeq = sum( a1_ds.VALUE < MBAL );                %  measure of the number of agents who are negative equity
N_paid_off = sum( MBAL == 0.0 );


end


%rent = .8*param.P_HR;
%rent_i = a1_ds.VALUE ./ param.med_val .* rent;      % individual rent
%MBAL2_tmp(idx1_bal) = AMMORT(idx1_bal) .*( 1.0 + max(a2_ds.INT(idx1_bal), 0.0) ).^T_INTO(idx1_bal) - T_INTO(idx1_bal).*PMT2(idx1_bal);


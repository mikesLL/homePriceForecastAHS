% calc_res_sale3: 
% must be consistent with the notes15 setup

%function [ WCF ] = gen_WCF(param, TERM, YRMOR_EST, BEDRMS, PMT,P_HR, CURR_YEAR, AMMORT )
function [ WCF, N_dcfp, N_cfp ] = gen_NEGEQ(param, a2_ds )

% want: N_negeg: the number of households with negative equity

%save('save_gen_NEGEQ');

int_tmp = a2_ds.INT( a2_ds.INT > 0.0 );

if ~isempty(int_tmp)
    if mean(int_tmp > 500.0)
        a2_ds.INT = 1.0 / 10000.0 * a2_ds.INT ;
    end
end

if isempty(int_tmp)
    a2_ds.INT = max( .01 * a2_ds.INTW + .0001* a2_ds.INTF, 0.0 );
end


%save('save_gen_WCF');
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
MBAL2_tmp(idx1_bal) = AMMORT(idx1_bal) .*( 1.0 + max(a2_ds.INT(idx1_bal), 0.0) ).^T_INTO(idx1_bal) - T_INTO(idx1_bal).*PMT2(idx1_bal);

MBAL2 = MBAL2_tmp;

N_dcfp = sum( param.med_val >= MBAL );
N_cfp = sum( param.med_val >= MBAL );

N_dcfp = sum( a2_ds.VALUE >= MBAL2 );
N_cfp = sum( a2_ds.VALUE >= MBAL2);

end

%idx_CFP = (rent >= PMT);
%ridx_CFN = (rent < PMT);

%WCF = rent - PMT;
%WCF(idx_CFP) = 1;
%WCF(idx_CFN) = -1;

%{
yr_PMT = 12.0*PMT;       % convert given monthly payment to yearly PMT

r_i = yr_PMT ./ AMMORT ;
%mbal = AMMORT;


%D = 1.04;
%D = 1.065; %1.05;  %1.04; %D = 1.07;

%% mods begin here!!!
r = param.APR;
PV = AMMORT;     % want this equal to purchase price
%n = 10;        % 10 years, 1 pmt per year
n = 30;        % 30 years, 1 pmt per year
%n = 15;

%yr_PMT2 = r*PV ./ ( 1 - (1 + r ).^-n );
yr_PMT2 = r_i.*PV ./ ( 1 - (1 + r_i ).^-n );
t_use = CURR_YEAR - YRMOR_EST;   % years since mortgage origination
t_left = max(n - t_use,0.0);
%t_left = max( 1.0*(YRMOR_EST + 3*10 - CURR_YEAR) + 0.0, 0.0);
%t_use = 10 - t_left;
%t_use = 30 - t_left;


delta2 = (1.0 + param.APR);
c2 = yr_PMT2;

mbal_idx = (t_use <= n);
%%
%t_use = 40;
%t_left = max(30 - t_use,0.0);
%mbal = mbal_idx.*AMMORT.*delta2.^t_use - c2.*(1.0 - delta2.^(t_use - 2) ) ./ ( 1- delta2);
mbal = mbal_idx.*AMMORT.*delta2.^t_use - c2.*(1.0 - delta2.^( t_use ) ) ./ ( 1- delta2);

%param.Disc = 1.055;
%delta1 = (1/D)/(1/param.GR);   % MOD HERE!
delta1 = 1/param.Disc;   % MOD HERE!

delta121 = param.GR(1)/param.Disc;
delta122 = param.GR(2)/param.Disc;
delta123 = param.GR(3)/param.Disc;

D_use1 = mbal_idx.*( 1.0 - delta1.^t_left ) ./ (1.0 - delta1 );
%D_use12 = mbal_idx.*( 1.0 - delta12.^t_left ) ./ (1.0 - delta12 );
D_use121 = mbal_idx.*( 1.0 - delta121.^t_left ) ./ (1.0 - delta121 );
D_use122 = mbal_idx.*( 1.0 - delta122.^t_left ) ./ (1.0 - delta122 );
D_use123 = mbal_idx.*( 1.0 - delta123.^t_left ) ./ (1.0 - delta123 );


D_use2 = delta1.^t_left.*1.0 ./ (1.0 - delta1) ;
%D_use22 = delta12.^t_left.*1.0 ./ (1.0 - delta12) ;
D_use221 = delta121.^t_left.*1.0 ./ (1.0 - delta121) ;
D_use222 = delta122.^t_left.*1.0 ./ (1.0 - delta122) ;
D_use223 = delta123.^t_left.*1.0 ./ (1.0 - delta123) ;


D_use3 = 1.0 / (1.0 - delta1 );
D_use321 = 1.0 / (1.0 - delta121 );
D_use322 = 1.0 / (1.0 - delta122 );
D_use323 = 1.0 / (1.0 - delta123 );
%D_use32 = 1.0 / (1.0 - delta12 );
%D_use32 = 1.0 / (1.0 - delta2 );

%rentA = max(rent - yr_PMT2,0.0);
%rentB = max(yr_PMT2 - rent, 0.0);

%sum01 = D_use1.*(rentA - 1.0*rentB)  + D_use2.*rent + mbal;
%sum02 = D_use3.*rent.*ones(size(mbal));

sum032 = 1/3*D_use121.*rent + 1/3*D_use122.*rent + 1/3*D_use123.*rent ...
    - D_use1.*yr_PMT2  + 1/3*D_use221.*rent + 1/3*D_use222.*rent + 1/3*D_use223.*rent;                  % AMMORTIZING MORTGAGE!

sum012 = sum032 + mbal;

sum022 = 1/3*D_use321*rent + 1/3*D_use322*rent + 1/3*D_use323*rent;
%sum03 = D_use1.*(rent - yr_PMT2)  + D_use2.*rent;
%sum032 = D_use12.*rent - D_use1.*yr_PMT2  + D_use22.*rent;                  % AMMORTIZING MORTGAGE!
%asum033 = D_use32*rent - D_use3*yr_PMT;


%sum03 = D_use1.*(rent - yr_PMT2)  + D_use2.*rent;
%sum03 = (rent - yr_PMT2);                                 %Cash Flow constraint
%sum01 = D_use1.*(rent - yr_PMT2)  + D_use2.*rent + mbal;
%sum012 = D_use12.*rent - D_use1.*yr_PMT2  + D_use22.*rent + mbal;
%sum013 =  D_use32*rent - D_use3*yr_PMT + mbal;


%sum02 = D_use3*rent;
%sum022 = D_use32*rent;

%idx03 = (sum03 >= 0.0);
%res_sale = idx03.*max(sum01, sum02) + (1 - idx03).*sum02;
idx03 = (sum032 >= 0.0);                                                    % AMMORTIZING MORTGAGE
%idx03 = (sum033 >= 0.0);
res_sale = idx03.*max(sum012, sum022) + (1 - idx03).*sum022;
%res_sale = idx03.*max(sum013, sum022) + (1 - idx03).*sum022;


end

%}
%sum01 = D_use1.*(rent - yr_PMT2) + D_use2.*rent + mbal;
%sum01(1) = -1000;

%%

%{
sum01 = ...
    (rent - yr_PMT)./(D^1) + (rent - yr_PMT)./(D^2) + (rent - yr_PMT)./(D^3) + ...
    (rent - yr_PMT)./(D^4) + (rent - yr_PMT)./(D^5) + (rent - yr_PMT)./(D^6) + ...
    (rent - yr_PMT)./(D^7) + (rent - yr_PMT)./(D^8) + (rent - yr_PMT)./(D^9) + ...
    (rent - yr_PMT)./(D^10) + (rent - yr_PMT)./(D^11) + (rent - yr_PMT)./(D^12) + ...
    (rent - yr_PMT)./(D^13) + (rent - yr_PMT)./(D^14) + (rent - yr_PMT)./(D^15) + ...
    (rent - yr_PMT)./(D^16) + (rent - yr_PMT)./(D^17) + (rent - yr_PMT)./(D^18) + ...
    (rent - yr_PMT)./(D^18) + (rent - yr_PMT)./(D^20) + (rent - yr_PMT)./(D^21) + ...
    (rent - yr_PMT)./(D^21) + (rent - yr_PMT)./(D^23) + (rent - yr_PMT)./(D^24) + ...
    (rent - yr_PMT)./(D^25) + (rent - yr_PMT)./(D^26) + (rent - yr_PMT)./(D^27) + ...
    (rent - yr_PMT)./(D^28) + (rent - yr_PMT)./(D^29) + (rent - yr_PMT)./(D^30) + ...
    1.0*mbal;
%}
    %1.0*(.35*P_low + .4*P_mid + .25*P_high)/ (D^16) + mbal  ;

%sum02 = 15.0*param.P_HR;

%{
sum02 = param.P_MULT_L*param.P_HR; 
this is the orginial sum02 aka the Blackstone price; note that as the t
increases, the actual price which is the sum of the two weightings 
goes from the individual price to the Blackstone price;
try getting rid of this for now...
%}

%sum02 = param.P_MULT_L*param.P_HR; 
%sum02 = sum01;

% sum01 represents LL type 1: HH acts as a LL
% sum02 represnets LL type 2: HH defaults and sells to a cash LL

%idx1 =  ( (rent - yr_PMT ) >= 0.0 );
%idx1 =  ( (rent - yr_PMT ) >= -1e10 );
%idx2 = ( (rent - yr_PMT) < -1e10 );
%idx1 =  ( (.8*rent - yr_PMT ) >= 0.0 );
%idx2 = ( (rent - yr_PMT) < 0.0 );


%idx3 = ( CURR_YEAR - YRMOR_EST <= 10 );
%idx2 =  ( (rent - yr_PMT ) < 0.0 );

%w1 = min ( ( CURR_YEAR - YRMOR_EST) ./ 10.0 , 1 );

%w1 = 0.0;   % mod here!!! This mod was NO GOOD
%sum01 = .95*sum01; % mode here! adjusts for expenses, exteralities, etc...

%{
There's a mod here! set w1=0.0 to get sum01 only

%}

%w1 = min ( ( CURR_YEAR - YRMOR_EST) ./ 8.0 , 1 );
%res_sale = idx1.*( (1-w1).*sum01 + w1*sum02 ) + idx2.*sum02;
%res_sale = max(res_sale, sum02);

%end

%yr_PMT = (12.0*PMT).*( 1.03.^(CURR_YEAR - YRMOR_EST) );
%mbal = 1.0/param.APR.*yr_PMT;          % mbal = t_left .* yr_PMT;

%res_sale = idx1.*sum01 + idx2.*sum02;
%res_sale = sum0;

%P_low = param.P_MULT_L*param.P_HR;    % three possible fundamental prices
%P_mid = param.P_MULT_M*param.P_HR;
%P_high = param.P_MULT_H*param.P_HR;

%disp('save calc_res_sale3');
%t_left = max(TERM + YRMOR_EST - CURR_YEAR, 0);  % ex: 30 + 1995 - 2001 = 24 years left on mortgage
%t_left = 100;

%sum0 = 0.0;
%BEDRMS = min(BEDRMS,2);
%rent = 12*(400 + 700*BEDRMS);
%rent = BEDRMS / 2.0 * P_HR;


%{
note:
does not look like I need to worry about equity here; 
the DCF is a parsimonious way to price the cash flows

one should be able to get impulse responses with respect
to credit standards
%}

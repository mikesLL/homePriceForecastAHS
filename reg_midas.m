function [ theta, lags1, lags2 ] = reg_midas( y, X1, X2 )
% gen_fore calls this function
% inputs: y: variable of interest (aggregated yearly)
% X1: own observations ( quarters )
% X2: predictor variable ( quarters )
% note that theta always takes on 7 parameters

save('reg_midas_save');

%note: MATLAB automatically drops nan entries

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
[foo, val] = fminsearch( @(theta) f_almon(theta, y_use, X1_use, X2_use, lags1, lags2 ), theta0 );



end

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



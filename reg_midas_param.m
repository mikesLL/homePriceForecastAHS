function [ output_args ] = reg_midas_param( y_use, X1_use, lags1,  X2_use, lags2 )

% y_use is variable of interest (aggregated yearly)
% X1_use is own lags (quarterly)
% X2_use is predictor variable (quarterly)

%lags1 = 7;
%lags2 = 3;

% guess coefficients
coeff_alpha = 0.0;
coeff_rho = 0.0;
coeff_beta = 0.0;
param_almon11 = 0.0;   % own almon params
param_almon12 = 0.0;
param_almon21 = 0.0;   % predictor-variable almon params
param_almon22 = 0.0;


w1 = 1/(lags1+1)*ones(lags1 + 1,1);   % almon-implied weights 
w2 = 1/(lags2+1)*ones(lags2 + 1,1);   % almon-implied weights

% theta: all free parameters
theta = [coeff_alpha; coeff_rho; coeff_beta; ...
    param_almon11; param_almon12; param_almon21; param_almon22;  ];

theta_grad = zeros(size(theta));

h = .00000001;  % step size for derivative
alpha_h = .001; % shift multiplier


% given coefficient guess, calculate y_hat vector of predicted values
A = X1_use * w1;
B = X2_use * w2;

%y_hat = f(theta, X1_use, X2_use);
y_hat = coeff_alpha + coeff_rho*A + coeff_beta*B;


ssr =  sum( (y_use - y_hat).^2 );

for i=1:length(theta_grad)
    theta_h = theta;
    theta_h(i) = theta_h(i) + h;
    
    y_hat_h = 
    ssr_h = 
    
end
ssr_d1 = sum( (y - (beta_est(1) + h) - beta_est(2)*ret0 ).^ 2 );
    d1 = (ssr_d1 - ssr )/ h;
    
    ssr_d2 = sum( (y - beta_est(1) - (beta_est(2) + h)*ret0 ).^ 2 );
    d2 = (ssr_d2 - ssr )/ h;




end


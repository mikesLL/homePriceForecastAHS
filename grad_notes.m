%%
f = @(x) x(1).^2 + x(2).^2 ;
gradient(f);

syms x y z
f = 2*y*z*sin(x) + 3*x*sin(z)*cos(y);

syms K L
F = K^(1/3)*L^(2/3);
gradient(F, [K, L;

%%
alpha1 = .02;
rho1 = .6;
sigma1 = .1;

ret_vec = zeros(100,1);

for t=2:length(ret_vec)
    ret_vec(t) = alpha1 + rho1*ret_vec(t-1) + sigma1*randn;
end


%%
alpha1 = .02;
rho1 = .6;
sigma1 = .1;

w1 = .4;
w2 = .3;
w3 = .2;
w4 = .1;

ret_vec = zeros(100,1);

for t=2:length(ret_vec)
    ret_vec(t) = alpha1 + rho1*ret_vec(t-1) + sigma1*randn;
end

%% Gradient descent
X = ret_vec;
y = zeros(size(ret_vec));

for t=5:length(ret_vec)
    y(t) = alpha1 + rho1*( w1*ret_vec(t-1) + w2*ret_vec(t-2) + ...
        w3*ret_vec(t-3) + w4*ret_vec(t-4) );
end

%%
%X = ret_vec(1:end-1);
%y = ret_vec(2:end);

%beta_est = [0.0, 0.0]';
beta_est = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]';

%y_hat = beta_est(1) + beta_est(2)*ret0;
%err = ( y - beta_est(1) - beta_est(2)*ret0 );
%ssr = sum( err.^ 2 );

h = .00000001;
alpha_h = .001;

beta_est_store = zeros(100000,7);
%%
for n = 1:100000
    ssr = sum( (y - beta_est(1) - beta_est(2)*ret0*...
                (beta_est(3)*X + beta_est(4)*X beta_est(4)*X ).^ 2 );
    
    ssr_d1 = sum( (y - (beta_est(1) + h) - beta_est(2)*ret0 ).^ 2 );
    d1 = (ssr_d1 - ssr )/ h;
    
    ssr_d2 = sum( (y - beta_est(1) - (beta_est(2) + h)*ret0 ).^ 2 );
    d2 = (ssr_d2 - ssr )/ h;
    
    beta_est = beta_est - alpha_h*[d1 d2]';
    
    beta_est_store(n,1) = beta_est(1);
    beta_est_store(n,2) = beta_est(2);
    beta_est_store(n,3) = ssr;
    
end
%%
















function [ x_opt ] = gen_MVw(MU, OMEGA, mv_GAMMA  )

%{
MU = [.07 .20 .02 .0]';   % stocks, house, mortgage
OMEGA = [.22 .01 .0 .0; 
         .01 .04 .0 .0; 
         .0 .0 .0 .0;
         .0 .0 .0 .0;];
mv_GAMMA = 4;
%}
x0 = [.25 .25 .25 .25];

%fun = @(x) 100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
fun = @(x) - (x*MU - mv_GAMMA / 2 * x * OMEGA * x');


A = [ -1 0 0 0;  % stock min
       1 0 0 0 ;  % stock max
       0 -1 0 0; % house min
       0 1  0 0; % house max
       0 -.8 -1 0; % mort min determined by x_h
       0 0  1 0; % mort max
       0 0 0 -1; % rf min
       1 1 1 1; ];
   
b = [ 0;  % stock min
      1;  % stock max
      0;  % house min
      8; % house max
      0;  % mort min
      0;  % mort max
      0;  % rf min
      1; ];

opts = optimset('Display', 'off', 'Algorithm', 'active-set');
%opts.Display = 'off';

%x_opt = fmincon(fun,x0,A,b);
x_opt = fmincon(fun,x0,A,b,[],[],[],[],[],opts);

end


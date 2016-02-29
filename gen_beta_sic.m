function [ beta_sic, lags1_opt, lags2_opt ] = gen_beta_sic(y_city, X_city )

%save('gen_beta_sic_save');
%%
sic_store = zeros(8,8);
sic_min = inf;
lags1_opt = 0;
lags2_opt = 0;

if ( size(X_city,2) == 2 )
    beta_sic = [0.0 1.0 0.0]';    
else
    beta_sic = [0.0 1.0 ]';
end

%%
if ( size(X_city,2) == 2 )
    for lags1 = 0:4:8
        %for lags2 = 0:2
        for lags2 = 0:4:8
            X_lag_mat = [ lagmatrix(X_city(:,1),(0:lags1)) lagmatrix(X_city(:,2),(0:lags2))];
            X_use = X_lag_mat(9:end,:);
            y_use = y_city(9:end,:);
            
            k = size(X_use,2) + 1;
            n = length(X_use);
            
            stats_i = regstats(y_use,X_use, 'linear');
            sigma2_hat = 1/n*sum( (y_use - stats_i.yhat) .^ 2);
            
            
            sic = n*log(sigma2_hat) + k*log(n);
            sic_store(lags1 + 1, lags2 + 1) = sic;
            
            if sic < sic_min
                sic_min = sic;
                lags1_opt = lags1;
                lags2_opt = lags2;
                beta_sic = stats_i.beta;
            else
                %break;
            end
            
  
        end
    end
    
else
    lags2 = 0;
    for lags1 = 0:4:8  
        X_lag_mat = lagmatrix(X_city(:,1),(0:lags1)) ;
        X_use = X_lag_mat(9:end,:);
        y_use = y_city(9:end,:);
        
        stats_i = regstats(y_use,X_use, 'linear');
        %sigma2_hat = sum( (y_use - stats_i.yhat) .^ 2);
        
        k = size(X_use,2) + 1;
        n = length(X_use);
            
        sigma2_hat = 1/n*sum( (y_use - stats_i.yhat) .^ 2);
        sic = n*log(sigma2_hat) + k*log(n);
        sic_store(lags1 + 1, lags2 + 1) = sic;
        %disp(sic);
        if sic < sic_min
            sic_min = sic;
            lags1_opt = lags1;
            beta_sic = stats_i.beta;
        else
            %break;
        end
    end
    
end
%X_use2 = [ lagmatrix(X_city(t_use,1),(0:lags1_opt)) lagmatrix(X_city(t_use,2),(0:lags2_opt)) ];

end


%{
smsa characeristics

%}

addpath('../results');
load fetch_data_save;

%%
%San Diego, Year 2005;
idx_SDG = all([ newhouse_flat.SMSA == 7320, newhouse_flat.PUFYEAR == 2005 ...
                newhouse_flat.UNITSF > 0.0, newhouse_flat.NUNITS == 1 ], 2 );
            
quantiles_SDG = quantile(newhouse_flat.UNITSF(idx_SDG),[.3333, .5, .6666]);

disp('SDG QUANTILES:');
disp(quantiles_SDG);


idx_SDG2 = all([ idx_SDG, newhouse_flat.AGE >= 25, newhouse_flat.AGE <= 35 ], 2 );

zinc2_SDG = newhouse_flat.ZINC2(idx_SDG2);
zinc2_W = newhouse_flat.WEIGHT(idx_SDG2);

mean_SDG = zinc2_SDG .* zinc2_W ./ (sum(zinc2_W));

%Los Angeles, Year 2005;
idx_LAX = all([ newhouse_flat.SMSA == 4480, newhouse_flat.PUFYEAR == 2005 ...
                newhouse_flat.UNITSF > 0.0, newhouse_flat.NUNITS == 1 ], 2 );
            
quantiles_LAX = quantile(newhouse_flat.UNITSF(idx_LAX),[.3333, .5, .6666]);

disp('LAX QUANTILES:');
disp(quantiles_LAX);

idx_LAX2 = all([ idx_LAX, newhouse_flat.AGE >= 25, newhouse_flat.AGE <= 35 ], 2 );
zinc2_LAX = newhouse_flat.ZINC2(idx_LAX2);

%San Francisco, Year 2005;
idx_SFR = all([ newhouse_flat.SMSA == 7360, newhouse_flat.PUFYEAR == 2005 ...
                newhouse_flat.UNITSF > 0.0, newhouse_flat.NUNITS == 1 ], 2 );
            
quantiles_SFR = quantile(newhouse_flat.UNITSF(idx_SFR),[.3333, .5, .6666]);

disp('SFR QUANTILE:');
disp(quantiles_SFR);

idx_SFR2 = all([ idx_SFR, newhouse_flat.AGE >= 25, newhouse_flat.AGE <= 35 ], 2 );
zinc2_SFR = newhouse_flat.ZINC2(idx_SFR2);



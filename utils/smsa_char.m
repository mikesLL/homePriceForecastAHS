%{
smsa characeristics


% file used for project_CSFv2
%}

addpath('../results');
load fetch_data_save;

%%
%San Diego, Year 2005;
idx_SDG = all([ newhouse_flat.SMSA == 7320, newhouse_flat.PUFYEAR == 2005 ...
                newhouse_flat.UNITSF > 0.0, newhouse_flat.UNITSF <= 6000, ...
                newhouse_flat.BEDRMS >= 0, newhouse_flat.NUNITS == 1 ], 2 );

figure;
hist( newhouse_flat.UNITSF(idx_SDG) );
quantiles_SDG = quantile(newhouse_flat.UNITSF(idx_SDG),[.3333, .5, .6666]);

% adding work here: k-means
[SDG_class, SDG_2means] = kmeans( newhouse_flat.UNITSF(idx_SDG), 2 );
fprintf('SDG_2means:   %f are : %f,  %f are : %f \n', ...
    sum(SDG_class==1)/length(SDG_class), SDG_2means(1), ...
    sum(SDG_class==2)/length(SDG_class), SDG_2means(2) );
fprintf('SDG quantiles: %f, %f, %f \n', ...
    quantiles_SDG(1), quantiles_SDG(2), quantiles_SDG(3) );

idx_SDG2 = all([ idx_SDG, newhouse_flat.AGE >= 25, newhouse_flat.AGE <= 35 ], 2 );

zinc2_SDG = newhouse_flat.ZINC2(idx_SDG2);
zinc2_W = newhouse_flat.WEIGHT(idx_SDG2);

mean_SDG = zinc2_SDG .* zinc2_W ./ (sum(zinc2_W));

%Los Angeles, Year 2005;
idx_LAX = all([ newhouse_flat.SMSA == 4480, newhouse_flat.PUFYEAR == 2005 ...
                newhouse_flat.UNITSF > 0.0, newhouse_flat.UNITSF <= 6000, ...
                newhouse_flat.BEDRMS >= 0, newhouse_flat.NUNITS == 1 ], 2 );
figure;
hist( newhouse_flat.UNITSF(idx_LAX) );
quantiles_LAX = quantile(newhouse_flat.UNITSF(idx_LAX),[.3333, .5, .6666]);

disp('LAX QUANTILES:');
disp(quantiles_LAX);

idx_LAX2 = all([ idx_LAX, newhouse_flat.AGE >= 25, newhouse_flat.AGE <= 35 ], 2 );
zinc2_LAX = newhouse_flat.ZINC2(idx_LAX2);

% adding work here: k-means
[LAX_class, LAX_2means] = kmeans( newhouse_flat.UNITSF(idx_LAX), 2 );
fprintf('LAX_2means:   %f are : %f,  %f are : %f \n', ...
    sum(LAX_class==1)/length(LAX_class), LAX_2means(1), ...
    sum(LAX_class==2)/length(LAX_class), LAX_2means(2) );
fprintf('LAX quantiles: %f, %f, %f \n', ...
    quantiles_LAX(1), quantiles_LAX(2), quantiles_LAX(3) );


%San Francisco, Year 2005;
idx_SFR = all([ newhouse_flat.SMSA == 7360, newhouse_flat.PUFYEAR == 2005 ...
                newhouse_flat.UNITSF > 0.0, newhouse_flat.UNITSF < 6000, ...
                newhouse_flat.BEDRMS >= 0, newhouse_flat.NUNITS == 1 ], 2 );
        
figure;
hist( newhouse_flat.UNITSF(idx_SFR) );
quantiles_SFR = quantile(newhouse_flat.UNITSF(idx_SFR),[.3333, .5, .6666]);

disp('SFR QUANTILE:');
disp(quantiles_SFR);

idx_SFR2 = all([ idx_SFR, newhouse_flat.AGE >= 25, newhouse_flat.AGE <= 35 ], 2 );
zinc2_SFR = newhouse_flat.ZINC2(idx_SFR2);

% adding work here: k-means
[SFR_class, SFR_2means] = kmeans( newhouse_flat.UNITSF(idx_LAX), 2 );
fprintf('SFR_2means:   %f are : %f,  %f are : %f \n', ...
    sum(SFR_class==1)/length(SFR_class), SFR_2means(1), ...
    sum(SFR_class==2)/length(SFR_class), SFR_2means(2) );
fprintf('SFR quantiles: %f, %f, %f \n', ...
    quantiles_SFR(1), quantiles_SFR(2), quantiles_SFR(3) );


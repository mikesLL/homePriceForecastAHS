%clear all;
load dsreadin_codes;
load smsa_table;
load newhouse_flat;
load dsreadin_macro_data;

param.CFUSE =  'DCFP'; %'CFP'; %'DCFP';  % = 'CFP';
param.LTI = .35;        % may want to load up an estimate of this; time-varying LTI?
param.max_mult = 40;
param.min_mult = 10;
param.Y_CC = 50000;

c = fred('https://research.stlouisfed.org/fred2/');           
fromdate = '01/01/1986';   % beginning of date range for historical data
todate = '01/01/2014';     % ending of date range for historical data

N_cities = max(dsreadin_codes.city_id);
ds_in{N_cities} = dataset;

%%
for city_id = 1:N_cities  %11:14    % = 1: N_cities
    
    fprintf('load city_id %d \n', city_id);
    param.city_id = city_id;
    param.rent2014 = dsreadin_codes.rent2014(city_id);
    param.price2014 = dsreadin_codes.price2014(city_id);
    param.seriesStr = dsreadin_codes.city_str{city_id};
    series_codes = dsreadin_codes(city_id,:);
    
    %ds_in{city_id} = fetch_fred(c, param, fromdate, todate, series_codes ); 
    %ds_in{city_id} = fetch_fred_quart(c, param, fromdate, todate, series_codes );
    ds_in0 = fetch_fred_quart(c, param, fromdate, todate, series_codes );
    ds_in0.spy_ret_fut = dsreadin_macro_data.spy_ret_fut;
    ds_in0.spy_ret = dsreadin_macro_data.spy_ret;
    ds_in0.spy_yield = dsreadin_macro_data.spy_yield;
    ds_in{city_id} = ds_in0;
    
    %tmp = ds_in{city_id};
end

%% ds_pool now contains pooled data for all cities
ds_pool = vertcat(ds_in{:});
ds_pool.risk_idx = zeros(length(ds_pool),1);
ds_pool.risk_idx2 = zeros(length(ds_pool),1);
save('notes_fetch_mid');

% issue for riverside: no renters or owners found in any year; 
% better double check associated SMSA code; SMSA code appears correct
% also issue for riverside; no data available?
% drop riverside: not a single obs for that metro in the AHS PUF 

%% in this section, generate the risk_idx?
for city_id = 1:N_cities
    city_str = dsreadin_codes.city_str(city_id);
    param.SMSA = dsreadin_codes.SMSA1(city_id);
    param.SMSA2 = dsreadin_codes.SMSA2(city_id);
    param.SMSA3 = dsreadin_codes.SMSA3(city_id);
    param.SMSA4 = dsreadin_codes.SMSA4(city_id);
    param.SMSA5 = dsreadin_codes.SMSA5(city_id);
      
    %ds_use.risk_idx(i_beg: i_end) = gen_risk_idx(param, city_str, ds_use(i_beg: i_end,:), newhouse_flat);
    idx_use = (ds_pool.city_id == city_id);
    %i_beg = 1;
    %i_end = 27;
    i_beg = find( ds_pool.city_id == city_id, 1, 'first');
    i_end = find( ds_pool.city_id == city_id, 1, 'last');
    %test_vec = gen_risk_idx(param, city_str, ds_pool(i_beg: i_end,:), newhouse_flat);
    [test_vec, test_vec2] = gen_risk_idx_quart(param, city_str, ds_pool(i_beg: i_end,:), newhouse_flat);
    ds_pool.risk_idx(i_beg:i_end) = test_vec;
    ds_pool.risk_idx2(i_beg:i_end) = test_vec2;
end


%%
close(c);

SMSA_unique = unique(newhouse_flat.SMSA);

SMSA_count = zeros(length(SMSA_unique),1);

for i=1:length(SMSA_unique)
    idx = ( newhouse_flat.SMSA == SMSA_unique(i));
    SMSA_count(i) = sum( idx );
end

SMSA_vec = [SMSA_unique SMSA_count];
SMSA_vec2 = sortrows(SMSA_vec, -2);


%%
pop_wvec = [ .19 .13 .09 .06 .06 .06 .05 .05 .04 .04 .04 .03 .03 .03 .03 .03 .02];
ds_pool.risk_idx2 = zeros(length(ds_pool),1);

for i = 1:length(ds_pool)
    idx_use1 = and( ds_pool.YEAR == ...
        ds_pool.YEAR(i), ds_pool.QUARTER == ds_pool.QUARTER(i) );
    ds_use_natl = ds_pool(idx_use1,:);
    
    ds_pool.risk_idx2(i) =  pop_wvec * ds_use_natl.risk_idx;
end

%save('notes_fetch_results.mat');
save('fetch_data_save.mat');

%%

%middate = '04/01/1986';

%dateseries = ones(4*28 + 1,1) .*  '01/01/1986';
%dateseries = repmat('01/01/1986', 4*28+1, 1);
%date_add =  repmat( [0 3 0 0 0 0 0 0 0 0], 4*28 + 1, 1 );

%date_add(:,2) = date_add(:,2) .* (0:(4*28) )';

%dateseries(2,:) = dateseries(2,:) + date_add(2,:);
%dateseries(3,:) = dateseries(3,:) + date_add(3,:);
%dateseries = dateseries + date_add;

%dateseries2(1:3,:) = dateseries(1:3,:) + date_add(1:3,:);


%dateseries3 = repmat('01/01/1986', 4*28+1, 1);
%for i=1:length(dateseries3)
%   dateseries3(i,:) = dateseries3(i,:) + i*[0 3 0 0 0 0 0 0 0 0];
%end


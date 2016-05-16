%{
clean_newhouse.m
Categorize datasets into homeowners and renters

a1_ds: homeowner dataset
a2_ds: renter dataset

Copyright A. Michael Sharifi, 2016
%}

%%
function [ a1_ds, a2_ds  ] = clean_newhouse(param, newhouse_flat )

save('clean_newhouse_save');

idx_yr = (newhouse_flat.PUFYEAR == param.CURR_YEAR); % years
idx_SMSA = (newhouse_flat.SMSA == param.SMSA) ;

idx_OWN = (newhouse_flat.TENURE == 1);
idx_RENT = (newhouse_flat.TENURE == 2);

idx_BB = all([idx_yr idx_SMSA idx_RENT ],2);
idx_SS = all([idx_yr idx_SMSA idx_OWN ],2);

%%
a1_ds = newhouse_flat(idx_SS,:);  % homeowner dataset
a2_ds = newhouse_flat(idx_BB,:);  % renter dataset

%% assume if value is not given that it equals median value
med_VAL = median(a1_ds.VALUE);
idx_VAL_ERROR = (a1_ds.VALUE < 0);
a1_ds.VALUE(idx_VAL_ERROR) = med_VAL;

end

%idx_BB = all([idx_yr idx_SMSA idx_RENT ],2);
%idx_SS = all([idx_yr idx_SMSA idx_OWN idx_MVALID idx_VAL ],2);

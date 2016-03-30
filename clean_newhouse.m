function [ a1_ds, a2_ds  ] = clean_newhouse(param, newhouse_flat )

%save('save_clean_newhouse');

idx_yr = (newhouse_flat.PUFYEAR == param.CURR_YEAR); % years

%idx_SMSA = (newhouse_flat.SMSA == param.SMSA) ;
%idx_SMSA = (newhouse_flat.SMSA == param.SMSA) + (newhouse_flat.SMSA == param.SMSA2) ;
idx_SMSA = (newhouse_flat.SMSA == param.SMSA) + (newhouse_flat.SMSA == param.SMSA2)  +...
           (newhouse_flat.SMSA == param.SMSA3) + (newhouse_flat.SMSA == param.SMSA4) +...
           (newhouse_flat.SMSA == param.SMSA5); 


idx_OWN = (newhouse_flat.TENURE == 1);
idx_RENT = (newhouse_flat.TENURE == 2);

newhouse_flat.YRMOR = max(newhouse_flat.YRMOREST, newhouse_flat.YRMOR);
idx_MVALID = (newhouse_flat.YRMOR >= 0);
idx_VAL = (newhouse_flat.VALUE > 0 );

idx_BB = all([idx_yr idx_SMSA idx_RENT ],2);
idx_SS = all([idx_yr idx_SMSA idx_OWN idx_MVALID idx_VAL ],2);

%%
a1_ds = newhouse_flat(idx_BB,:);
a2_ds = newhouse_flat(idx_SS,:);

%%
med_VAL = median(a2_ds.VALUE);
idx_VAL_ERROR = (a2_ds.VALUE < 0);
a2_ds.VALUE(idx_VAL_ERROR) = med_VAL;

med_PMT = median(a2_ds.PMT);
idx_PMT_ERROR = (a2_ds.PMT < 0 );
a2_ds.PMT(idx_PMT_ERROR) = med_PMT;

a2_ds.RUNITS = a2_ds.VALUE / med_VAL ;


end


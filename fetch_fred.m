function [ ds ] = fetch_fred(c, param, fromdate, todate, series_codes )

save('fetch_fred_save');

%%
rent2014 = param.rent2014;
price2014 = param.price2014;

hpi_series = series_codes.hpi_code; 
rent_series = series_codes.rent_code;
pci_series = series_codes.pci_code;
priv_units_series = series_codes.priv_units_code;
pop_series = series_codes.pop_code;
emp_series = series_codes.emp_code;
lf_series = series_codes.lf_code;
urate_series = series_codes.urate_code;

apr_series = 'MORTGAGE30US';
d = fetch(c,apr_series,fromdate,todate);
idx_count = 1:length(d.Data);
idx_mod = mod(idx_count, 52);
idx_keep = ( idx_mod == 1 );
APR_tmp = d.Data(idx_keep,2);
APR = APR_tmp(2:end);

%hpi_series = 'ATNHPIUS31084Q';
d = fetch(c,hpi_series,fromdate,todate);  
% want to keep only jan values
idx = 1:length(d.Data);
mod_idx = mod(idx, 4);
idx_keep = ( mod_idx == 1 );

data_tmp = d.Data(idx_keep, 2);

price = data_tmp .* price2014 / data_tmp(end);
price = price(2:end);

ret_tmp = ( data_tmp(2:end) - data_tmp(1:end-1) ) ./ data_tmp(1:end-1);
%ret_fut = ret_tmp;
%ret = [ 0; ret_tmp(1:end-1) ];
ret = ret_tmp;
ret_fut = [ret_tmp(2:end); 0];

%{
if strcmp(param.seriesStr,'LAX')
    hpi_series = 'LXXRSA';
    d = fetch(c,hpi_series,fromdate,todate);
    idx = 1:length(d.Data);
    mod_idx = mod(idx, 12);
    idx_keep = ( mod_idx == 1 );
    data_tmp = d.Data(idx_keep, 2); 
    price = data_tmp .* price2014 / data_tmp(end);
    
    ret_tmp = ( data_tmp(2:end) - data_tmp(1:end-1) ) ./ data_tmp(1:end-1);
    ret_fut = [ 0; ret_tmp];
    ret = [ 0; 0; ret_tmp(1:end-1) ];
end
%}
%%
d = fetch(c,rent_series,fromdate,todate);  

if strcmp( series_codes.rent_freq, 'M' )
    datestr(d.Data(:,1));
    idx = 1:length(d.Data);
    mod_idx = mod(idx, 12);
    idx_keep = ( mod_idx == 1 );
    rent_keep = d.Data(idx_keep,2);
    rent_keep = rent_keep(2:end);
end

if strcmp( series_codes.rent_freq, 'S' )
    datestr(d.Data(:,1));
    idx = 1:length(d.Data);
    mod_idx = mod(idx, 2);
    idx_keep = ( mod_idx == 1 );
    rent_keep = d.Data(idx_keep,2);
    rent_keep = rent_keep(2:end);
end

%rent_series = 'CUUSA424SEHC';  % manually try San Deigo
%d = fetch(c,rent_series,fromdate,todate);  
if strcmp( series_codes.rent_freq, 'A' )
    datestr(d.Data(:,1));
    %idx = 1:length(d.Data);
    %mod_idx = mod(idx, 1);
    %idx_keep = ( mod_idx == 1 );
    rent_keep = d.Data(:,2);
    
    if ( length(d.Data(:,1)) > 28 )
        rent_keep = rent_keep(2:end);
    end
end


%%
rent = rent_keep .* ( rent2014 / rent_keep(end) );
rp = rent ./price;

%%
d = fetch(c,pci_series,fromdate,todate);  

pci = d.Data(:,2);
%pci_perc_chg = ( pci(2:end) - pci(1:end-1) ) ./ pci(1:end-1);
pci_perc_chg = ( pci(2:end) - pci(1:end-1) ) ./ pci(1:end-1);

if (d.Data(end,1) > 735235 ) 
    %pci = pci(2:end);                  % note that pci is in nominal, raw units
    pci = pci(1:end-1);
end

pi_ratio = price ./ pci;

% load in population
% convert to percent change
% load 
d = fetch(c,pop_series,fromdate,todate);  
pop = d.Data(:,2);
pop2 = pop(2:end);
pop_perc_chg_tmp = (pop(2:end) - pop(1:end-1) )./ pop(1:end-1);
pop_perc_chg = [0; pop_perc_chg_tmp(1:end-1) ];

d = fetch(c,priv_units_series,fromdate,todate);  

%%
a = d.Data(:,2);
a = a(1:end-1);
b = reshape(a, 12, 26);
cc = sum(b)';
new_units = [cc(1); cc];

%{
new_units2 = zeros(28,1);
for id = 1:length(new_units2)
    year_id = 1987 + (id - 1);
    idx = ( year( d.Data(:,1) ) == year_id );
    new_units2(id) = sum( d.Data(idx,2 ) );
end
%}

%%
%new_units_to_pop = [ new_units(1); new_units] ./ ( pop2 * 1000 );  % issue: new_units only available beginning in 1988;
new_units_to_pop = [ new_units; new_units(end)] ./ ( pop2 * 1000 );  % issue: new_units only available beginning in 1988;

d = fetch(c,emp_series,fromdate,todate);  

emp_tmp = d.Data(:,2);
emp_perc_chg = ( emp_tmp(2:end) - emp_tmp(1:end-1) ) ./  emp_tmp(1:end-1); 

d = fetch(c,lf_series,fromdate,todate);  
% units are monthly; keep only beginning of year
idx_count = 1:length(d.Data(:,2));
idx_mod = mod(idx_count, 12);
idx_keep = (idx_mod == 1);
lf_vec_tmp = d.Data(idx_keep,2);
lf_perc_chg = ( lf_vec_tmp(2:end) - lf_vec_tmp(1:end-1) ) ./  lf_vec_tmp(1:end-1); 

%urate_series = 'NYURN';
d = fetch(c,urate_series,fromdate,todate);  
idx_count = 1:length(d.Data(:,2));
idx_mod = mod(idx_count, 12);
idx_keep = (idx_mod == 1);
urate_vec_tmp = d.Data(idx_keep,2);
urate = urate_vec_tmp(2:end);

%year_vec = (1988:2014)';
year_vec = ( (year(fromdate) + 1) : year(todate) )'; 
% generate the return dataset
ds = dataset;
ds.city_id = param.city_id*ones(size(year_vec));
ds.YEAR = year_vec;
ds.RENT = rent; %ones(size(year_vec));      % dummy here!
ds.PRICE = price; % ones(size(year_vec));     % dummy here!
ds.APR = APR / 100.0; %ones(size(year_vec));       % dummy here!
ds.RP = rp;
ds.RET_fut = ret_fut;
ds.RET = ret;

ds.POPCHG = pop_perc_chg;
ds.PCICHG = pci_perc_chg;

ds.PI_ratio = pi_ratio;
ds.PCI = pci;

ds.NU2POP = new_units_to_pop;
ds.EMPCHG = emp_perc_chg;
ds.LFCHG = lf_perc_chg;
ds.URATE = urate;

end


% Q: think about how to keep the number of units
% The good thing is fetch retrives the units and length
% An interesting thing to try would be to save the units and to modify the
% series based on length

%ds = dataset;
%ds.ret = zeros(27,1);
%ds.ret_fut = zeros(27,1);


% sweet; now have the main things you need; fut returns, returns, and rp
% ratio

% now check out home price to income ratio?

% load in per capita income


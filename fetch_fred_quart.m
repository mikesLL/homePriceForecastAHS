function [ ds ] = fetch_fred_quart(c, param, fromdate, todate, series_codes )

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

%hpi_series = 'ATNHPIUS31084Q';
d = fetch(c,hpi_series,fromdate,todate);  
dateseries_quart = d.Data(:,1);

apr_series = 'MORTGAGE30US';
APR = .01* gen_quart(c, dateseries_quart, apr_series, fromdate, todate, 0 );

%hpi_series = 'ATNHPIUS31084Q';
price_idx = gen_quart(c, dateseries_quart, hpi_series, fromdate, todate, 0);
price = price_idx .* price2014 / price_idx(end);

h_step = 4;
yr_step = 4;
chg_step = 1;
ret = gen_perc_chg(price, h_step, 0);   % 1 quarter price changes!
ret_fut = gen_perc_chg(price, h_step, 1);

%%
rent_idx = gen_quart(c, dateseries_quart, rent_series, fromdate, todate, 0);
rent = rent_idx .* rent2014 ./ rent_idx(end);
rp = rent ./price;

%%
pci = gen_quart(c, dateseries_quart, pci_series, fromdate, todate, 0); 
pci_perc_chg = gen_perc_chg(pci, h_step, 0);
pi_ratio = price ./ pci;

%%
pop = 1000.0* gen_quart(c, dateseries_quart, pop_series, fromdate, todate, 0); 
pop_perc_chg = gen_perc_chg(pop, h_step, 0);

new_units = gen_quart(c, dateseries_quart, priv_units_series, fromdate, todate, 1 );
new_units_to_pop = new_units ./ pop;

%%
emp = gen_quart(c, dateseries_quart, emp_series, fromdate, todate, 0 );
emp_perc_chg = gen_perc_chg(emp, h_step, 0);

%%
lf = gen_quart(c, dateseries_quart, lf_series, fromdate, todate, 0 );
lf_perc_chg = gen_perc_chg(lf, h_step, 0);

%%
urate = .01 * gen_quart(c, dateseries_quart, urate_series, fromdate, todate, 0 );

ds = dataset;
ds.city_id = param.city_id*ones(size(dateseries_quart));
ds.DATENUM = dateseries_quart;
ds.YEAR =  year(dateseries_quart);
ds.MONTH = month(dateseries_quart);
ds.QUARTER = floor( month(dateseries_quart) ./ 3.0 ) + 1;

% generate the return dataset
%ds = dataset;
%ds.city_id = param.city_id*ones(size(year_vec));
%ds.YEAR = year_vec;
ds.RENT = rent; %ones(size(year_vec));      % dummy here!
ds.PRICE = price; % ones(size(year_vec));     % dummy here!
ds.APR = APR; %ones(size(year_vec));       % dummy here!
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

%%

%ret_tmp = ( data_tmp(2:end) - data_tmp(1:end-1) ) ./ data_tmp(1:end-1);
%ret_fut = ret_tmp;
%ret = [ 0; ret_tmp(1:end-1) ];
%ret = ret_tmp;
%ret_fut = [ret_tmp(2:end); 0];


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


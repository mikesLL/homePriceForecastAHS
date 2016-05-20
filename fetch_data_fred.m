%{
fetch_data_fred.m reads in series_codes and connection c and retrives associated data

Copyright A. Michael Sharifi, 2016
%}

function [ ds ] = fetch_data_fred(c, param, fromdate, todate, series_codes )

%save('fetch_data_fred_save');  % TODO: delete this when done with diagnostics

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

d = fetch(c,hpi_series, fromdate, todate);  

%%
dateseries_quart = d.Data(:,1);

apr_series = 'MORTGAGE30US';
APR = .01* gen_quart(c, dateseries_quart, apr_series, fromdate, todate, 0 );

price_idx = gen_quart(c, dateseries_quart, hpi_series, fromdate, todate, 0);
price = price_idx .* price2014 / price_idx(end);

h_step = 4;
h_step_q = 1;
yr_step = 4;
chg_step = 1;
h_shift = 0;

ret = gen_perc_chg(price, h_step, h_shift);   % annual price changes using quarterly data

ret_ql0 = gen_perc_chg(price, h_step_q, 0 );
ret_ql1 = gen_perc_chg(price, h_step_q, -1 );
ret_ql2 = gen_perc_chg(price, h_step_q, -2 );
ret_ql3 = gen_perc_chg(price, h_step_q, -3 );
ret_ql4 = gen_perc_chg(price, h_step_q, -4 );
ret_ql5 = gen_perc_chg(price, h_step_q, -5 );
ret_ql6 = gen_perc_chg(price, h_step_q, -6 );
ret_ql7 = gen_perc_chg(price, h_step_q, -7 );

%save('fetch_data_fred_save');

h_shift_fut = 4;
ret_fut = gen_perc_chg(price, h_step, h_shift_fut);

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

%generate the return dataset
ds.RENT = rent; %ones(size(year_vec));      % dummy here!
ds.PRICE = price; % ones(size(year_vec));     % dummy here!
ds.APR = APR; %ones(size(year_vec));       % dummy here!
ds.RP = rp;
ds.RET_fut = ret_fut;
ds.RET = ret;

ds.ret_ql0 = ret_ql0;
ds.ret_ql1 = ret_ql1;
ds.ret_ql2 = ret_ql2;
ds.ret_ql3 = ret_ql3;
ds.ret_ql4 = ret_ql4;
ds.ret_ql5 = ret_ql5;
ds.ret_ql6 = ret_ql6;
ds.ret_ql7 = ret_ql7;

ds.POPCHG = pop_perc_chg;
ds.PCICHG = pci_perc_chg;

ds.PI_ratio = pi_ratio;
ds.PCI = pci;

ds.NU2POP = new_units_to_pop;
ds.EMPCHG = emp_perc_chg;
ds.LFCHG = lf_perc_chg;
ds.URATE = urate;

end

%h_step = 4;
%ret = gen_perc_chg(price, h_step, 0);   % quarter price changes!
%function [ series_perc_chg ] = gen_perc_chg( series_in, h_step, fut_flag )
function [ series_perc_chg ] = gen_perc_chg( series_in, h_step, h_shift )

series_perc_chg = zeros(size(series_in));

%i_begin = h_step + 1;                       % + fut_flag.*h_step;
%i_beg = 1;
%i_end = length(series_in) - (h_step + 1);   % + fut_flag.*h_step;

for i = 1 : length(series_in)
    %i_use = i + fut_flag .* h_step;
    i_use = i + h_shift;  
    % ex: h_shift = 0 for current return, h_shift = 4 for 1-year ahead
   
    if ( (i_use - h_step) >= 1 ) && (i_use <= length(series_in) )
        series_perc_chg(i) = log(series_in(i_use)) - log(series_in(i_use - h_step  ));
    end
end

end


%price_idx = ...
%gen_quart(c, dateseries_quart, hpi_series, fromdate, todate, 0);

function [ series_clean ] = gen_quart(c, dateseries_quart, series_str, fromdate, todate, agg_flag )

d = fetch(c, series_str, fromdate, todate);            % fetch series
series_clean = zeros(length(dateseries_quart),1);

%%
if (agg_flag == 0)                % do not aggregate series
    for i = 1:length(series_clean)
        % find last observation in fetched series with data before requested date
        [loc, ~] = find(d.Data(:,1) <= dateseries_quart(i), 1, 'last');    
        
        if ~isempty(loc)
            series_clean(i) = d.Data(loc,2);
        end
    end
end

%%
%disp(d.Frequency);
if (agg_flag == 1)
    if strcmp(d.Frequency, ' Annual')
        h_back = 0;
    elseif strcmp(d.Frequency, ' Quarterly')
        h_back = 3;
    else
        h_back = 11;
    end    
    
    for i = 1:length(series_clean)
        [loc, ~] = find(d.Data(:,1) <= dateseries_quart(i), 1, 'last');
        
        if ~isempty(loc)
            loc_beg = max(loc - h_back, 1);
            series_clean(i) = sum( d.Data( loc_beg : loc,2 )) ;
        end
    end
end


end
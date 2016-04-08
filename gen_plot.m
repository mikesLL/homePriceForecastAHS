function gen_plot(param, ds_use, city_id, city_str )

addpath('figs');
idx1 = all([ ds_use.city_id == city_id, ds_use.YEAR >= param.year_beg, ...
    ds_use.YEAR <= param.year_end] , 2 );

h = figure;
set(h, 'Visible', 'off');
plot(ds_use.YEAR(idx1),ds_use.risk_idx(idx1));
print(strcat('figs/negeq_',char(lower(city_str))),'-depsc','-tiff'); % Neg Eq homeowners
print(strcat('figs/negeq_',char(lower(city_str))),'-dpng'); 

h = figure; 
set(h, 'Visible', 'off');
plot(ds_use.YEAR(idx1), ds_use.risk_idx2(idx1));
print(strcat('figs/pb_',char(lower(city_str))),'-depsc','-tiff');  % Potential Buyers
print(strcat('figs/pb_',char(lower(city_str))),'-dpng');

h = figure; 
set(h, 'Visible', 'off');
plot(ds_use.YEAR(idx1), ds_use.PRICE(idx1));
print(strcat('figs/price_',char(lower(city_str))),'-depsc','-tiff'); % Prices
print(strcat('figs/price_',char(lower(city_str))),'-dpng'); 



end

%print('test','-dpng', '-painters'); 
%print -painters -dpdf -r600 test.eps
%print('SurfacePlot','-depsc','-tiff')
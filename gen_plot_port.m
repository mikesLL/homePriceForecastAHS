function gen_plot_port(param, port_ds, city_str)

addpath('figs');

idx1 = (port_ds.valid == 1);
figure;
plot(port_ds.x_opt(idx1,:));
print(strcat('figs/x_opt_',char(lower(city_str))),'-depsc','-tiff'); 
%print('SurfacePlot','-depsc','-tiff')
end


%% want to be able to plot the portfolio for the city over time
%{
idx1 = all([ ds_use.city_id == city_id, ds_use.YEAR >= param.year_beg, ...
    ds_use.YEAR <= param.year_end] , 2 );

figure; plot(ds_use.YEAR(idx1),ds_use.risk_idx(idx1));
print(strcat('figs/negeq_',char(lower(city_str))),'-dpng'); % Neg Eq homeowners

figure; plot(ds_use.YEAR(idx1), ds_use.risk_idx2(idx1));
print(strcat('figs/pb_',char(lower(city_str))),'-dpng');  % Potential Buyers

figure; plot(ds_use.YEAR(idx1), ds_use.PRICE(idx1));
print(strcat('figs/price_',char(lower(city_str))),'-dpng'); % Prices
%}
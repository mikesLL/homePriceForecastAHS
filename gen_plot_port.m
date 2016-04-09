function gen_plot_port(param, port_ds, ds_use, city_str, view_id)

addpath('figs');

idx1 = (port_ds.valid == 1);
figure('Position',[0 0 800 500 ]);
plot(ds_use.YEAR(idx1), port_ds.x_opt(idx1,:));
legend('H','X','M','B','Location', 'northoutside','Orientation','horizontal');
str1 = sprintf('figs/x_opt_%s%d', char(lower(city_str)),(view_id));  
print(str1, '-depsc','-tiff'); 
print(str1, '-dpng'); 

end


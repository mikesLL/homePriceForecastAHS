function [ series_perc_chg ] = gen_perc_chg( series_in, h_step, fut_flag )

series_perc_chg = zeros(size(series_in));

i_begin = h_step + 1;                       % + fut_flag.*h_step;
i_end = length(series_in) - (h_step + 1);   % + fut_flag.*h_step;

for i = i_begin : i_end
    i_use = i + fut_flag .* h_step;
    series_perc_chg(i) = log(series_in(i_use)) - log(series_in(i_use - h_step  ));
end

end

%{
%for i = 5 : ( length(price) - 5)
for i = (h_step + 1) : ( length(price) - (h_step + 1))
    ret(i) = log(price(i)) - log(price(i-4));
    ret_fut(i) = log(price(i+4)) - log(price(i));
end
%}

%{
if fut_flag == 0
    for i = (h_step + 1) : ( length(price) - (h_step + 1))
    ret(i) = log(price(i)) - log(price(i-4));
    ret_fut(i) = log(price(i+4)) - log(price(i));
    end

end
%}

function [ series_clean ] = gen_quart(c, dateseries_quart, series_str, fromdate, todate, agg_flag )

%save('gen_quart_save');

d = fetch(c,series_str,fromdate,todate);
series_clean = zeros(length(dateseries_quart),1);

%%
if (agg_flag == 0)
    for i = 1:length(series_clean)
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


%apr_series = 'MORTGAGE30US';
%d = fetch(c,apr_series,fromdate,todate);
%APR = zeros(length(dateseries_quart),1);

%idx_count = 1:length(d.Data);
%idx_mod = mod(idx_count, 52);
%idx_keep = ( idx_mod == 1 );
%APR_tmp = d.Data(idx_keep,2);
%APR = APR_tmp(2:end);


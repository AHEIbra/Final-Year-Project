%clear all
close all
%%%%%%%%% Clear all before using 

A = load('levelfivetestnedgeplus.mat');
A = struct2cell(A);
A = A{1};

all_fgps = learnfingerprints('levelfivefingerprintstwo.mat');

test_location = 6;
%Testing locatio
A = A( A.Location==test_location , : );

t_0 = A.Time(1) - 4;
t0 = t_0;
t_beg = min(A.Time);
t_end = max(A.Time);
n = 1;
dist_array = [];
check_array = [];
test_array = [];
corr_array =[];

actual_corr = [ ];

unique_fgps_locations = unique(all_fgps.all_location);

for i = t_beg:4*n:t_end
    test_point = A(A.Time < i+4 & A.Time >= i, :);

    for j = 1:length(unique_fgps_locations)
        location_fgps = all_fgps(all_fgps.all_location==unique_fgps_locations(j) , : );
        
        for k = 1:height(test_point)
          %Find candidate mac
          test_mac = test_point(strcmp(test_point.BSSID, test_point.BSSID(k)), :);
          %Unique SSID check
          [uniqueSSID, rowfound] = unique(test_mac.BSSID);
          test_mac = test_mac(rowfound,:);
          %Check if SSID is in the fingerprint database
          check = location_fgps(strcmp(location_fgps.all_macs, test_mac.BSSID), :);
          
          %Calculate distances between mac address RSSI's
          if isempty(check) == 0;
            dist = (test_mac.RSSI - check.all_meanRSSI)^2;
            
            %DB vector
            check_RSSI = check.all_meanRSSI;
            %Test vector
            test_RSSI = test_mac.RSSI;
            dist_array = vertcat(dist_array, dist);
            check_array = vertcat(check_array, check_RSSI);
            test_array = vertcat(test_array, test_RSSI);
          end   
        end
        %Euclidean distance instead
        G = sqrt(sum(dist_array));
        
        %Test matlab function
        H = pdist([check_array test_array]' , 'euclidean');      

        %Actual correlation array between matrices
        correlation = corr(check_array, test_array);
        correlation = [correlation unique_fgps_locations(j)];
        actual_corr = vertcat(actual_corr, correlation);
        
        
        %Correlation using pdist or euclidean distances
        corr_array_to_append = horzcat(H, unique_fgps_locations(j));
        corr_array = vertcat(corr_array, corr_array_to_append);
        
     
        
        dist_array = []; 
        check_array = [];
        test_array = [];
    end
end


 corr_end = max(unique(corr_array(:,2)));
 min_corr_array = [];

 
%Build array of minimum distance means 
for i = 1:length(unique(corr_array(:,2))):(length(corr_array))
    corr_at_time = corr_array(i:i+length(unique(corr_array(:,2))) - 1,:);
    min_corr = corr_at_time(corr_at_time(:,1) == min(corr_at_time(:,1)),:);
    min_corr_array = vertcat(min_corr_array, min_corr(:,2)); 
end

max_correlation_array = [ ];

for i = 1:length(unique(actual_corr(:,2))):(length(actual_corr))
    correlation_at_time = actual_corr(i:i+length(unique(actual_corr(:,2)))-1,:);
    maximum_correlation = correlation_at_time(correlation_at_time(:,1) == max(correlation_at_time(:,1)),:);
    max_correlation_array = vertcat(max_correlation_array, maximum_correlation(:,2));
end

%Find average of correlation array
time_steps = length(corr_array)/13;
avg_corr_array = mean(reshape(corr_array(:,1), [13, time_steps]),2);
normalised_avg = (avg_corr_array - min(avg_corr_array))/(max(avg_corr_array) - min(avg_corr_array));
weighted_norm = normalised_avg;

l5_conf = [weighted_norm(1) weighted_norm(2) weighted_norm(3) weighted_norm(4) weighted_norm(5);...
           weighted_norm(13) 1 weighted_norm(10) 1 weighted_norm(6);...
           weighted_norm(12) weighted_norm(11) weighted_norm(9) weighted_norm(8) weighted_norm(7)];
                                 
%%% Results 
Actual_location = test_location
%To make it more readable 
calculated_location = min_corr_array.'

calculated_location_using_correlation = max_correlation_array'

loc_mat_graph = return_distance_coordinate(Actual_location);
sorted_l5_conf = sort(max(l5_conf));
h = figure
imagesc(l5_conf, [min(l5_conf(:)) sorted_l5_conf(3)]);
color = colorbar;
colormap(h, flipud(colormap));
ylabel(color, 'Normalised measurement vector distances', 'FontSize', 12);
shading interp;
set(gca,'YTickLabel',{'0' '1' '2' '3' '4' '5' '6'});
set(gca,'XTickLabel',{'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' '10'});
title(['Normalised average vector distances, actual location = (' num2str(loc_mat_graph(2)) ',' num2str(loc_mat_graph(1)) ')' ]);
xlabel('Distance (m)');
ylabel('Distance (m)');

[M,I] = min(l5_conf(:));
[I_row, I_col] = ind2sub(size(l5_conf),I);
conv_row  = return_distance([I_row I_col]);
                 

dist_between = [conv_row(1), conv_row(2); loc_mat_graph(1), loc_mat_graph(2)];
%%%Finding distance
error = pdist(dist_between)
new_sorted_l5 = sort(l5_conf(:));




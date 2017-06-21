close all

load('roomopenorientation.mat')
untitled = sortrows(roomopenorientation,'Time','ascend');
phone_table = untitled(strcmp(untitled.Found_Device, 'Galaxy S6 edge') , :);
distance = 100;
phone_table = phone_table(phone_table.Distance == distance, :);
phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.Time phone_table.Distance];




test_orientation = 135; %Choose from 0 45 90 135 180 225 270 315 
test_orientation_array = [0 45 90 135 180 225 270 315];
n_array = 1:0.1:6;


avgs = [ ];
vara = [ ];
stdva = [ ];

A_0 = -40.92; 
n =4.16; 
d_0 = 0.5;

optimal_a0_array = [ ];



Q = [0.001]; %Process error
R = [0.1]; %Measurement error

for i = 1:length(test_orientation_array)
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
    temp = [i mean(temp_phone_mat(:,1))];
    avgs = vertcat(avgs, temp);
    temp_phone_mat = [];
end

for i = 1:length(test_orientation_array)
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
    temp = [i var(temp_phone_mat(:,1))];
    vara = vertcat(vara, temp);
    temp_phone_mat = [];
end

for i = 1:length(test_orientation_array)
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
    temp = [i std(temp_phone_mat(:,1))];
    stdva = vertcat(stdva, temp);
    temp_phone_mat = [];
end

figure
plot(test_orientation_array, avgs(:,2));
title('Average of test measurements for each orientation at a distance of 1m');
xlabel('Orientation (deg)');
ylabel('RSSI (dBm)');
grid minor

figure
plot(test_orientation_array, vara(:,2));
title('Variance of test measurments for each orientation');
xlabel('Orientation (deg)');
ylabel('\sigma^(2) (dBm^{2})');
grid minor

figure 
subplot(2,1,1);
plot(test_orientation_array, stdva(:,2));
title('Log normal shadowing at each orientation');
xlabel('Orientation (deg)');
ylabel('\sigma (dBm)');
grid minor

avg_kdprime = [ ];
for i = 1:length(test_orientation_array)
    phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.Time];
    phone_mat = phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
    phone_mat(:,3) = phone_mat(:,3) - phone_mat(1,3);
    
    %kdprime = kalmanFilterOrientation(phone_mat, d_0, orientation_parameters, test_orientation_array(i), Q, R);
    kdprime = kalmanFilterImproved(phone_mat, d_0, A_0, n, Q, R);
    avg_k = mean(kdprime);
    avg_kdprime = vertcat(avg_kdprime, [test_orientation_array(i) avg_k]);
    
end

avg_dist = [ ];

for i = 1:length(test_orientation_array)
    phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.Time];
    phone_mat = phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
    phone_mat(:,3) = phone_mat(:,3) - phone_mat(1,3);
    
    
    dist = mean(d_0*10.^((A_0 - phone_mat(:,1))/(10*n)));
    avg_dist = vertcat(avg_dist, [test_orientation_array(i) dist]);
    
end


mse_orientation = [];

for i = 1:length(avgs(:,1))
    mse = immse(distance/100, avg_dist(i,2));
    mse_orientation = vertcat(mse_orientation, mse);
    
end

mse_orientation_kalman = [];

for i = 1:length(avgs(:,1))
    mse = immse(distance/100, avg_kdprime(i,2));
    mse_orientation_kalman = vertcat(mse_orientation_kalman, mse);
end



avg_kdprime_param = [ ];
for i = 1:length(test_orientation_array)
    phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.Time];
    phone_mat = phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
    phone_mat(:,3) = phone_mat(:,3) - phone_mat(1,3);
    avg_k = mean(kdprime);
    avg_kdprime_param = vertcat(avg_kdprime_param, [test_orientation_array(i) avg_k]);
    
end

mse_orientation_kalman_parameters = [];

for i = 1:length(avgs(:,1))
    mse = immse(distance/100, kalmanFilterOrientation(avgs(i,2), d_0, orientation_parameters, test_orientation_array(i), Q, R));
    mse_orientation_kalman_parameters = vertcat(mse_orientation_kalman_parameters, mse);
  
end

foo = immse(avgs(:,1)/100, d_0*10.^((A_0 - avgs(:,2))/(10*n)))
subplot(2,1,2);
plot(test_orientation_array,  mse_orientation_kalman, '--');
% hold on
% plot(test_orientation_array, mse_orientation_kalman_parameters, '.-');
hold on
plot(test_orientation_array,  mse_orientation);
title('MSE for each orientation');
xlabel('Orientation (deg)');
ylabel('MSE (m^{2})');
legend('Kalman filtered', 'Raw');
grid minor;



figure

plot(test_orientation_array,  mse_orientation_kalman, '--');
hold on
plot(test_orientation_array, mse_orientation_kalman_parameters, '.-');
hold on
plot(test_orientation_array,  mse_orientation);
title('MSE for each orientation');
xlabel('Orientation (deg)');
ylabel('MSE (m^{2})');
legend('Kalman filtered', 'Kalman filter with optimal parameters', 'Raw');
grid minor;


phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.Time];

phone_mat = phone_mat(phone_mat(:,2) == test_orientation,:);
phone_mat(:,3) = phone_mat(:,3) - phone_mat(1,3);





phone_mat(:,4) = d_0*10.^((A_0 - phone_mat(:,1))/(10*n));

phone_mat(:,5) = abs(phone_mat(:,4) - distance/100);

%Kalman filter
kdprime = kalmanFilterImproved(phone_mat, d_0, A_0, n, Q ,R);




figure;
%plot x,y --> time,distance
plot(phone_mat(:,3),phone_mat(:,4)); %Measured
hold on
plot(phone_mat(:,3), phone_mat(:,5)); %Measured error
hold on
plot(phone_mat(:,3), ones(size(phone_mat(:,2)))*distance/100); %Actual
hold on
plot(phone_mat(:,3), kdprime); %Kalman filtered
hold on
plot(phone_mat(:,3), abs(kdprime - distance/100)); %Kalman error

mse = immse(kdprime, ones(size(kdprime))*distance/100)

xlabel('Time (s)');
ylabel('Calculated distance (m)');
str=sprintf('Estimated distance with error at a %d deg orientation', test_orientation);
title(str);
legend('Raw', 'Raw error', 'Actual', 'Kalman filtered', 'Kalman error');
grid minor

figure


mean_kdprime = zeros(1,length(test_orientation_array));

surfdata = zeros(length(n_array),length(test_orientation_array));

error_mat = [  ];

for j = 1:length(n_array);
    n = n_array(j);
    for i = 1:length(test_orientation_array)
        phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.Time];
        phone_mat = phone_mat(phone_mat(:,2) == test_orientation_array(i),:);
        phone_mat(:,3) = phone_mat(:,3) - phone_mat(1,3);

        phone_mat(:,4) = d_0*10.^((A_0 - phone_mat(:,1))/(10*n));
        phone_mat(:,5) = abs(phone_mat(:,4) - distance/100);

        kdprime = kalmanFilterImproved(phone_mat, d_0, A_0, n, Q, R);
        mean_kdprime(i) = mean(kdprime);
        current_error = [n test_orientation_array(i) abs(mean_kdprime(i) - distance/100)];
        error_mat = vertcat(error_mat, current_error);
        
   
        hold on
    end
    legendInfo{j} = ['n = ' num2str(n_array(j))];

    plot3(test_orientation_array, n*ones(1,length(mean_kdprime)), mean_kdprime);
    
    surfdata(j,:) = mean_kdprime;
end

optimal_orientation_n = [  ];

for i = 1:length(test_orientation_array)
    test_error_mat = error_mat(error_mat(:,2) == test_orientation_array(i),:);
    [M, I] = min(test_error_mat(:,3));
    optimal_to_append = test_error_mat(I,:);
    optimal_orientation_n = vertcat(optimal_orientation_n, optimal_to_append);
end


xlabel('Orientation deg')
ylabel('n');
zlabel('Calculated distance (m)');
title('Distance and error with all orientations');
grid minor


figure;
[XX,YY] = meshgrid(test_orientation_array, n_array); 
s1 = surf(XX, YY, surfdata); 

hold on 

 
s2 = surf(XX,YY,ones(size(XX)));

s2.FaceColor = 'flat';
figure
plot(optimal_orientation_n(:,2), optimal_orientation_n(:,1));
xlabel('Orientation (deg)');
ylabel('Optimal n');
title('Optimal n for each orientation');
grid minor


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




close all
clear all

%%Load data
load('untitleddata2.mat')

loadTest = 'untitleddata2.mat';
testDevice = 'Nexus 5';

untitled = sortrows(untitleddata2,'Time','ascend');
phone_table = untitled(strcmp(untitled.Found_Device, 'Nexus 5') , :);
phone_mat = [phone_table.RSSI phone_table.Distance phone_table.Time];


%%%%%%%%%%%% Choose distance to test with
test_distance = 120;
phone_mat = phone_mat(phone_mat(:,2) == test_distance,:);
phone_mat(:,3) = phone_mat(:,3) - phone_mat(1,3);


%%%%%%%%% Find optimal parameters
d_0 = 0.5;
optimal_n = find_optimal_n(loadTest, testDevice, d_0)
A_0 = optimal_n(:,3); 
n =optimal_n(:,1);

phone_mat(:,4) = d_0*10.^((A_0 - phone_mat(:,1))/(10*n));
phone_mat(:,5) = abs(phone_mat(:,4) - (phone_mat(:,2)/100));

mse_norm = immse(phone_mat(:,4), ones(size(phone_mat(:,4)))*test_distance/100)

d = 0.1:0.1:2.5
mse_norm_array = [ ];
%No filtering MSE
for i = 10:10:250
    pphone_mat = [phone_table.RSSI phone_table.Distance phone_table.Time];
    pphone_mat = pphone_mat(pphone_mat(:,2) == i,:);
    pphone_mat(:,3) = pphone_mat(:,3) - pphone_mat(1,3);
    pphone_mat(:,4) = d_0*10.^((A_0 - pphone_mat(:,1))/(10*n));
    mse_norm = immse(pphone_mat(:,4), ones(size(pphone_mat(:,4)))*i/100);
    mse_norm_array = vertcat(mse_norm_array, mse_norm);
end


figure

plot(d, mse_norm_array);

figure;

plot(phone_mat(:,3),phone_mat(:,4));
xlabel('time (s)');
ylabel('distance (m)');
title(['Pre-processed calculated distance and error at a testing distance of ' num2str(test_distance/100)  'm']);

hold on
plot(phone_mat(:,3), (phone_mat(:,2)/100) ,'r');
plot(phone_mat(:,3), phone_mat(:,5), 'k');

grid minor;
hold on
legend('Calculated distance', 'Actual distance', 'Error');

%%Feedback filtering

alpha = 0.75;
previous_rssi = 0;


filtered_array = [ ];
for i = 1:length(phone_mat(:,4))
   current_rssi = phone_mat(i,4);
   filtered = alpha*current_rssi + (1-alpha)*previous_rssi;
   filtered_array = vertcat(filtered_array, filtered);
   previous_rssi = current_rssi;
end
 
 err_new = abs(test_distance/100 - filtered_array);
 mse_feedback = immse(filtered_array, filtered_array*test_distance/100)
figure
plot(phone_mat(:,3),filtered_array);

hold on
plot(phone_mat(:,3), err_new);

hold on
plot(phone_mat(:,3),ones(size(phone_mat(:,3)))*test_distance/100);

title(['Feedback filter calculated distance at a test distance of '  num2str(test_distance/100)  'm']);
xlabel('Time (s)');
ylabel('Calculated distance (m)');
legend('Calculated', 'Error', 'Actual');


grid minor


figure
kdprime = kalmanFilterImproved(phone_mat, d_0, A_0, n, Q, R);
plot(phone_mat(:,3), (phone_mat(:,2)/100) ,'r');
hold on
plot(phone_mat(:,3), kdprime);
hold on
plot(phone_mat(:,3), abs(kdprime - test_distance/100));
legend('Actual', 'Kalman estimation', 'Kalman error');

xlabel('Time (s)');
ylabel('Calculated distance (m)');
title(['Estimated distance using the improved Kalman filter for a test distance of ' num2str(test_distance/100)  'm']);
grid minor

mse_kalman = immse(kdprime, ones(size(kdprime))*test_distance/100)

%%%Kalman MSE
mse_kalman_array = [ ];
for i = 10:10:250
    pphone_mat = [phone_table.RSSI phone_table.Distance phone_table.Time];
    pphone_mat = pphone_mat(pphone_mat(:,2) == i,:);
    pphone_mat(:,3) = pphone_mat(:,3) - pphone_mat(1,3);
    kdprime = kalmanFilter(pphone_mat, d_0, A_0, n, Q, R);
    mse_kalman = immse(kdprime, ones(size(kdprime))*i/100);
    mse_kalman_array = vertcat(mse_kalman_array, mse_kalman);
end


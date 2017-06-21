close all
clear all

%%%Load table

load('levelfivetable.mat')

loadTest = 'levelfivetable.mat';
testDevice = 'Nexus 5';


untitled = sortrows(levelfivetable,'Time','ascend');


d = (0:0.01:2.5); %distance
A_0 = -55.142;  %reference RSSI
n =4.41 %path loss
d_0 = 0.5; %reference distance
avgs = [  ]; %Averages
vara = [  ]; %Varaiance
stdva = [  ]; %Standard deviation of data
phone_table = untitled(strcmp(untitled.Found_Device, testDevice) , :);
phone_mat = [phone_table.RSSI phone_table.Distance phone_table.Time];


%%Averages
for i = 10:10:250
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == i,:);
    temp = [i mean(temp_phone_mat(:,1))];
    avgs = vertcat(avgs, temp);
    temp_phone_mat = [];
end

%%Vaiances
for i = 10:10:250
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == i,:);
    temp = [i var(temp_phone_mat(:,1))];
    vara = vertcat(vara, temp);
    temp_phone_mat = [];
end

%%Standard deviation
for i = 10:10:250
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == i,:);
    temp = [i std(temp_phone_mat(:,1))];
    stdva = vertcat(stdva, temp);
    temp_phone_mat = [];
end

%Plot path loss 
pl = -10*n*log10(d/d_0) + A_0;

semilogx(d, pl);
xlabel('Distance (m)');
ylabel('Path-loss (dBm)');

hold on



%%%%%%Plot average
plot((avgs(:,1)/100), avgs(:,2) , 'k');


noise_power = 1;
for i = 1:5
    dist = sqrt(noise_power)*randn(1,size(pl,2)) + pl;
    semilogx(d, dist, 'bo');
end
title(['Theoretical path loss model as a function of distance \sigma =' num2str(noise_power)]);

legend('Mean path-loss', 'Log-normal shadowing');

grid minor;

figure 
hold on
for i = 10:10:250
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == i,:);
    %plot(i*ones(size(temp_phone_mat(:,1)), temp_phone_mat(:,1));
    scr = scatter((i/100)*ones(size(temp_phone_mat(:,1))),temp_phone_mat(:,1),'b');
    temp_phone_mat = [];
end

pav = plot((avgs(:,1)/100), avgs(:,2) , 'k');
xlabel('Distance (m)');
ylabel('RSSI (dBm)');
title('Logged results with average');
legend([scr pav], 'Raw data point', 'Average');
grid minor

figure


hold on

% Plot data-points
for i = 10:10:250
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == i,:);
    scr = scatter((i/100)*ones(size(temp_phone_mat(:,1))),temp_phone_mat(:,1),'b');
    temp_phone_mat = [];
end

xlabel('Distance (m)');
ylabel('Path-loss (dBm)');
title('Optimal curve fitting the measurments for the level 3 laboratory');
pav = plot(d, pl);
legend([pav scr],  'Path-loss curve', 'Measurements');
grid minor

figure
plot((vara(:,1)/100), vara(:,2));
title('Variance of measurments against distance');
xlabel('Distance (m)');
ylabel('Variance (dBm)');
grid minor



figure
plot((stdva(:,1)/100), stdva(:,2));
title('Log-normal shadowing of measurments against distance');
xlabel('Distance (m)');
ylabel('\sigma (dBm)');
grid minor

average_var_stdv = sqrt(mean(vara(:,2)))
average_stdv = mean(stdva(:,2))


figure
plot(avgs(:,1)/100, ((abs(avgs(:,1)/100 - d_0*10.^((A_0 - avgs(:,2))/(10*n))))/(avgs(:,1)/100))*100);
title('Percentage average error from path loss model');
xlabel('Actual Distance (m)');
ylabel('Path loss model percentage error');
grid minor

figure
plot(avgs(:,1)/100, abs(avgs(:,1)/100 - d_0*10.^((A_0 - avgs(:,2))/(10*n))));
title('Average absolute error from path loss model');
xlabel('Actual Distance (m)');
ylabel('Path loss model error (m)');
grid minor



errormat = abs(avgs(:,1)/100 - d_0*10.^((A_0 - avgs(:,2))/(10*n)));
mean_error = mean(errormat);
mean_squared_error = immse(avgs(:,1)/100, d_0*10.^((A_0 - avgs(:,2))/(10*n)))

optimal_n = find_optimal_n(loadTest, testDevice, d_0)

%%% Find optimal n
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mse_array_d = [];
foo = 0.1:0.1:2.5;
for i = 1:25
    optimal_n = find_optimal_n(loadTest, testDevice, i/10);
    mse = optimal_n(:,2);
    mse_array_d = vertcat(mse_array_d, mse);
end


%%%%For differ

figure
plot(foo, mse_array_d);
grid minor

hold on

loadTest = 'untitleddata2.mat';
mse_array_d = [];
foo = 0.1:0.1:2.5;
for i = 1:25
    optimal_n = find_optimal_n(loadTest, testDevice, i/10);
    mse = optimal_n(:,2);
    mse_array_d = vertcat(mse_array_d, mse);
end


plot(foo, mse_array_d);


loadTest = 'upstairshand.mat';
mse_array_d = [];
foo = 0.1:0.1:2.5;
for i = 1:25
    optimal_n = find_optimal_n(loadTest, testDevice, i/10);
    mse = optimal_n(:,2);
    mse_array_d = vertcat(mse_array_d, mse);
end

plot(foo, mse_array_d);



close all

load('roomopenorientation.mat')
untitled = sortrows(roomopenorientation,'Time','ascend');
phone_table = untitled(strcmp(untitled.Found_Device, 'Galaxy S6 edge') , :);
distance = 100;
phone_table = phone_table(phone_table.Distance == distance, :);
phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.wOrientation phone_table.xOrientation phone_table.yOrientation phone_table.zOrientation phone_table.Time];


test_orientation = 135; %Choose from 0 45 90 135 180 225 270 315 
test_orientation_array = [0 45 90 135 180 225 270 315 360];
n_array = 1:0.01:3;



A_0 = -42;
n = 3.84; 
d_0 = 0.5;





phone_mat = phone_mat(phone_mat(:,2) == test_orientation,:);
phone_mat(:,7) = phone_mat(:,7) - phone_mat(1,7);





phone_mat(:,8) = d_0*10.^((A_0 - phone_mat(:,1))/(10*n));

phone_mat(:,9) = abs(phone_mat(:,8) - distance/100);


%Kalman filter
[kdprime, yawPrime, pitchPrime, rollPrime] = kalmanFilterAll(phone_mat, d_0, orientation_parameters, test_orientation);



figure;
%plot x,y --> time,distance
plot(phone_mat(:,7),phone_mat(:,8)); %Measured
hold on
plot(phone_mat(:,7), phone_mat(:,9)); %Measured error
hold on
plot(phone_mat(:,7), ones(size(phone_mat(:,2)))*distance/100); %Actual
hold on
plot(phone_mat(:,7), kdprime); %Kalman filtered
hold on
plot(phone_mat(:,7), abs(kdprime - distance/100)); %Kalman error

mse = immse(kdprime, ones(size(kdprime))*distance/100)

xlabel('time (s)');
ylabel('distance (m)');
str=sprintf('Distance and error with %d deg orientation', test_orientation);
title(str);
legend('Measured', 'Error real', 'Actual', 'Kalman filtered', 'Kalman error');
grid minor


quat = [phone_mat(:,3) phone_mat(:,4) phone_mat(:,5) phone_mat(:,6)];

angle_mat = [];
%%% Quat to angle - [yaw, pitch, roll]
[angle_mat(:,1), angle_mat(:,2), angle_mat(:,3)] = quat2angle([phone_mat(:,3) phone_mat(:,4) phone_mat(:,5) phone_mat(:,6)], 'XYZ');


figure
plot(phone_mat(:,7), radtodeg(yawPrime));
hold on
plot(phone_mat(:,7), radtodeg(angle_mat(:,1)));
yaw = mean(radtodeg(angle_mat(:,1)))
title('Kalman filtered accelerometer Azimuth');
xlabel('Time (s)');
ylabel('Azimuth angle (deg)');
grid minor;

figure
plot(phone_mat(:,7), radtodeg(pitchPrime));
hold on
plot(phone_mat(:,7), radtodeg(angle_mat(:,2)));
pitch = mean(radtodeg(angle_mat(:,2)))
title('Kalman filtered accelerometer pich');
xlabel('Time (s)');
ylabel('Pitch angle (deg)');
grid minor;

figure
plot(phone_mat(:,7), radtodeg(rollPrime));
hold on
plot(phone_mat(:,7), radtodeg(angle_mat(:,3)));
roll = mean(radtodeg(angle_mat(:,3)))
title('Kalman filtered accelerometer roll');
xlabel('Time (s)');
ylabel('Roll angle (deg)');
grid minor;




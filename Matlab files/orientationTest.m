close all
clear all
load('roomopenorientation.mat')
untitled = sortrows(roomopenorientation,'Time','ascend');
phone_table = untitled(strcmp(untitled.Found_Device, 'Galaxy S6 edge') , :);
distance = 100;
phone_table = phone_table(phone_table.Distance == distance, :);
phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.wOrientation phone_table.xOrientation phone_table.yOrientation phone_table.zOrientation phone_table.Time];

test_orientation = 0; %Choose from 0 45 90 135 180 225 270 315 360
test_orientation_array = [0 45 90 135 180 225 270 315];
n_array = [2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0];

phone_mat = phone_mat(phone_mat(:,2) == test_orientation,:);
phone_mat(:,7) = phone_mat(:,7) - phone_mat(1,7);

test_orientation
averageW = mean(phone_mat(:,3))
averageX = mean(phone_mat(:,4))
averageY = mean(phone_mat(:,5))
averageZ = mean(phone_mat(:,6))

quat = [averageW averageX averageY averageZ];
[yaw, pitch, roll] = quat2angle(quat, 'XYZ');
yaw = radtodeg(yaw)
pitch = radtodeg(pitch)
roll = radtodeg(roll)
averageOrientation = [     ];

for i = 1:length(test_orientation_array);
    orientation = test_orientation_array(i);
    phone_mat = [phone_table.RSSI phone_table.Orientation phone_table.wOrientation phone_table.xOrientation phone_table.yOrientation phone_table.zOrientation phone_table.Time];
    phone_mat = phone_mat(phone_mat(:,2) == orientation,:);
    currentAverage(:,1) = orientation;
    
    %w
    currentAverage(:,2) = mean(phone_mat(:,3));
    
    %x
    currentAverage(:,3) = mean(phone_mat(:,4));
    
    %y
    currentAverage(:,4) = mean(phone_mat(:,5));
    
    %z
    currentAverage(:,5) = mean(phone_mat(:,6));
    
    [currentAverage(:,6), currentAverage(:,7), currentAverage(:,8)] = quat2angle([currentAverage(:,2), currentAverage(:,3), currentAverage(:,4),currentAverage(:,5)], 'XYZ');
    
    currentAverage(:,6) = radtodeg(currentAverage(:,6));
    currentAverage(:,7) = radtodeg(currentAverage(:,7));
    currentAverage(:,8) = radtodeg(currentAverage(:,8));
    averageOrientation = vertcat(averageOrientation, currentAverage);
end

plot(averageOrientation(:,1), averageOrientation(:,8));
title('Actual orientaton to accelerometer orientation');
ylabel('Accelerometer orientation (deg)');
xlabel('Actual orientation (deg)');
grid minor
hold on
plot(averageOrientation(:,1), averageOrientation(:,7));
plot(averageOrientation(:,1), averageOrientation(:,6));
legend('Azimuth', 'Pitch', 'Roll');

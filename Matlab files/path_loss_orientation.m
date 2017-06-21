close all
clear all
%%%Load table
load('roomopenorientation.mat')

loadTest = 'roomopenorientation.mat';
testDevice = 'Galaxy S6 edge';


untitled = sortrows(roomopenorientation,'Time','ascend');

d = (0.1:0.1:1);

%R
d_0 = 0.5;
test_orientation_array = [0 45 90 135 180 225 270 315];
avgs = [  ];
orientation_parameters = [   ];

full_table = untitled(strcmp(untitled.Found_Device, testDevice) , :);

figure

%%%Find optimal parameters at each orientation
%%%Carry optimum
for i = 1:length(test_orientation_array)


    phone_table = full_table(full_table.Orientation == test_orientation_array(i) , :); 
    phone_mat = [phone_table.RSSI phone_table.Distance phone_table.Time];
    test_orientation_array(i)
    for j = 10:10:100
        temp_phone_mat = phone_mat;
        temp_phone_mat = temp_phone_mat(phone_mat(:,2) == j,:);
        temp = [j mean(temp_phone_mat(:,1)), test_orientation_array(i)];
        avgs = vertcat(avgs, temp);
        temp_phone_mat = [];
    end
    avgs

    [optimal_n, A_0] = opt_main_orientation(avgs, d_0);
    temp_param = [test_orientation_array(i), optimal_n, A_0];
    orientation_parameters = vertcat(orientation_parameters, temp_param);


    

    pl = -10*optimal_n(1,1)*log10(d2/d_0) + A_0;
   
    plot(d2,pl);
    
    legendInfo{i} = [num2str(test_orientation_array(i)) '^{\circ}'];
    grid minor
    hold on

    avgs = [  ];

end

grid minor
title('Optimal path loss curve for each orientation');
xlabel('Distance (m)');
ylabel('Path loss (dBm)');
grid minor 

legend(legendInfo);
grid minor;


figure 
plot(orientation_parameters(:,1), orientation_parameters(:,2));
title('Optimal n');
ylabel('n');
xlabel('Orientation');
grid minor;



figure 
plot(orientation_parameters(:,1), orientation_parameters(:,4));
title(['Reference RSSI A_{0} at the reference distance of ' num2str(d_0) 'm']);
grid minor;


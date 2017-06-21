function optimal_n = find_optimal_n(testReading, testDevice, d_01)
A = load(testReading);

A = struct2cell(A);
A = A{1};

untitled = sortrows(A,'Time','ascend');

avgs = [  ];

phone_table = untitled(strcmp(untitled.Found_Device, testDevice) , :);
phone_mat = [phone_table.RSSI phone_table.Distance phone_table.Time];

for i = 10:10:250
    temp_phone_mat = phone_mat;
    temp_phone_mat = temp_phone_mat(phone_mat(:,2) == i,:);
    temp = [i mean(temp_phone_mat(:,1))];
    avgs = vertcat(avgs, temp);
    temp_phone_mat = [];
end

A_0 = avgs(d_01*10,2);
mean_error_mat = [  ];

for n = 1:0.01:5
    errormat = immse(avgs(:,1)/100, d_01*10.^((A_0 - avgs(:,2))/(10*n)));
    mean_error = [n, mean(errormat), A_0];
    mean_error_mat = vertcat(mean_error_mat, mean_error);
end

[M, I] = min(mean_error_mat(:,2));
optimal_n_vect = mean_error_mat(I,:);
optimal_n = optimal_n_vect(1,:);
end
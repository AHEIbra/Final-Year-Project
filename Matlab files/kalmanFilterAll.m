function [kdprime, yawPrime, pitchPrime, rollPrime] = kalmanFilterAll(phone_mat, d_0, orientation_parameters, orientation)

A = eye(4); %State transition
B = zeros(4); %Control
H = eye(4); %Observation
Q = eye(4)*0.01; %initial process error
R = zeros(4); %initial Measurement error
x_n = [0 0 0 0]; %initial state estimate
P_n = [5 0 0 0; 0 5 0 0; 0 0 5 0; 0 0 0 5]; %initial covariance estimate
u_n = [0 0 0 0]; %control
x_rprime = [     ];
P_r = [  ];


x_Trssi = [ ];
x_Tyaw = [ ];
x_Tpitch = [ ];
x_Troll = [ ];


kalman_mat(:,1) = phone_mat(:,1);

%%% Convert quaternions to angles
quat = [phone_mat(:,3) phone_mat(:,4) phone_mat(:,5) phone_mat(:,6)];

%%% Quat to angle - [yaw, pitch, roll]
[kalman_mat(:,2), kalman_mat(:,3), kalman_mat(:,4)] = quat2angle(quat, 'XYZ');

for i = 1:size(kalman_mat(:,1),1)
    %%%%Prediction
    x_p = A*x_n' + B*u_n';
    P_p = A*P_n*A.' + Q;

    %%%Observation
    innov = [kalman_mat(i,1), kalman_mat(i,2), kalman_mat(i,3), kalman_mat(i,4)] - H*x_p;
    innov_cov = H*P_p*H.' + R;

    K = P_p*H.' * inv(innov_cov);
    x_f = x_p + K*innov;
    x_n = [x_f(1,1) x_f(2,2) x_f(3,3) x_f(4,4)];
    
    x_rprime = vertcat(x_rprime, x_n);
    P_n = (eye(size(P_n)) - K*H)*P_p;
     
    x_rssi = kalman_mat(i,1);
    x_yaw  = kalman_mat(i,2);
    x_pitch = kalman_mat(i,3);
    x_roll = kalman_mat(i,4);
    
    x_Trssi = vertcat(x_Trssi, x_rssi);
    x_Tyaw = vertcat(x_Tyaw, x_yaw);
    x_Tpitch = vertcat(x_Tpitch, x_pitch);
    x_Troll = vertcat(x_Troll, x_roll);
    
    R = [var(x_Trssi) 0 0 0; 0 var(x_Tyaw) 0 0; 0 0 var(x_Tpitch) 0; 0 0 0 var(x_Troll)];
end


A_0 = orientation_parameters(orientation_parameters(:,1) == orientation,4); 
n = orientation_parameters(orientation_parameters(:,1) == orientation, 2);
kdprime = d_0*10.^((A_0 - x_rprime(:,1).')/(10*n)); %Filtered RSSI output
yawPrime = x_rprime(:,2);
pitchPrime = x_rprime(:,3);
rollPrime = x_rprime(:,4);


end
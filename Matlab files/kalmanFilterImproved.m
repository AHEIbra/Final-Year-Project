function kdprime = kalmanFilterImproved(phone_mat, d_0, A_0, n, Q, R)

A = [1]; %State transition
B = [0]; %Control
H = [1]; %Observation
% Q = [0.01]; %Process error
% R = [1]; %Measurement error
x_n = 0; %initial state estimate
P_n = [5]; %initial covariance estimate
u_n = [0]; %control
x_rprime = [  ];
P_r = [  ];

x_t = [ ];

for i = 1:size(phone_mat(:,1),1)
    %%%%Prediction
    x_p = A*x_n + B*u_n;
    P_p = A*P_n*A.' + Q;

    %%%Observation
    innov = phone_mat(i,1) - H*x_p;
    innov_cov = H*P_p*H.' + R;

    K = P_p*H.' * inv(innov_cov);
    x_n = x_p + K*innov;
    x_rprime = vertcat(x_rprime, x_n);
    P_n = (eye(size(P_n)) - K*H)*P_p;
    P_r = vertcat(P_r ,P_n);
    
    x_i = phone_mat(i,1);
    x_t = vertcat(x_t, x_i);
    
    
    R = var(x_t);

end


kdprime = d_0*10.^((A_0 - x_rprime.')/(10*n)); %Kalman output


end
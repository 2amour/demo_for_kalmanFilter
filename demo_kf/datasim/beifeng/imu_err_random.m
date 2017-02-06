function [ Gyro_b,Gyro_r,Gyro_wg,Acc_r ] = imu_err_random( t,T,Gyro_b,Gyro_r,Gyro_wg,Acc_r )
% IMU�����ģ��
g = 9.7803698;                       %�������ٶȣ���λ����/��/�룩
Wie = 7.292115147e-5;                %������ת�����ʣ���λ������/�룩
deg_rad = pi/180;

Da_bias = [0.0001; 0.001;0.001]*g;   %���ٶ���ƫ��Ӧ������������м��ٶ���ƫ����һ�£�

Ta = 1800;                           %���ٶ�һ������ɷ�������ʱ��
Tg = 3600;                           %����һ������ɷ��������¼�

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if t == 0
    Acc_r = Da_bias.*randn(3,1);
    
    Gyro_b = 0.1*deg_rad/3600*randn(3,1);   %�������0.1��deg/h��
    Gyro_r = 0.1*deg_rad/3600*randn(3,1);   %����һ������ɷ����0.1��deg/h��
    Gyro_wg = 0.1*deg_rad/3600*randn(3,1);  %���ݰ�����0.1��deg/h��
else
    Acc_wa = sqrt(2*T/Ta)*Da_bias.*randn(3,1);  %���ٶ�һ������ɷ���̰�����
    Acc_r = exp(-1.0*T/Ta)*Acc_r+Acc_wa;        %���ٶ�һ������ɷ����
    
    Gyro_wr = sqrt(2*T/Tg)*0.1*deg_rad/3600*randn(3,1); %����һ������ɷ���̰�����0.1��deg/h��
    Gyro_r = exp(-1.0*T/Tg)*Gyro_r+Gyro_wr; %����һ������ɷ����0.1��deg/h��
    Gyro_wg = 0.1*deg_rad/3600*randn(3,1);  %���ݰ�����0.1��deg/h��
end

end
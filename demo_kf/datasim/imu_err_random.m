function [Gyro_w,Gyro_rw,Acc_w,Acc_rw] = imu_err_random( t,Gyro_w,Gyro_rw,Acc_w,Acc_rw)
% IMU�����ģ��

%%%%Gyro: ƫ��ȶ���+������+�����������
%%%%Accel: ƫ��ȶ���+������+�����������
g = 9.7803698;                     %�������ٶȣ���λ����/��/�룩
mg = g/1000;

%%%%%��������
ProcessNoiseVariance = [3.9e-04    4.5e-4       7.9e-4;   %%%Accelerate_Variance
                        1.9239e-7, 3.5379e-7, 2.4626e-7;%%%Accelerate_Bias_Variance
                        8.7e-04,1.2e-03,1.1e-03;      %%%Gyroscope_Variance
                        1.3111e-9,2.5134e-9,    2.4871e-9    %%%Gyroscope_Bias_Variance
                      ];
                                              
%%%%%�����ϵ� ��ƫ
AccelInit_bias = [5;5;8]*mg;   %%x/y: +-50 mg  z: +-80 mg
GyroInit_bias = 1/400;   %%%+-2 deg/s

%%%%%������
Da_w_sigma = sqrt(ProcessNoiseVariance(1,:)');   
Dg_w_sigma = sqrt(ProcessNoiseVariance(3,:)');   

%%%%%�����������:w = ����(������)
Da_rw_sigma = sqrt(ProcessNoiseVariance(2,:)');   
Dg_rw_sigma = sqrt(ProcessNoiseVariance(4,:)');   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if t == 0

    Acc_b = AccelInit_bias.*randn(3,1);    %%% ���ٶȼƳ�ʼ����ƫ
    Gyro_b = GyroInit_bias*randn(3,1);   %%% �����ǳ�ʼ����ƫ

    Acc_rw = Acc_b;
    Gyro_rw = Gyro_b;
else
    Acc_w = Da_w_sigma.*randn(3,1);               %���ٶȰ�����
    Acc_rw = Acc_rw + Da_rw_sigma.*randn(3,1);    %���ٶ������������(����)

    Gyro_w = Dg_w_sigma.*randn(3,1);               %���ٶȰ�����
    Gyro_rw = Gyro_rw + Dg_rw_sigma.*randn(3,1);   %���ٶ������������(����)
end

end




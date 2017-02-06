close all
clear all
t = 0;
T = 0.02;
t_stop = 164.0;

%%����������
atti = zeros(3,1);         %��ת��������ƫ������λ���ȣ�
atti_rate = zeros(3,1);    %��ת�����ʡ����������ʡ�ƫ�������ʣ���λ����/�룩
veloB = zeros(3,1);        %�ɻ��˶��ٶ�--X����Y��ͷ��Z���򣨵�λ����/�룩
acceB = zeros(3,1);        %�ɻ��˶����ٶ�--X����Y��ͷ��Z���򣨵�λ����/��/�룩
posi = zeros(3,1);         %������������ʼλ�þ��ȡ�γ�ȡ��߶ȣ���λ���ȡ��ȡ��ף�
posi = [26;70;-19];

atti(1,1) = 0;            %
atti(2,1) = 0;            %
atti(3,1) = 90;            %��ʼ����ǣ���λ���ȣ�

%%IMU���
Wibb = zeros(3,1);         %����ϵ�������������λ����/�룩
Fb = zeros(3,1);           %����ϵ���ٶȼ��������λ����/��/�룩
Gyro_fix = zeros(3,1);      %����ϵ�����ǹ̶�����������λ������/�룩
Acc_fix = zeros(3,1);       %����ϵ���ٶȼƹ̶�����������λ����/��/�룩
Gyro_b = zeros(3,1);       %�����������������/�룩
Gyro_r = zeros(3,1);       %����һ������ɷ���̣�����/�룩
Gyro_wg = zeros(3,1);      %���ݰ�����������/�룩
Acc_r = zeros(3,1);        %���ٶ�һ������ɷ���̣���/�룩

%%UWB�������
posiG = zeros(3,1);        %UWB����ķ�����λ�ò��ֵ

%%�����ߵ�����
attiN = zeros(3,1);        %��������ʼ��̬
veloN = zeros(3,1);        %��������ʼ�ٶȣ�����ڵ���ϵ��
posiN = zeros(3,1);        %��������ʼλ��
WnbbA_old = zeros(3,1);    %���ٶȻ����������λ�����ȣ�

posiN = posi;
attiN = atti;

%%KALMAN�˲����
T_D = 1;                   %��ɢ����
T_M = 0;                   %�˲��������ʱ�䣨�룩
Xc = zeros(18,1);              %�ۺ�ģ��״̬��
PK = zeros(18,18);               %Э������
Xerr = zeros(1,18);             %״̬�����������
kflag = 0;                 %GPS�ź���Ч��־λ��1-��Ч��

Acc_modi = zeros(3,1);     %���ٶȼ��������ֵ
Gyro_modi = zeros(3,1);     %�������������ֵ

%%��ʼ��׼
kc = 0;
tmp_Fb = zeros(3,1);
tmp_Wibb = zeros(3,1);
t_alig = 0;

old_veloB = veloB;
old_atti = atti;

deg_rad = pi/180;

TraceData = [];
IMUData =[];
UWBData = [];
kc = 0;bS = 1;
while t<=t_stop
	old_atti = atti;
    old_veloB = veloB;
    
    [t,atti,atti_rate,veloB,acceB] = trace(t,T,atti,atti_rate,veloB,acceB);
    
    [Wibb,Fb,posi,veloN,acceN] = IMUout(T,posi,atti,atti_rate,veloB,acceB,old_veloB,old_atti);

	if kc == 4
       [Ranging] = UwbOut(bS,posi);
	   Uwbranging_vector = Ranging';stationnumber_vector=bS;UWBBroadTime_vector=t;
	    UWBData = [UWBData;[Uwbranging_vector stationnumber_vector UWBBroadTime_vector]];
		kc = 0;
% 		bS = mod(bS ,5) + 1;
		switch bS
			case 1 
				bS = 3;
			case 2
				bS = 4;
		    case 3
				bS = 5;
			case 4
				bS = 1;
			case 5
				bS = 2;
		end
	end
    [Gyro_b,Gyro_r,Gyro_wg,Acc_r] = imu_err_random(t,T,Gyro_b,Gyro_r,Gyro_wg,Acc_r);
    
	%%%%%��������
    Fb = Fb+Acc_r;
    Wibb = Wibb+Gyro_b/deg_rad+Gyro_r/deg_rad+Gyro_wg/deg_rad;   %%%deg/s
	
	    %%��������
    TraceData = [TraceData;[t,atti',veloN',posi',Gyro_r',Acc_r',acceN']];
    
	a_vector =  Fb';g_vector=Wibb';  Temperature = 36.1;SampleTimePoint=t;
    IMUData = [IMUData;[a_vector,g_vector,Temperature,SampleTimePoint]];
   
   kc = kc + 1;
    t = t+T;
end
bSPcs = 5;
Uwbranging_vector = UWBData(:,1:bSPcs);
stationnumber_vector = UWBData(:,bSPcs+1);
UWBBroadTime_vector = UWBData(:,bSPcs+2);
save uwb_HandledFileToMatData.mat Uwbranging_vector stationnumber_vector UWBBroadTime_vector

a_vector =  IMUData(:,1:3);
g_vector =  IMUData(:,4:6);
Temperature =  IMUData(:,7);
SampleTimePoint =  IMUData(:,8);
save imu_HandledFileToMatData.mat a_vector g_vector  Temperature SampleTimePoint

hold on
plot(TraceData(:,8),TraceData(:,9),'r','DisplayName','Trace')
% axis equal;
plot(TraceData(:,1),TraceData(:,10),'r','DisplayName','Speed')

grid on
save TraceData.mat TraceData


t = 0;
T = 0.01;
t_stop = 1800.0;

%%����������
atti = zeros(3,1);         %��ת��������ƫ������λ���ȣ�
atti_rate = zeros(3,1);    %��ת�����ʡ����������ʡ�ƫ�������ʣ���λ����/�룩
veloB = zeros(3,1);        %�ɻ��˶��ٶ�--X����Y��ͷ��Z���򣨵�λ����/�룩
acceB = zeros(3,1);        %�ɻ��˶����ٶ�--X����Y��ͷ��Z���򣨵�λ����/��/�룩
posi = zeros(3,1);         %������������ʼλ�þ��ȡ�γ�ȡ��߶ȣ���λ���ȡ��ȡ��ף�
posi = [110;20;500];

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

%%GPS�������
posiG = zeros(3,1);        %GPS����ķ�����λ�ã����ȣ��ȣ���γ�ȣ��ȣ����߶ȣ��ף���
veloG = zeros(3,1);        %GPS����ķ������ٶȣ�������/�룩��������/�룩��������/�룩��


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

while t<=1
    [t_alig,atti,atti_rate,veloB,acceB] = trace(0,T,atti,atti_rate,veloB,acceB);
    
    %%IMU�������
    [Wibb,Fb,posi] = IMUout(T,posi,atti,atti_rate,veloB,acceB,old_veloB,old_atti);
    [Gyro_b,Gyro_r,Gyro_wg,Acc_r] = imu_err_random(t,T,Gyro_b,Gyro_r,Gyro_wg,Acc_r);
    
    Fb = Fb+Acc_r;
    Wibb = Wibb+Gyro_b/deg_rad+Gyro_r/deg_rad+Gyro_wg/deg_rad;
    
    tmp_Fb = tmp_Fb+Fb;
    tmp_Wibb = tmp_Wibb+Wibb;
    
    kc = kc+1;
    t = t+T;
end

Fb = tmp_Fb/kc;
Wibb = tmp_Wibb/kc;

attiN = atti;
[attiN] = align_cal(Wibb,Fb,posiN);
[veloN] = veloN0(atti,veloB);


input('press any key to continue...');


%%%%%%%%%%%%%%%%%%%%%%%%%%%���ݼ�¼%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TraceData = zeros(t_stop/T,10);
IMUData = zeros(t_stop/T,7);
GPSData = zeros(t_stop+1,7);
SinsData = zeros(t_stop/T,10);
KALData = zeros(t_stop+1,19);
ErrData = zeros(t_stop+1,19);

kc = 1;
kc_sins = 1;    
kc_kal = 1;
t = 0;                   %������ʼ

[posiG,veloG] = simu_gps(t,posi,atti,veloB);                       %GPS�������

[Xc,PK,Xerr] = kalman_gps_init(posiN,Xc,PK,Xerr);                  %Kalman�˲���ʼ��

GPSData(kc_kal,:) = [t,posiG',veloG'];
KALData(kc_kal,:) = [t,Xerr];
ErrData(kc_kal,:) = [t,Xc'];                                       %�����ʼ����

while t<=t_stop
    if (t>=kc*50-T && t<kc*50)
        kc = kc+1;
        disp(t);
    end
    
    old_atti = atti;
    old_veloB = veloB;
    
    [t,atti,atti_rate,veloB,acceB] = trace(t,T,atti,atti_rate,veloB,acceB);
    
    [Wibb,Fb,posi] = IMUout(T,posi,atti,atti_rate,veloB,acceB,old_veloB,old_atti);
    
    [Gyro_b,Gyro_r,Gyro_wg,Acc_r] = imu_err_random(t,T,Gyro_b,Gyro_r,Gyro_wg,Acc_r);
    
    Fb = Fb+Acc_r;
    Wibb = Wibb+Gyro_b/deg_rad+Gyro_r/deg_rad+Gyro_wg/deg_rad;
    
    
    %%��̬����
%     [ attiN,WnbbA_old ] = atti_cal_cq_modi( T,Wibb,attiN,veloN,posiN,WnbbA_old );
    attiN = atti;
    %%�ٶȽ���
    [veloN] = velo_cal( T,posiN,attiN,veloN,Fb );
    
    %%λ�ý���
    [ posiN ] = posi_cal( T,posiN,veloN );
    
    %%%%%%%%%%%%%%%%%%%%%%%%�˴�ģ��GPS���棬���Ƶ��1HZ%%%%%%%%%%%%%%%%%%%%%
    if T_M < 1
        T_M = T_M+T;
    end
    
    if (T_M >(1-T))&&(T_M <(1+T))
        kflag = 1;
        kc_kal = kc_kal+1;
        [posiG,veloG] = simu_gps(t,posi,atti,veloB);                       %GPS������� 
        
        [ Xc,PK,Xerr ] = Kalman_GPS( T_D,Fb,attiN,posiN,veloN,posiG,veloG,Xc,PK,Xerr,kflag );
        [ attiN,veloN,posiN ] = kalm_modi( attiN,veloN,posiN,Xc );
        
        GPSData(kc_kal,:) = [t,posiG',veloG'];
        KALData(kc_kal,:) = [t,Xerr];
        ErrData(kc_kal,:) = [t,Xc'];                        %��������
        
        Xc = zeros(18,1);
        
        kflag = 0;
        T_M = 0;
    end
    
    
    %%��������
    TraceData(kc_sins,:) = [t,atti',veloB',posi'];
    
    IMUData(kc_sins,:) = [t,Wibb',Fb'];
    
    SinsData(kc_sins,:) = [t,attiN',veloN',posiN'];
    
    kc_sins = kc_sins+1;
    
    t = t+T;                     %ʱ�����
    
end

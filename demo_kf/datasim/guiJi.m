load TraceSim.mat
via = [via;via(1,:)];
Point = 150;
Tf = 1/50;
plot3(via(:,1),via(:,2),via(:,3),'r-o');grid on;
xlabel('x����');ylabel('y����');zlabel('z����');
figure 
plot(via(:,1),via(:,2),'r-o');grid on;

theta = zeros(Pcs,3);
%%%%%%1.�켣1
theta(1:21,:) = repmat(([0,0,0] + 5*randn(1,3))/180*pi,21,1);
theta(22:25,:) = repmat(([0,0,45] + 5*randn(1,3))/180*pi,4,1);
theta(26:33,:) = repmat(([0,0,90] + 5*randn(1,3))/180*pi,8,1);
theta(34:37,:) = repmat(([0,0,135] + 5*randn(1,3))/180*pi,4,1);
theta(38:51,:) = repmat(([0,0,180] + 5*randn(1,3))/180*pi,14,1);
theta(52:56,:) = repmat(([0,0,225] + 5*randn(1,3))/180*pi,5,1);
theta(57:65,:) = repmat(([0,0,270] + 5*randn(1,3))/180*pi,9,1);
theta(66,:) = repmat(([0,0,0] + 5*randn(1,3))/180*pi,1,1);




T = zeros(4,4,Pcs+1);
TSeq = zeros(4,4,Pcs*Point);

for ki=1:Pcs+1
   Tk = transl(via(ki,:))*trotx(theta(ki,1))*troty(theta(ki,2))*trotz(theta(ki,3));
   T(:,:,ki) = Tk;
end


for ki=1:Pcs
   Ti = ctraj(T(:,:,ki), T(:,:,ki+1), Point);
   TSeq(:,:,(ki-1)*Point+1:ki*Point) = Ti;
end
about TSeq

% We can plot the motion of this coordinate frame by

% clf; tranimate(TSeq)


%%%%%%------------����̬����ת��Ϊ�켣xyz��ŷ����Euler
x = TSeq(1,4,:);x = x(:);
y = TSeq(2,4,:);y = y(:);
z = TSeq(3,4,:);z = z(:);
position = [x,y,z];
speed = diff(position)/Tf;
accel = diff(speed)/Tf;

euler = [];
for ki=1:size(TSeq,3)
    euler = [euler;tr2rpy(TSeq(:,:,ki))];
end

plot3(x,y,z,'b-o');grid on;
xlabel('x����');ylabel('y����');zlabel('z����');
axis equal
figure
plot(euler(:,3)/pi*180,'r');grid on;hold on;
plot(euler(:,2)/pi*180,'g');grid on;hold on;
plot(euler(:,1)/pi*180,'b');grid on;hold on;
legend('heading','pitch','roll')

save TSeq.mat TSeq

close all
addpath('datasim')
t = 0;
T = 0.02;
t_stop = 189.0;

%%����������
atti = zeros(3,1);         %��ת��������ƫ������λ���ȣ�
atti_rate = zeros(3,1);    %��ת�����ʡ����������ʡ�ƫ�������ʣ���λ����/�룩
veloB = zeros(3,1);        %�ɻ��˶��ٶ�--X����Y��ͷ��Z���򣨵�λ����/�룩
acceB = zeros(3,1);        %�ɻ��˶����ٶ�--X����Y��ͷ��Z���򣨵�λ����/��/�룩
posi = zeros(3,1);         %������������ʼλ�þ��ȡ�γ�ȡ��߶ȣ���λ���ȡ��ȡ��ף�
posi = [60;250;-1.9];

atti(1,1) = 0;            %
atti(2,1) = 0;            %
atti(3,1) = 90;            %��ʼ����ǣ���λ���ȣ�

%%IMU���
Wibb = zeros(3,1);         %����ϵ�������������λ����/�룩
Fb = zeros(3,1);           %����ϵ���ٶȼ��������λ����/��/�룩
Gyro_fix = zeros(3,1);      %����ϵ�����ǹ̶�����������λ������/�룩
Acc_fix = zeros(3,1);       %����ϵ���ٶȼƹ̶�����������λ����/��/�룩

Gyro_w = zeros(3,1);       %�����������������/�룩
Gyro_rw = zeros(3,1);       %����һ������ɷ���̣�����/�룩
Acc_w = zeros(3,1);      %���ݰ�����������/�룩
Acc_rw = zeros(3,1);        %���ٶ�һ������ɷ���̣���/�룩

%%UWB�������
posiG = zeros(3,1);        %UWB����ķ�����λ�ò��ֵ

%%�����ߵ�����
attiN = zeros(3,1);        %��������ʼ��̬
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
ALLNUM = size(accel,1);
for	ki = 1:ALLNUM

    
%     [t,atti,atti_rate,veloB,acceB] = trace_(t,T,atti,atti_rate,veloB,acceB);
    
    atti = euler(ki,:)';
    atti_rate = (euler(ki+1,:)'-euler(ki,:)')/pi*180; %%deg
    
    R = rpy2r(atti');
    posi = position(ki,:)';
    veloB = (R*speed(ki,:)');
    acceB = (R*accel(ki,:)');
    
    [Wibb,Fb,posi,veloN,acceN] = IMUout(T,posi,atti,atti_rate,veloB,acceB,old_veloB,old_atti);

    old_atti = atti;
    old_veloB = veloB;
    
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
%     [Gyro_b,Gyro_r,Gyro_wg,Acc_r] = imu_err_random(t,T,Gyro_b,Gyro_r,Gyro_wg,Acc_r);
    [Gyro_w,Gyro_rw,Acc_w,Acc_rw] = imu_err_random( t,Gyro_w,Gyro_rw,Acc_w,Acc_rw);
    
	%%%%%��������
    Fb = Fb + Acc_w + Acc_rw;
    Wibb = Wibb + Gyro_w/deg_rad + Gyro_rw/deg_rad;   %%%deg/s
	
	%%��������
    TraceData = [TraceData;[t,posi',veloN',atti',...
                           (Acc_w + Acc_rw)',(Gyro_w/deg_rad + Gyro_rw/deg_rad)',acceN']];

    
	a_vector =  Fb';g_vector=Wibb';  Temperature = 36.1;SampleTimePoint=t;
    IMUData = [IMUData;[a_vector,g_vector,Temperature,SampleTimePoint]];
   
   kc = kc + 1;
    t = t+Tf;
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
plot(TraceData(:,2),TraceData(:,3),'r','DisplayName','Trace')
axis equal;
% plot(TraceData(:,1),TraceData(:,10),'r','DisplayName','Speed')

grid on
save TraceData.mat TraceData


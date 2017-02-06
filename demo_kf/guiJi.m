if 1
    load TraceSim.mat
    via = [via;via(1,:)];
    via(:,3) = -via(:,3)*4;  %%%%��ֵ
    Point = 250;
    Tf = 1/50;
    plot3(via(:,1),via(:,2),via(:,3),'r-o');grid on;
    xlabel('x����');ylabel('y����');zlabel('z����');
    title('�켣�ռ���άͼ')
    figure 
    plot(via(:,1),via(:,2),'r-o');grid on;
    title('�켣2άͼƽ��ͼ')

    theta = zeros(Pcs,3);
    %%%%%%1.�켣1
    theta(1:21,:) = repmat(([0,0,0] + 15*randn(1,3))/180*pi,21,1);
    theta(22:25,:) = repmat(([0,0,45] + 15*randn(1,3))/180*pi,4,1);
    theta(26:33,:) = repmat(([0,0,90] + 15*randn(1,3))/180*pi,8,1);
    theta(34:37,:) = repmat(([0,0,135] + 15*randn(1,3))/180*pi,4,1);
    theta(38:51,:) = repmat(([0,0,180] + 15*randn(1,3))/180*pi,14,1);
    theta(52:56,:) = repmat(([0,0,225] + 15*randn(1,3))/180*pi,5,1);
    theta(57:65,:) = repmat(([0,0,270] + 15*randn(1,3))/180*pi,9,1);
    theta(66,:) = repmat(([0,0,0] + 15*randn(1,3))/180*pi,1,1);


    figure
    plot(theta(:,3)/pi*180,'r');grid on;hold on;
    plot(theta(:,2)/pi*180,'g');grid on;hold on;
    plot(theta(:,1)/pi*180,'b');grid on;hold on;
    legend('heading','pitch','roll')
    title('��̬�Ƕ�ͼ')

    T = zeros(4,4,Pcs+1);
    TSeq = zeros(4,4,Pcs*Point);

    for ki=1:Pcs+1
       %%%%ƽ��+ ��ת  n -> b   zyx 
       Tk = transl(via(ki,:))*trotz(theta(ki,3))*troty(theta(ki,2))*trotx(theta(ki,1));
       %%%%%b -> n
       %Tk = Tk';
    %    Tk = trotx(-theta(ki,1))*troty(-theta(ki,2))*trotz(-theta(ki,3))*transl(-via(ki,:));
       T(:,:,ki) = Tk;
    end


    for ki=1:Pcs
       Ti = ctraj(T(:,:,ki), T(:,:,ki+1), Point);  %%%�����Ϊn->b����̬ UEN
       for kj=1:Point
          Ti(:,:,kj) = Ti(:,:,kj)*diag([1,1,-1,1]); %%%UEN -> DEN
       end
       TSeq(:,:,(ki-1)*Point+1:ki*Point) = Ti;
    end
    about TSeq

    % We can plot the motion of this coordinate frame by
    % figure;grid on; box on;
    % tranimate(TSeq,'fps',5)


    %%%%%%------------����̬����ת��Ϊ�켣xyz��ŷ����Euler
    x = TSeq(1,4,:);x = x(:);
    y = TSeq(2,4,:);y = y(:);
    z = TSeq(3,4,:);z = z(:);
    position = [x,y,z];
    speed = diff(position)/Tf;
    accel = diff(speed)/Tf;

    euler = [];%%n -> b
    for ki=1:size(TSeq,3)
        ypr = tr2rpy(TSeq(:,:,ki),'zyx');
        euler = [euler;[ypr(3),ypr(2),ypr(1)]];
    end
    figure
    plot3(x,y,z,'b-o');grid on;
    xlabel('x����');ylabel('y����');zlabel('z����');
    axis equal
    figure
    plot(euler(:,3)/pi*180,'r');grid on;hold on;
    plot(euler(:,2)/pi*180,'g');grid on;hold on;
    plot(euler(:,1)/pi*180,'b');grid on;hold on;
    legend('heading','pitch','roll')

    save TSeq.mat TSeq euler position speed accel Tf
end


%%%%%%------------���ɴ���������
close all
load TSeq.mat 
load TraceSim.mat
addpath('datasim')
t = 0;
T = 0.02;
t_stop = 189.0;

%%����������
atti = zeros(3,1);         %��ת��������ƫ������λ���ȣ�
atti_rate = zeros(3,1);    %��ת�����ʡ����������ʡ�ƫ�������ʣ���λ����/�룩
veloB = zeros(3,1);        %�ɻ��˶��ٶ�--X����Y��ͷ��Z���򣨵�λ����/�룩
acceB = zeros(3,1);        %�ɻ��˶����ٶ�--X����Y��ͷ��Z���򣨵�λ����/��/�룩
posi = [60;250;-1.9];         %������������ʼλ�þ��ȡ�γ�ȡ��߶ȣ���λ���ȡ��ȡ��ף�

%%IMU���
Wibb = zeros(3,1);         %����ϵ�������������λ����/�룩
Fb = zeros(3,1);           %����ϵ���ٶȼ��������λ����/��/�룩
Gyro_fix = zeros(3,1);      %����ϵ�����ǹ̶�����������λ������/�룩
Acc_fix = zeros(3,1);       %����ϵ���ٶȼƹ̶�����������λ����/��/�룩

Gyro_w = zeros(3,1);       %�����������������/�룩
Gyro_rw = zeros(3,1);       %����һ������ɷ���̣�����/�룩
Acc_w = zeros(3,1);      %���ݰ�����������/�룩
Acc_rw = zeros(3,1);        %���ٶ�һ������ɷ���̣���/�룩

old_veloB = veloB;
old_atti = euler(1,:)';

deg_rad = pi/180;

TraceData = [];
IMUData =[];
UWBData = [];
kc = 0;bS = 1;
ALLNUM = size(accel,1);
for	ki = 1:ALLNUM
    
    atti = euler(ki,:)';  %%%rad  n -> b
    
    if euler(ki+1,3) - euler(ki,3) < -pi 
         atti_rate = ([0 0 2*pi]' + euler(ki+1,:)'-euler(ki,:)')/Tf; %%rad/s
    else if euler(ki+1,3) - euler(ki,3) > pi 
               atti_rate = (euler(ki+1,:)'-euler(ki,:)'-[0 0 2*pi]')/Tf; %%rad/s
        else
               atti_rate = (euler(ki+1,:)'-euler(ki,:)')/Tf; %%rad/s
        end
    end
    %Rbn = rpy2r(atti','zyx');  %%%n -> b
    %%DCM������ϵN-->B   ŷ������ת����Ϊn->b   ZYX
    roll = atti(1,1);%��λ������/��
    pitch = atti(2,1);%��λ������/��
    head = atti(3,1);%��λ������/��
    Rz = [cos(head),-sin(head),0;
              sin(head),cos(head),0;
               0,0,1];
    Ry = [cos(pitch),0,sin(pitch);
               0,1,0;
              -sin(pitch),0,cos(pitch)];
    Rx = [1,0,0;
              0,cos(roll),-sin(roll);
              0,sin(roll),cos(roll)];	  
    Rbn = Rz*Ry*Rx;   %%%%n->b

    %Rbn= R';
    posi = position(ki,:)';
    veloB = (Rbn*speed(ki,:)');
    acceB = (Rbn*accel(ki,:)');
    
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
    [Gyro_w,Gyro_rw,Acc_w,Acc_rw] = imu_err_random( t,Gyro_w,Gyro_rw,Acc_w,Acc_rw);
    
	%%%%%��������
    Fb = Fb + Acc_w + Acc_rw;
    Wibb = Wibb + Gyro_w + Gyro_rw;   %%%deg/s

	%%��������
    if atti(3) < 0  
        atti(3) = atti(3) + 2*pi;
    end
    TraceData = [TraceData;[t,posi',veloN',atti'/pi*180,...
                           (Acc_w + Acc_rw)',(Gyro_w + Gyro_rw)',acceN']];

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
% plot(TraceData(:,1),TraceData(:,4),'r','DisplayName','heading')

grid on
save TraceData.mat TraceData


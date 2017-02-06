function [ Wibb,Fb,posi,veloN,acceN ] = IMUout( T,posi,atti,atti_rate,veloB,acceB,old_veloB,old_atti )

%%%%%%%%%%%%%%%%%%%%%������йصĲ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Re = 6378137.0;               %����뾶����λ���ף�
f = 1/298.257;                %������Բ��
Wie = 7.292115147e-5;         %������ת�����ʣ���λ������/�룩
g = 9.7803698;                 %�������ٶȣ���λ����/��/�룩

%%������λ��
posiNow = [110;20;-1.9];
lon = posiNow(1,1)*pi/180;
lat = posiNow(2,1)*pi/180;
x = posi(1,1);
y = posi(2,1);
height = posi(3,1);           

%%�������ʰ뾶
Rm = Re*(1-2*f+3*f*sin(lat)*sin(lat));
Rn = Re*(1+f*sin(lat)*sin(lat));   
                              
%%��̬�Ǻ���̬������
roll = old_atti(1,1);%��λ������/��
pitch = old_atti(2,1);%��λ������/��
head = old_atti(3,1);%��λ������/��
droll = atti_rate(1,1);%��λ������/��
dpitch = atti_rate(2,1);%��λ������/��
dhead = atti_rate(3,1);%��λ������/��

%%DCM������ϵN-->B   ŷ������ת����Ϊn->b   ZYX
Rz = [cos(head),-sin(head),0;
		  sin(head),cos(head),0;
		   0,0,1];
Ry = [cos(pitch),0,sin(pitch);
	       0,1,0;
		  -sin(pitch),0,cos(pitch)];
Rx = [1,0,0;
	      0,cos(roll),-sin(roll);
		  0,sin(roll),cos(roll)];	  
Cbn = Rz*Ry*Rx;   %%%%n->b
% Cbn
% Rbn = rpy2r(atti','zyx')

% Cbn = Cnb';
% Cbn = [cos(roll)*cos(head)+sin(roll)*sin(pitch)*sin(head), -cos(roll)*sin(head)+sin(roll)*sin(pitch)*cos(head), -sin(roll)*cos(pitch);
%        cos(pitch)*sin(head),                               cos(pitch)*cos(head),                                sin(pitch);
%        sin(roll)*cos(head)-cos(roll)*sin(pitch)*sin(head), -sin(roll)*sin(head)-cos(roll)*sin(pitch)*cos(head), cos(roll)*cos(pitch)];
%   
%ŷ���Ǳ任����
% Eluer_M=[cos(roll), 0, sin(roll)*cos(pitch);
%          0,         1, -sin(pitch);
%          sin(roll), 0, -cos(pitch)*cos(roll)];
I = eye(3,3);
Lbn = [I *[1;0;0], Rx*[0;1;0] , Ry*Rx*[0;0;1]];
Eluer_M  = Lbn;
% Eluer_M=[1, 0,                   sin(pitch) ;
%                    0, cos(roll), -sin(roll)*cos(pitch);
%                    0, -sin(roll), cos(roll)*cos(pitch)];   



%%%%%%%%%%%%%%%%%%%%%%%%%%%%���������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wnbb = Eluer_M*[dpitch,droll,dhead]';
Wnbb = Eluer_M*[droll,dpitch,dhead]';

veloN = Cbn'*old_veloB;
Ve = veloN(1,1);
Vn = veloN(2,1);
Vu = veloN(3,1);

Wenn = [-Vn/(Rm+height), Ve/(Rn+height), Ve/(Rn+height)*tan(lat)]';
Wien = [0,               Wie*cos(lat),   Wie*sin(lat)]';

Wibb = Cbn*(Wien+Wenn)+Wnbb;    %��λ������/��
Wibb = Wibb/pi*180;             %��λ����/��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%���ٶȼ����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acceN = Cbn'*(acceB+cross(Wnbb,old_veloB));%%%%%���ļ��ٶȵ��ڽ��ٶ�w�����ٶ�v�Ĳ��
Fn = acceN+cross(2*Wien+Wenn,veloN)-[0,0,-1*g]';
Fb = Cbn*Fn;                    %��λ����/��/��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%λ�ü���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
veloN = Cbn'*veloB;
Ve = veloN(1,1);
Vn = veloN(2,1);
Vu = veloN(3,1);

x = x+T*Ve;
y = y+T*Vn;
height = height+T*Vu;

posi(1,1) = x;
posi(2,1) = y;
posi(3,1) = height;


% lat = lat+T*(Vn/(Rm+height));
% lon = lon+T*(Ve/(Rn+height)*cos(lat));

% posi(1,1) = lon*180/pi;
% posi(2,1) = lat*180/pi;
% posi(3,1) = height;

end


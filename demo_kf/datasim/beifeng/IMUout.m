function [ Wibb,Fb,posi ] = IMUout( T,posi,atti,atti_rate,veloB,acceB,old_veloB,old_atti )

%%%%%%%%%%%%%%%%%%%%%������йصĲ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Re = 6378137.0;               %����뾶����λ���ף�
f = 1/298.257;                %������Բ��
Wie = 7.292115147e-5;         %������ת�����ʣ���λ������/�룩
g = 9.7803698;                %�������ٶȣ���λ����/��/�룩

%%������λ��
lon = posi(1,1)*pi/180;
lat = posi(2,1)*pi/180;
height = posi(3,1);           

%%�������ʰ뾶
Rm = Re*(1-2*f+3*f*sin(lat)*sin(lat));
Rn = Re*(1+f*sin(lat)*sin(lat));   
                              
%%��̬�Ǻ���̬������
roll = old_atti(1,1)*pi/180;
pitch = old_atti(2,1)*pi/180;
head = old_atti(3,1)*pi/180;
droll = atti_rate(1,1)*pi/180;
dpitch = atti_rate(2,1)*pi/180;
dhead = atti_rate(3,1)*pi/180;

%%DCM������ϵN-->B
Cbn = [cos(roll)*cos(head)+sin(roll)*sin(pitch)*sin(head), -cos(roll)*sin(head)+sin(roll)*sin(pitch)*cos(head), -sin(roll)*cos(pitch);
       cos(pitch)*sin(head),                               cos(pitch)*cos(head),                                sin(pitch);
       sin(roll)*cos(head)-cos(roll)*sin(pitch)*sin(head), -sin(roll)*sin(head)-cos(roll)*sin(pitch)*cos(head), cos(roll)*cos(pitch)];
   
%%ŷ���Ǳ任����
Eluer_M=[cos(roll), 0, sin(roll)*cos(pitch);
         0,         1, -sin(pitch);
         sin(roll), 0, -cos(pitch)*cos(roll)];
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%���������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Wnbb = Eluer_M*[dpitch,droll,dhead]';

veloN = Cbn'*old_veloB;
Ve = veloN(1,1);
Vn = veloN(2,1);
Vu = veloN(3,1);

Wenn = [-Vn/(Rm+height), Ve/(Rn+height), Ve/(Rn+height)*tan(lat)]';
Wien = [0,               Wie*cos(lat),   Wie*sin(lat)]';

Wibb = Cbn*(Wien+Wenn)+Wnbb;    %��λ������/��
Wibb = Wibb/pi*180;             %��λ����/��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%���ٶȼ����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roll = atti(1,1)*pi/180;
pitch = atti(2,1)*pi/180;
head = atti(3,1)*pi/180;

acceN = Cbn'*(acceB+cross(Wnbb,old_veloB));
Fn = acceN+cross(2*Wien+Wenn,veloN)-[0,0,-1*g]';
Fb = Cbn*Fn;                    %��λ����/��/��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%λ�ü���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
veloN = Cbn'*veloB;
Ve = veloN(1,1);
Vn = veloN(2,1);
Vu = veloN(3,1);

height = height+T*Vu;
lat = lat+T*(Vn/(Rm+height));
lon = lon+T*(Ve/(Rn+height)*cos(lat));

posi(1,1) = lon*180/pi;
posi(2,1) = lat*180/pi;
posi(3,1) = height;

end


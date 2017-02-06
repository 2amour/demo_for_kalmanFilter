function [ t,atti,atti_rate,veloB,acceB,acce ] = trace_quadrotor( t,T,atti,atti_rate,veloB,acceB,acce )

format long;

if t == 0
    acce = [0,0,0]';                              %��ʼ��׼ʱ��
elseif t<=10
    acce = [0,0,0.6]';                            %��ֱ����,ֱ����������ٶ�
elseif t<=510
    acce = [0,0,0]';                              %��ǰ�߶�30���������ٶȴ�ֱ����,����3000m
elseif t<=520
    acce = [0,0,-0.6]';                           %�����������ͣ
elseif t<=525
    acce = [0,0,0]';                              %��ͣ״̬��ά��5s,�߶�3060m
elseif t<=525+2.5
    atti_rate = [0,-6,0]';                         
    acce = [0,2,0]';                              %��ͷǰ��
elseif t<=535
    atti_rate = [0,0,0]';
elseif t<=545
    acce = [0,0,0]';                              %����ǰ��
elseif t<=645                      
    atti_rate = [0,0,3.6]';                        %Բ���˶�
%  elseif t<=755
     
end

roll = atti(1,1)*pi/180;
pitch = atti(2,1)*pi/180;
head = atti(3,1)*pi/180;

atti=atti+atti_rate*T;

Cbn = [cos(roll)*cos(head)+sin(roll)*sin(pitch)*sin(head), -cos(roll)*sin(head)+sin(roll)*sin(pitch)*cos(head), -sin(roll)*cos(pitch);
   cos(pitch)*sin(head),                               cos(pitch)*cos(head),                                sin(pitch);
   sin(roll)*cos(head)-cos(roll)*sin(pitch)*sin(head), -sin(roll)*sin(head)-cos(roll)*sin(pitch)*cos(head), cos(roll)*cos(pitch)];

acceB = Cbn*acce;

veloB = veloB+acceB*T;

end

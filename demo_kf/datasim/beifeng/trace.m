function [ t,atti,atti_rate,veloB,acceB ] = trace( t,T,atti,atti_rate,veloB,acceB )
%                   ����������
% 
%   ���������
%   t           ����ʱ��
%   T           ���沽��
%   atti        ��������������򣨵�λ���ȣ�
%   atti_rate   ������ʡ��������ʡ��������ʣ���λ����/�룩
%   veloB       �ɻ��˶��ٶ�--X����Y��ͷ��Z���򣨵�λ����/�룩
%   acceB       �ɻ��˶����ٶ�--X����Y��ͷ��Z���򣨵�λ����/��/�룩
%   posi         ������������ʼλ�þ��ȡ�γ�ȡ��߶ȣ���λ���ȡ��ȡ��ף�

    if t==0
        acceB(2,1) = 0;                                     %��ʼ��׼ʱ��
    elseif t<=20
        acceB(2,1) = 8.0;                                   %����
    elseif t<=24
        atti_rate(2,1)= 7.5;
        acceB(2,1) = 10;                                    %��������
    elseif t<=64
        atti_rate(2,1)= 0;                                  %����
    elseif t<=68
        atti_rate(2,1)= -7.5;                               %�ѻ�ͷ��ƽ
        acceB(2,1) = 0;
    elseif t<=668
        atti_rate(2,1)= 0;                                  %ƽֱ����
    elseif t<=671
        atti_rate(1,1)= 10;                                 %��бת��
    elseif t<=731
        atti_rate(1,1)= 0;
        atti_rate(3,1)= 1.5;                                %ת��
    elseif t<=734
        atti_rate(3,1)=0;
        atti_rate(1,1)= -10;                                %��ƽ
    elseif t<=1334
        atti_rate(1,1)= 0;                                  %ƽ��ֱ��
    elseif t<=1342
        atti_rate(2,1)=7.5;
        acceB(2,1) = 2;                                     %��������
    elseif t<=1374
        atti_rate(2,1)=0;
    elseif t<=1382
        acceB(2,1) = 0; 
        atti_rate(2,1)=-7.5;                                %��ƽ
    elseif t<=1862
        atti_rate(2,1)= 0;                                  %ƽֱ����
    elseif t<=1902
        acceB(2,1) = -2.5;                                  %���ٷ���
    elseif t<=1905
        atti_rate(1,1)=10;
        acceB(2,1) = 0;                                     %��бԤת��
    elseif t<=1965
        atti_rate(1,1)=0;
        atti_rate(3,1)=1.5;                                 %ת��
    elseif t<=1968
        atti_rate(1,1)=-10;
        atti_rate(3,1)=0;                                   %��ƽ
    elseif t<=2568
        atti_rate(1,1)=0;                                   %ƽֱ����
    elseif t<=2574
        atti_rate(2,1)=-7.5;                                %��ͷ
    elseif t<=2594
        atti_rate(2,1)= 0;                                  %���� 
    elseif t<=2600
        atti_rate(2,1)= 7.5;                                %��ƽ
    elseif t<=2603
        atti_rate(2,1)= 0;
        atti_rate(1,1)= 10;                                 %��бת��
    elseif t<=2663
        atti_rate(3,1)= 1.5;
        atti_rate(1,1)= 0;                                  %ת��
    elseif t<=2666
        atti_rate(3,1)= 0;
        atti_rate(1,1)= -10;                                %��ƽ
    elseif t<=3600
        atti_rate(1,1)=0;                                   %ƽֱ����
    end
    
    veloB(2,1)=veloB(2,1)+acceB(2,1)*T;
    atti(1,1)=atti(1,1)+atti_rate(1,1)*T;
    atti(2,1)=atti(2,1)+atti_rate(2,1)*T;
    atti(3,1)=atti(3,1)+atti_rate(3,1)*T;
    
    
end
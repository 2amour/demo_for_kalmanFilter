function [ t,atti,atti_rate,veloB,acceB ] = trajectory( t,T,atti,atti_rate,veloB,acceB )
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

	global traceLine;
    
    veloB(1,1)=veloB(1,1)+acceB(1,1)*T;
	veloB(2,1)=veloB(2,1)+acceB(2,1)*T;
	veloB(3,1)=veloB(3,1)+acceB(3,1)*T;
    atti(1,1)=atti(1,1)+atti_rate(1,1)*T;
    atti(2,1)=atti(2,1)+atti_rate(2,1)*T;
    atti(3,1)=atti(3,1)+atti_rate(3,1)*T;
    
    
end
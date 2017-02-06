function [xlog,ylog] = Alian(NoiseSeq,SamplePeriod,L)
%%%%%%%%%%��������----------------------------------
progressBar = 0;
% SamplePeriod = 1/50.0;  %%%%��������

figure
sensorNobias = NoiseSeq;
N = size(sensorNobias,1);
seq = 1:L:floor(N/10);
timeTau = zeros(length(seq),1);
alianVariance = zeros(length(seq),1);
% 	clear a_vector;
	for kn=seq
			m = floor(N/kn);  %%%%��ȡ�������m
% 			Tau = kn*SamplePeriod;
			timeTau(kn) = kn*SamplePeriod;
			%%%%�����ݽ��з��飬��Ϊm�飬ÿ��kn������
			FenzuMatrix = reshape(sensorNobias(1:kn*m),kn,m);  
			A_t = mean(FenzuMatrix);   %%%%ÿ������ľ�ֵ�γɵ�����
% 			quadraticSum = alianVarianceValue(A_t);

			alianVariance(kn) = alianVarianceValue(A_t);     
			progressBar = progressBar + 1;
			if progressBar == 1000
				  disp(['      �����Ѿ����е�:',num2str(100*kn/floor(N/10)),'  %']);
				  progressBar = 0;
			end
	end
	
	progressBar = 0;
	xlog = log(timeTau);
	ylog=log(alianVariance);
	plot(xlog,ylog,'.');
	grid on;

	% ���� xlabel
	xlabel('ʱ��\tau: s');

	% ���� ylabel
	ylabel('alianVariance','FontWeight','bold');

	% ���� title
	title(['����Ԫ��','Random walk','�����������'],'FontWeight','bold','FontSize',12);
	
end

function quadraticSum = alianVarianceValue(A_t)
	A_t = diff(A_t); 
	A_t = A_t.^2;
	quadraticSum = sum(A_t/2/(size(A_t,2)-1));

end
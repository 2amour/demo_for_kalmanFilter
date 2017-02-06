function traceGenerate()


disp('    ��ȡˮƽ���ڵ�����λ��')
h1 = figure;
title('ƽ��궨')
xlim([0,200]);ylim([0,100]);grid on;box on;
Pcs = 25+18+2+20;px=[];py=[];pz=[];
for ki=1:Pcs
   [x,y,z]=ginput(1);
   px = [px;x];py = [py;y];
   plot(px,py,'r-o');hold on;
   title(['ƽ��궨ʣ�����:',num2str(Pcs-ki),'��'])
   xlim([0,200]);ylim([0,100]);grid on;box on;
end
close(h1);

disp('    ��ȡ��ֱ�ڵ�����λ��')
h2= figure;title('�߶ȱ궨')
h3 = figure;title('�켣ͼ')
figure(h2)
xlim([0,100]);ylim([0,10]);grid on;box on;
for ki=1:Pcs
   figure(h2);
   [x,z]=ginput(1);
   pz = [pz;z];
   figure(h3);
   num = length(pz);
   hAx = plot3(px(1:num),py(1:num),pz,'r-o');hold on;
   title(['�߶ȱ궨ʣ�����:',num2str(Pcs-ki),'��'])
   xlim([0,200]);ylim([0,100]);zlim([0,10]);grid on;
   xlabel('x����');ylabel('y����');zlabel('z����');
end

%% Frist path generation
via = [px,py,pz];
save TraceSim.mat via Pcs

end
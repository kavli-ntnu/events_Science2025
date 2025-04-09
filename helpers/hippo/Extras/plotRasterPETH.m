
% Function plots Raster and PETH
% Input: 
%   rst, the output form RSTPTHSMPL
%   filename: how do you want to name the graph
%   bin: binwidth of peth
%   pre/pos: from/back edge of time window interested in
%   nodename: second part of graph name (event)

% !!!!! Note: the unit of general input is ms in the field of neuroscience. the unit on peth is count/s. If this code is used for other purpose, you need to revise the unit! 

function [h1,h2]=plotRasterPETH(rst,filename,bin,pre,pos,nodename)
nmove=length(unique(rst(:,2)));

h1=subplot(2,1,1);
plot(rst(:,1),rst(:,2),'.k') % %'SizeData',2,'MarkerEdgeColor','k','MarkerFaceColor','k');
hold on
plot([0 0], [0 nmove]);
ylim([0 nmove]);
xlim([-pre pos]);
title([filename nodename]);




h2=subplot(2,1,2);
a=hist(rst(:,1),-pre:bin:pos,'k')/nmove/bin*1000; % here the unit is converted to count/second!
bar(-pre:bin:pos,a);
hold on
plot([0 0], [0 max(a)+.5]);
xlim([-pre pos]);
ylim([0 max(a)+.5]);



% print('-dtiff','-r400',[filename '_' num2str(n) '_up']);



%dlmwrite([filename '_' num2str(n) '_upsne.txt'],upmov,'delimiter','\t','precision',8);
%dlmwrite([filename '_' num2str(n)
%'_rstup.txt'],spkt_up,'delimiter','\t','precision',8)
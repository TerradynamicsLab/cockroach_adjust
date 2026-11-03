clear; close all; clc; 

% kinetic energy fluctuation: a line 0.01 mJ
% x: -13.6

% maximum energy for
% leg pronation 0.06
% head flexion 0.0027, yaw: 0.012, 0.008

y = [0.0027, 0.012, 0.008, 0.06];
set(gcf, 'Position',[261 365 320 500])
bar(y,'k')
line([0,5],[1,1]*0.01,'Color',[0.1490,0.6588,0.0196],'LineWidth',3);
ylim([0,0.065]);
xlim([0.5,4.5]);
set(gca,'FontSize',20)
xticks([1,2,3,4]);
xticklabels({'a','b','c','d'})
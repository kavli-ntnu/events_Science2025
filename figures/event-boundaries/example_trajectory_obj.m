
function example_trajectory_obj()

load('N:\benjamka\events\figures\event-boundaries\example_trajectory_obj.mat')

figure
hold on
plot(score(:,1),score(:,2),'k-')
scatter(score(:,1),score(:,2),75,epochs,'filled','markerfacealpha', 1)

numEpochs = length(unique(epochs));
colormap(clr.rocket(numEpochs))
c = colorbar;

c.Ticks = [1+0.5*(numEpochs-1)/numEpochs:(numEpochs-1)/numEpochs:numEpochs];
c.TickLabels = int2str([1:numEpochs]');
c.Label.String = 'Epoch';
c.TickLength = 0;
xlabel LD1
ylabel LD2
fixPlot
box on
   
mx = max(abs(axis()),[],'all');
axis([-mx mx -mx mx -mx mx])
axis square

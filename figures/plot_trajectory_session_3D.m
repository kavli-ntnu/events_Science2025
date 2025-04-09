function [xx, yy, zz] = plot_trajectory_session_3D(score, epochs, axLims)

nDim = size(score, 2);
numEpochs = length(unique(epochs));
if min(epochs) == 0
    epochs = epochs + 1;
end
DIMS = [1, 2, 3];

old = unique(epochs);
new = 1:numEpochs;
for i = 1:numEpochs
    epochs(epochs == old(i)) = new(i);
end

figure
hold on

colormap(clr.rocket(numEpochs))
c = colorbar;

c.Ticks = [1+0.5*(numEpochs-1)/numEpochs:(numEpochs-1)/numEpochs:numEpochs];
c.TickLabels = int2str([1:numEpochs]');
c.Label.String = 'Epoch';
c.TickLength = 0;
xlabel(sprintf('D%d',DIMS(1)))
ylabel(sprintf('D%d',DIMS(2)))
zlabel(sprintf('D%d',DIMS(3)))
fixPlot
box on

% epoch averages
epoch_ave = [];
for i = 1:size(score, 2)
    tmp = [];
    for j = unique(epochs)
        tmp = [tmp, nanmean(score(epochs == j, i))];
    end
    epoch_ave(:, i) = tmp;
end
xx = epoch_ave(:, DIMS(1));
yy = epoch_ave(:, DIMS(2));
zz = epoch_ave(:, DIMS(3));

scatter3(xx, yy, zz, 300, clr.rocket(length(xx)),'filled','markeredgecolor','k','linew',1.5)
plot3(xx, yy, zz, 'k-','linew',1)

mx = axLims;
axis([-mx mx -mx mx -mx mx])
axis square
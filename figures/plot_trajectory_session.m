function plot_trajectory_session(score, epochs, axLims)

N_t = size(score, 1);
numEpochs = length(unique(epochs));
if min(epochs) == 0
    epochs = epochs + 1;
end

old = unique(epochs);
new = 1:numEpochs;
for i = 1:numEpochs
    epochs(epochs == old(i)) = new(i);
end

figure
hold on
inds = 1:size(score, 1);

scatter(score(:,1),score(:,2),75,epochs,'filled')
mx = axLims;
axis([-mx mx -mx mx -mx mx])
axis square
colormap(clr.rocket(numEpochs))
c = colorbar;

c.Ticks = [1+0.5*(numEpochs-1)/numEpochs:(numEpochs-1)/numEpochs:numEpochs];
c.TickLabels = int2str([1:numEpochs]');
c.Label.String = 'Epoch';
c.TickLength = 0;
xlabel 'LD1'
ylabel 'LD2'
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
x1 = epoch_ave(:, 1);
x2 = epoch_ave(:, 2);
scatter(x1, x2, 300, clr.rocket(length(x1)),'filled','markeredgecolor','k','linew',1.5)
plot(x1, x2, 'k-','linew',1)

c.Label.String = 'Session time (min)';
set(gca,'fontsize', 24)
load figp
set(gcf,'pos',figp), movegui
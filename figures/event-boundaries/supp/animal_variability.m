
speed_of = trajectory_speed_of(regions(1), colors([1, 4], :));
animal_inds = [1, 2; 3, 7; 8, 9; 10, 14; 15, 18; 19, 22; 23, 26];
animal_IDs = {'26863', '26965', '26966', '27284', '27285', '27963', '28003'};
hold on
for iRat = 1:size(animal_inds, 1)
    plot(mean(speed_of(animal_inds(iRat, 1):animal_inds(iRat, 2), :)), 'k-', 'linew', 0.5)
end

%%
speed_f8 = trajectory_speed_f8();
animal_inds = [1, 3; 4, 5];
animal_IDs = {'26965', '26966'};
hold on
for iRat = 1:size(animal_inds, 1)
    plot(mean(speed_f8(animal_inds(iRat, 1):animal_inds(iRat, 2), :)), 'k-', 'linew', 0.5)
end

%%
speed_seq = trajectory_speed_seq();
animal_inds = [1, 4; 5, 5];
animal_IDs = {'27285', '29630'};
hold on
for iRat = 1:size(animal_inds, 1)
    if ~all(diff(animal_inds(iRat, :)))
        plot(speed_seq(animal_inds(iRat, 1):animal_inds(iRat, 2), :), 'k-', 'linew', 0.5)
    else
        plot(mean(speed_seq(animal_inds(iRat, 1):animal_inds(iRat, 2), :)), 'k-', 'linew', 0.5)
    end
end

%%
speed_first = trajectory_speed_obj_contact();
hold on
animal_inds = [1, 3; 4, 6; 7, 18; 19, 23];
animal_IDs = {'27963', '28003', '29630', '29629'};
for iRat = 1:size(animal_inds, 1)
    plot(mean(speed_first(animal_inds(iRat, 1):animal_inds(iRat, 2), :)), 'k-', 'linew', 0.5)
end

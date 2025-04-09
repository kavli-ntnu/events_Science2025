
speed_of = trajectory_speed_of(regions(1), colors([1, 4], :));
hold on
for iSession = 1:size(speed_of, 1)
    plot(speed_of(iSession, :), 'k-', 'linew', 0.5)
end

%%
speed_f8 = trajectory_speed_f8();
hold on
for iSession = 1:size(speed_f8, 1)
    plot(speed_f8(iSession, :), 'k-', 'linew', 0.5)
end

%%
speed_seq = trajectory_speed_seq();
hold on
for iSession = 1:size(speed_seq, 1)
    plot(speed_seq(iSession, :), 'k-', 'linew', 0.5)
end
ylim auto

%%
speed_first = trajectory_speed_obj_contact();
hold on
session_inds = [1, 3; 4, 6; 7, 9; 10, 12; 13, 15; 16, 18; 19, 20; 21, 23];
for iSession = 1:size(session_inds, 1)
    plot(mean(speed_first(session_inds(iSession, 1):session_inds(iSession, 2), :)), 'k-', 'linew', 0.5)
end

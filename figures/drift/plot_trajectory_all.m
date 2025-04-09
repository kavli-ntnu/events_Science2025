
function plot_trajectory_all(regions)

nr = 5;
nc = 6;
for iRegion = 1:length(regions)
    subs = npx_banal.subs(nr, nc);
    iPool = 1;
    for ir = 1:nr
        for ic = 1:nc
            fname = sprintf('N:\\benjamka\\events\\data\\foraging\\score_%s_%d.mat', regions{iRegion}, iPool);
            if exist(fname, 'file')
                tmp = load(fname);
                score = tmp.score;
                fname2 = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
                tmp = load(fname2);
                epochs = tmp.epochs;
                mxInd = min(size(score, 1), length(epochs));
                plot_trajectory_session_subs(score(1:mxInd, 1:2), epochs(1:mxInd), 12, subs{ir, ic})
                iPool = iPool + 1;
            else
                break
            end
        end
    end
end
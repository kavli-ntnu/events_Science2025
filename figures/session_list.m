
% This script was used to generate some of the pre-processed mat files in
% the data folder. It is provided here in case it helps explain where
% certain values come from or helps someone get started on a new analysis. But
% please note that some sections would need to be (un)commented or otherwise 
% modified for it to work as intended. Excecute it with appropriate
% caution.

%%
[~, ~, xl] = xlsread('N:\benjamka\events\session_list.xlsx');
labels = xl(1, :);
xl = xl(2:end, :);

TASK = {'OF'};
% TASK = {'OF novel'};
% TASK = {'F8'};
% TASK = {'SEQ'};
% TASK = {'OBJ'};

LEC = extract.rows(xl, labels, 'keep', 'Region', {'LEC'}, 'Task', TASK);
MEC = extract.rows(xl, labels, 'keep', 'Region', {'MEC'}, 'Task', TASK);
CA1 = extract.rows(xl, labels, 'keep', 'Region', {'CA1'}, 'Task', TASK);

%%
DATA = LEC;

for iSession = 1:size(DATA, 1)
    folder = char(extract.cols(DATA(iSession, :), labels, {'Folder'}));
    probeNum = double(extract.cols(DATA(iSession, :), labels, {'Probe'}));
    shanks = char(extract.cols(DATA(iSession, :), labels, {'Shanks'}));
    if length(shanks) == 5
        shanks = 1:4;
    else
        shanks = str2double(shanks(2));
    end
    try
        seshInd = double(extract.cols(DATA(iSession, :), labels, {'Session'}));
    catch
        tmp = extract.cols(DATA(iSession, :), labels, {'Session'});
        eval(sprintf('seshInd = %s;', tmp{1}))
    end
    speed_filter = false;
    speed_kernel = 0.25; % seconds
    posT_c = cell(1);
    frCutoffs = [0.05 40];
    dpthCutoffs = [-inf inf];
    dpth_min = double(extract.cols(DATA(iSession, :), labels, {'Depth min'}));
    dpth_max = double(extract.cols(DATA(iSession, :), labels, {'Depth max'}));
    if ~isnan(dpth_min)
        dpthCutoffs(1) = dpth_min;
    end
    if ~isnan(dpth_max)
        dpthCutoffs(2) = dpth_max;
    end

    FLAG = true;
    while FLAG
        d = npx_load(folder, "ksVer", "2.5");
        if all(isinf(d.probes(probeNum).units(1).spikeAmplitudes))
            fprintf('Correcting clusters file: %s\n', d.probes(probeNum).ksdir.name)
            runPostKsTasks(d.probes(probeNum).ksdir.name, 1);
        else
            FLAG = false;
        end
    end
    if strcmpi(TASK, 'OF')
        split = [d.sessions(min(seshInd)).startTime, d.sessions(min(seshInd)).startTime + (10 * 60) + 1]; % 10 min
    else
        split = [d.sessions(min(seshInd)).startTime, d.sessions(max(seshInd)).endTime]; % for SEQ/OBJ this will include intertrials
    end
%     split = [d.sessions(1).startTime, d.sessions(4).endTime];
    [posT, posX, posY, HD] = npx_banal.getPos(d,seshInd,split);
    [posX, posY, spd_sm] = npx_banal.speedFilter(posT,posX,posY,speed_kernel,speed_filter);
%     save(sprintf('spd_sm_LEC_%d', iSession), 'spd_sm')
    
    % animal acceleration control
    % dt = 10; % sec
    % timeInt = posT(1):dt:posT(end);
    % smat_spd = spd_sm(round(linspace(1, length(spd_sm), length(timeInt) - 1)));
    % save(sprintf('N:\\benjamka\\events\\data\\foraging\\smat_spd_CA1_%d', iSession), 'smat_spd')
    % 
    % continue

    [sCell,N,dpthSrt,unitIDs,shankNums,chanX,chanY] = npx_banal.units(d,probeNum,shanks,posT,frCutoffs,dpthCutoffs,'all',[],posT_c);

    % waveform stability
    % time = prctile(posT, [25, 75]);
    % N = length(d.probes(probeNum).units);
    % first = nan(1, N);
    % last = nan(1, N);
    % for i = 1:N
    %     spkT = d.probes(probeNum).units(i).spikeTimes;
    %     spkAmp = d.probes(probeNum).units(i).spikeAmplitudes;
    %     first(i) = mean(spkAmp(spkT < time(1)));
    %     last(i) = mean(spkAmp(spkT > time(2)));
    % end
    % toRemove = isnan(first) | isnan(last);
    % first = first(~toRemove);
    % last = last(~toRemove);
    % fprintf('Waveform stability = %0.2f\n', corr(first', last'))

    % save(sprintf('N:\\benjamka\\events\\data\\foraging\\spike_amplitudes_CA1_%d', iSession), 'first', 'last')

    % [maps, maps_struct] = npx_banal.maps(sCell,posT,posX,posY);
    % si = npx_banal.spatInfo(maps_struct);
    % [siSrt, sortInd] = sort(si, 'descend', 'missing', 'last');
    % subplot(5, 6, iSession)
    % si_all{1}{iSession} = si;
    % histogram(si, 200)
    % drawnow

    % dt = 10; % sec
    dt = 1; % sec
    % dt = 0.5; % sec
    % dt = 0.1; % sec
    [smat,smat_n,smat_z,fr] = npx_banal.binSpikes(sCell,posT,dt);

    % [fano] = fano_sort(smat_n);
    % fano_all{1}{iSession} = fano;

    % [~, ~, ~, ~, explained] = pca(smat_n');
%     nPCs = find(cumsum(explained) > 50, 1);
%     save(sprintf('nPCs_LEC_%d', iSession), 'nPCs')

    epochLength = 6 * 10;
    numEpochs = ceil(size(smat_n, 2) / epochLength);
    epochs = [];
    for i = 1:numEpochs
        epochs = [epochs, zeros(1, epochLength) + i];
    end
    epochs = epochs(1:size(smat_n, 2));

    % save(sprintf('N:\\benjamka\\events\\data\\foraging_100ms\\smat_n_LEC_%d', iSession), 'smat_n', 'epochs', 'spd_sm')
    % save(sprintf('N:\\benjamka\\events\\data\\event-manipulation\\smat_full_1s\\smat_n_%d', iSession), 'smat_n', 'epochs', 'spd_sm')

%     % GLM
%     predPopRate = nanmean(smat_n);
%     predTimeLinear = linspace(0, 1, size(smat_n,2));
%     X = [predPopRate; predTimeLinear]';
%     clear b stats p
%     for iNeuron = 1:size(smat_n,1)
%         [b(iNeuron,:),~,stats{iNeuron}] = glmfit(X,smat_n(iNeuron,:),'poisson');
%         p(iNeuron,:) = stats{iNeuron}.p;
%         exp_var(iNeuron) = 1 - var(stats{iNeuron}.resid) ./ var(smat_n(iNeuron,:)); 
%     end
%     [~,sind] = sort(p(:,3),'ascend','missing','last');

%     save(sprintf('N:\\benjamka\\events\\figures\\Fig2\\data\\glm_CA1_%d', iSession), 'b', 'p', 'smat_n', 'sind', 'X')

    % fprintf('%d saved\n', iSession)
end
    
    

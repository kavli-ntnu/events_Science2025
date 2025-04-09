
% Display all subjective quality judgments for a recording session in a
% figure window.
%
%   USAGE
%       minions.getQuality
%
% Written by BRK 2016

function getQuality

%% choose directory and find saved mat files
folder = uigetdir();
matFiles = dir(fullfile(folder,'*.mat'));
matFiles = struct2cell(matFiles)';
ind = find(~cellfun(@isempty,strfind(matFiles(:,1),'Quality')));

%% plot quality judgments as text
figure('name',folder);
set(gca,'ydir','reverse')
axis off
for iFile = 1:length(ind)
    quality = 0;
    name = matFiles{ind(iFile),1};
    load(fullfile(folder,name))
    hCluster = text(1,iFile,name(1:strfind(name,'-')-1),'interpreter','none');
    if strcmpi(name(strfind(name,'TT')+2),'1')
        set(hCluster,'color','m');
    elseif strcmpi(name(strfind(name,'TT')+2),'2')
        set(hCluster,'color','b');
    elseif strcmpi(name(strfind(name,'TT')+2),'3')
        set(hCluster,'color','r');
    end
    hQual = text(10,iFile,num2str(quality));
    if quality == 3
        set(hQual,'color','r');
    elseif quality == 4
        set(hQual,'color',[0.7 0.7 0.7]);
    end
    
end
axis([0 15 0 iFile+1])
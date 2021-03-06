function fig1=topoplot248(vec,cfg,sortedChans)
%% reading weights
% topoplot of 248 values
if ~exist('sortedChans','var')
    sortedChans=false;
end
cfg.layout='4D248.lay';
% if ~exist ('cfg','var')
%     cfg=[];
% end
load ~/ft_BIU/matlab/plotwts
if sortedChans
    for chani=1:248
        wts.label{chani,1}=['A',num2str(chani)];
    end
end

wts.avg(:,1)=vec;

if isfield(cfg,'maskparameter')
    eval(['wts.',cfg.maskparameter,'=(~isnan(wts.avg));']);
end
fig1=ft_topoplotER(cfg,wts);

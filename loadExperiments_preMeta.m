function [meta,rasters,lfps,Trials] = loadExperiments_preMeta(preMeta, no_return, no_lfp, no_conv)
% same as loadExperiments but use the structure array `preMeta` as inut. 
% Closer to original loadExp version.
if nargin == 1
no_return = false;
no_lfp = true;
no_conv = false;
elseif nargin == 2
no_lfp = true;
no_conv = false;
elseif nargin == 3
no_conv = false;
end

iExp = 0;
for iExp = 1:numel(preMeta)
    if no_conv, preMeta(iExp).sdf = 'raster'; else, preMeta(iExp).sdf = 'sdf'; end
end

Project_General_copyMissingFiles(preMeta); % communicating and copying data from network to local 
meta = {}; rasters = {}; lfps = {}; Trials = {};
for iExp = 1:length(preMeta) 
    tMeta = preMeta(iExp);
    % if tMeta.  is about video, then modify the time window. 

    addargs = {};
    if no_conv, addargs = [addargs, 'sdf', 'raster']; end % instead of defualt 'sdf'
    if contains(tMeta.expControlFN, "generate_Movie"), addargs = [addargs, 'rasterWindow', [-250 500]]; 
    elseif contains(tMeta.expControlFN, "movie"), addargs = [addargs, 'rasterWindow', [-250 2500]];  
    elseif contains(tMeta.expControlFN, "Masking"), addargs = [addargs, 'rasterWindow', [-250 600]]; end 
    % Extract longer time window activity when using movie? TODO, this 
    try
    % time window value should change for each different movie experiments.
    [meta_,rasters_,lfps_,Trials_] = loadData(tMeta.ephysFN,'expControlFN',tMeta.expControlFN, addargs{:}) ;
    catch err % err is an MException struct, save the err in a log file and continue. 
        fprintf('Error message:\n%s\n',err.message);
        fprintf('Error trace:\n%s\n',err.getReport);
        disp(tMeta)
%         keyboard
        fileID = fopen('S:\Exp_error_log_new.log','w+');
        fprintf(fileID,'Error message:\n%s\n',err.message);
        fprintf(fileID,'Error trace:\n%s\n',err.getReport);
        fclose(fileID);
        continue
    end
    meta_merged = rmfield( tMeta, intersect(fieldnames(tMeta), fieldnames(meta_)) );
    names = [fieldnames(meta_merged); fieldnames(meta_)];
    meta_ = cell2struct([struct2cell(meta_merged); struct2cell(meta_)], names, 1);
    if ~no_return % if true then don't return these things, only save to disk. 
        % helpful when we don't want to take up all the memory! 
        meta{iExp} = meta_;
        rasters{iExp} = rasters_;
        if ~no_lfp
            lfps{iExp} = lfps_;
        end
        Trials{iExp} = Trials_;
    end
    clear meta_  rasters_ lpfs_ Trials_ names meta_merged tMeta
end
end
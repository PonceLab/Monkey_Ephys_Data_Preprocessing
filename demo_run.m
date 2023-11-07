%% Organize OneNote into structured table
!ExpRecordBackup.bat

%% Get Big Mat
batchProcessPL2

%% Sort into trials
Animal = "Beto";%Set_Path;
ExpRecord = readtable("sample_ExpRecords\\Exp_Record_Beto.csv")
currows = find(contains(ExpRecord.expControlFN,["220118", "220119", "220225", "220228", "220302","220307", "220309",...
"220311", "220404", "220406"])); 
[meta_new, rasters_new, lfps_new, Trials_new] = loadExperiments(currows(1:end), Animal, false);
bhvfns = ExpRecord.expControlFN(currows);

%% Customized Analysis code for different subtype of experiments
%% Process RFMapping Experiments 
rfidx = contains(bhvfns,"rfMapper");
RFS_col = RF_Calc_Stats_fun(meta_new(rfidx), rasters_new(rfidx), Trials_new(rfidx));
%  Process RF data and get the masks saved to disk. 
for iRF = 1:numel(RFS_col)
    RFStat = RFS_col(iRF);
    maskS = RFStats_indiv_chan_gen_mask(RFStat);
    expdir = fullfile(saveroot, compose("%s-%s-RF",datestr(RFStat.meta.datetime,"yyyy-mm-dd"),RFStat.Animal));
    mkdir(expdir)
    save(fullfile(expdir,'RFStat.mat'),'RFStat')
    save(fullfile(expdir,'maskStat.mat'),'maskS')
end

%% Process the Selectivity Representation Ecoding Experiments 
selidx = contains(bhvfns,"selectivity_basic") & ~cellfun(@isempty,meta_new');
SelS_col = selectivity_Collect_Stats_fun(meta_new(selidx), rasters_new(selidx), Trials_new(selidx));
%% Visualize response distribution of all channels 
visusalize_resp_distri_allchan(SelS_col);

%% Extract and Visualize Cosine Experiments. 
evoidx = contains(bhvfns,"generate_BigGAN_cosine") & ~cellfun(@isempty,meta_new');
CStats = Evol_Cosine_Collect_Stats_fun(meta_new(evoidx), rasters_new(evoidx), Trials_new(evoidx));
%%
visualize_TargetImg(CStats(:))
visualize_Cosine_PopEvol(CStats(:),9);
visualize_Cosine_score_traj(CStats(:),10);
visualize_PCCosine_imageEvol(CStats(:),7,8)
calc_Cosine_RFmask_fun(CStats(15:end))
animate_Cosine_Evol_summary(CStats(:),15)
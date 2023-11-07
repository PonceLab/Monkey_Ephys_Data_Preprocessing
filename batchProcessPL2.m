function batchProcessPL2(ephysFNs, varargin)
% Simply Sorting of today's experiments and save the BigMat, with no other operations.
% assume ephysFNs is a string array or a cell array of ephysFN names. 
if nargin <= 1, sdf = 'sdf'; end % 'raster' otherwise
if nargin == 0 % get today's animal
    animal = input("Animal:",'s');
    date = input("Date:",'s');
    if isempty(date)
        date = datetime();
    end
    date = datetime(date,"InputFormat","yyyyMMdd");
    searchstr = string([animal,'-',datestr(date,"ddmmyyyy"),'*.pl2']);
    ephysFNs = string(ls("N:\Data-Ephys-Raw\"+searchstr));
    preMeta = arrayfun(@(fn)struct('ephysFN',fn{1}(1:end-4),'sdf',sdf), ephysFNs);
else
    if contains(ephysFNs{1},'.pl2')
    preMeta = arrayfun(@(fn)struct('ephysFN',fn{1}(1:end-4),'sdf',sdf), ephysFNs);
    else
    preMeta = arrayfun(@(fn)struct('ephysFN',char(fn{1}),'sdf',sdf), ephysFNs);
    end
end
Project_General_copyMissingFiles(preMeta)
for iFn = 1:numel(ephysFNs)
ephysFN = preMeta(iFn).ephysFN; % ephysFNs{iFn}(1:end-4);
try
sortPL2(ephysFN, varargin{:});
catch err % err is an MException struct, save the err in a log file and continue. 
    fprintf('Error message:\n%s\n',err.message);
    fprintf('Error trace:\n%s\n',err.getReport);
    disp(preMeta(iFn))
    %keyboard
    fileID = fopen('S:\Exp_error_log.log','w+');
    fprintf(fileID,'Error message:\n%s\n',err.message);
    fprintf(fileID,'Error trace:\n%s\n',err.getReport);
    fclose(fileID);
    continue
end
end
end

function sortPL2(ephysFN, varargin)
p = inputParser;
defaultEquipment =  'OMNIPLEX';
defaultExpControl = 'ML';
% defaultBaseline =   90;
% defaultRasterWindow =   [0 200];
% defaultExpControlName = '170619_ringo_screening.bhv2';

addRequired(p,  'ephysFN')
% addOptional(p,  'expControlFN',defaultExpControlName)
addParameter(p, 'expControl', defaultExpControl)
addParameter(p, 'equipment', defaultEquipment)
% addParameter(p, 'baselineWindowLength', defaultBaseline )
% addParameter(p, 'rasterWindow', defaultRasterWindow )
addParameter(p, 'sdf', 'sdf') % 'raster'

parse(p,ephysFN, varargin{:})

meta = p.Results;
meta = myPaths(meta);

if strcmp(meta.sdf, 'sdf')
bigMatPath = fullfile(meta.pathMat,[meta.ephysFN '.mat']);
elseif strcmp(meta.sdf, 'raster')
bigMatPath = fullfile(meta.pathMat,[meta.ephysFN '_spike.mat']);
else
error;
end
bigMatrixExists = exist(bigMatPath,'file');
if bigMatrixExists, fprintf("Found sorted file %s pass!\n",bigMatPath); return; end %
[spikeChans,lfpChans,timeline,spikeID,unitID,wvfms] = plxread_fullExperiment_vcrp(meta);
% Save the source of the channel per isolated unit/hash
if ~spikeID(1) 
    meta.spikeID = spikeID + 1;
else
    meta.spikeID = spikeID ;
end
meta.unitID = unitID;
meta.wvfms = wvfms;
% read words/bits from Plexon file
Trials = plxread_loadWordsInPlexonFile_v2(meta) ;
if strcmp(meta.sdf, 'sdf')
savefast(bigMatPath,'meta','Trials','spikeChans','lfpChans','timeline');
elseif strcmp(meta.sdf, 'raster') % change name! 
savefast(bigMatPath,'meta','Trials','spikeChans','lfpChans','timeline');
else
error();
end
end
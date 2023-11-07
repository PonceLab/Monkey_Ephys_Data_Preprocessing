function ExpRecord = readExpRecord(Animal)
if nargin == 0 
    Animal = "Both";
end
ExpSpecTable_Aug = readtable("S:\ExpSpecTable_Augment.xlsx",'Format','auto');
ExpSpecTable_Aug_alfa = readtable("S:\Exp_Record_Alfa.xlsx",'Format','auto');
switch Animal
    case "Alfa"
        ExpRecord = ExpSpecTable_Aug_alfa;
    case "Beto"
        ExpRecord = ExpSpecTable_Aug;
    case "Both"
        ExpRecord = [ExpSpecTable_Aug; ExpSpecTable_Aug_alfa];
end 

date_vec = {};
ephys_ids = [];
for rowi = 1:size(ExpRecord,1)
    bhv2fn = ExpRecord.expControlFN{rowi};
    ephysfn = ExpRecord.ephysFN{rowi};
    if length(ephysfn) ~= 0 
        parts = split(ephysfn,'-');
        date_str = parts{2};
        ephys_id = str2num(parts{3});
        date = datetime(date_str,'InputFormat','ddMMyyyy');
        date_vec{end+1} = date;
        if ~isempty(ephys_id)
            ephys_ids(rowi) = ephys_id;
        else
            ephys_ids(rowi) = 0;
        end
    elseif length(bhv2fn) ~= 0 
        parts = split(bhv2fn,'_');
        date_str = parts{1};
        date = datetime(date_str,'InputFormat','yyMMdd');
        date_vec{end+1} = date;
        ephys_ids(rowi) = -1;
    else
        error("msg")
        disp(ExpRecord(rowi,:))
    end
end
% ExpRecord.expdate = reshape(date_vec,[],1);
ExpRecord.expdate = cat(1,date_vec{:});
ExpRecord.ephys_id = reshape(ephys_ids,[],1);
end
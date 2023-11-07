Monkey Data Processing Set Up
====
# Data Processing Workflow

1. After experiments, back up the data (`PL2`, `BHV`) to `N:` drive and write up the OneNote.
2. Preprocess (spike sorting and filtering) the PL2 file, with `batchProcessPL2.m`, this will generate the BigMat file with spikes and continuous signal. 
	* This function will copy the PL2 file from `N:` drive to local `S:` drive, `S:\Data-Ephys-Raw`, and then sort the spikes and save it into `S:\Data-Ephys-MAT` 
	* This usually take an hour or so, so you can run this command and happily go to dinner and enjoy the show. XD
3. (Optional, but preferred by B.W.) Transform the onenotes into some more structured table format, e.g. excel and csv. I do this with the `ExpRecordBackup.bat` script, to format onenote into organized Excel files. 
	* --- this python script is sometimes brittle, weird character can break it! 
4. Process the BigMat file into the Formatted Mat file using the `loadExperiments` or `loadExperiments_preMeta` function. Then you will get an array of 
	* `loadExperiments` takes in rowids in the ExpRecord table. 
	* `loadExperiments_preMeta` takes in the `struct` or cell array of preMeta files. 
5. (Optional) Process the array of experiments with your analysis.
	* `Evol_Cosine_Analysis_modular.m` these are master script that can do all kinds of analysis in a modularized way. 
	* `*_Collect_Stats_fun` are functions which collect and save key responses for multi-experimental analysis and visualization, e.g.
	 `Evol_Cosine_Collect_Stats_fun`, `Evol_Optimizer_CMAGA_Collect_Stats.m` . 
6. (Optional) The formatted mat file or the `Stats` file can be loaded in Python. with `mat73` library `https://pypi.org/project/mat73/`

# Dependency
* High level loading code: sorting timeline into trials etc.
	* `git clone` `data-loading-code` from Ponce lab bitbucket, and add it to your matlab PATH. 
	* High level code written by CRP, contributed to and customized by BW and OR through the years.
	* **Key functions**
		* `loadData.m`: CRP's master script for loading data. 
		* `plxread_fullExperiment.m`: Load the whole PL2 file get spikes over whole time course into a "Big Mat" file. Very robust, *Not dependent on the `bhv2` file!* 
		* `plxread_trialBytrial_vcrp.m`: Using matched timing information from `bhv2` and `PL2` to cut the timeline into trials, discard invalid trials. 
			* *The matching process is not super robust*, issue can happen when Plexon is ended earlier than the task end, or started later, or network connection broke etc.
		* `myPaths.m`: Setting default paths for network folder and local mapping
* Interface with Plexon: reading PL2 files etc.
	* Download `OmniPlex and MAP Offline SDK Bundle` from https://plexon.com/software-downloads/, and then put the subfolders into matlab path. 
	* **Key function**
		* `OmniPlex and MAP Offline SDK Bundle\Matlab Offline Files SDK\plx_information.m`
* Interface with MonkeyLogic: reading BHV2 files etc.
	* Install Monkeylogic2 from https://monkeylogic.nimh.nih.gov/download.html. 
	* After install monkeylogic should be in your matlab path. If not add it. The path shall be like `C:\Users\ponce\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22` 
	* **NOTICE**: make sure the `which mlread` return the path above, to avoid shadowing problem. 
	* **NOTICE**: mlread version is critical. BHV2 file format changed over time, so older mlread function will break for newer format. 
	* **Key function**:
		* `NIMHMonkeyLogic22\mlread.m`: load bhv2 files


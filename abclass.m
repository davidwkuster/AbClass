%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% init
close all;
clear all;
clc;

rng(1) % Fixed seed for reproducibility

warning('off','all');

% Paths
root = dir;
workingroot = root.folder;
edffolder = uigetdir(workingroot,'Select ''edf'' folder in DataBase structure:');
trainsetpath = strcat(edffolder,'\train');
evalsetpath = strcat(edffolder,'\eval');

% Paths to EEGLab and Root of AbClass
eegfolder = uigetdir(workingroot,'Select ''EEGLab'' folder:');
addpath(eegfolder);

addpath(workingroot);

%% Definition of the Trial Parameters
% Default Parameters
definputs = {'all','all','3','10','8','def'};

prompt = {'Enter Train #:','Enter Eval #:','Enter time offset [min]:','Enter Sample Time [sec]:', 'Enter microstate prototypes # :','Trial Type: clustercmp,sfs,def'};
dlgtitle = 'Configs';
dims = [1 35];
inputs = inputdlg(prompt,dlgtitle,dims,definputs);

%% Loads EEGLab
% EEGLab path must be previouly added by 'addpath' from Matlab
eeglab nogui;

%% Enter working path
cd(workingroot);

%% SELECTING AND LOADING DATA
% LOAD preaviously saved MAT FILE instead of reading raw eeg sessions

yn = questdlg(sprintf('Would you like to load a saved data file?\n\n(Click No for reading raw sessions in \n%s and\n%s)', trainsetpath,evalsetpath)); % control for loading file or reading raw samples

dataload = strcmp(yn,'Yes');

if dataload
    %% SELECT DATA FROM DATAFILE
    [datafile, datapath] = uigetfile(workingroot,'Select ''.MAT'' data file:'); % Select file for reading manually
    fprintf('\nLoadind %s file at %s\n', datafile,datapath);
    load(strcat(datapath,datafile)); % Loading file
    dataload = true; %bugfix
    
    fprintf('Processing Samples:\nTrain Samples\t|\t%d\nEval Samples\t|\t%d\n', n_samples_train, n_samples_eval);
    fprintf('Interval\t|\t%d-%d sec\n', t_range(1), t_range(2));
    
    n_alleeg = length(ALLEEG);
end

%% SELECT DATA FOR READING FROM RAW EEG SESSIONS
n_samples_train = inputs{1}; % used for reading all samples or a subset of N samples in 'trainsetpath'
n_samples_eval = inputs{2}; % used for reading all samples or a subset of N samples in 'evalsetpath'

% Time offset and time interval to process
t_start = str2num(inputs{3});  % min offset
delta_t = str2num(inputs{4}); % sec of recording block to read from each session
fprintf('Processing Samples:\nTrain Samples\t|\t%s\nEval Samples\t|\t%s\n', n_samples_train, n_samples_eval);

% Interval offset
% t_start minutes offset for stabilization of the signal capture
% delta_t interval of seconds to read
t_range = [60*t_start 60*t_start+delta_t];

fprintf('Interval\t|\t%d-%d sec\n', t_range(1), t_range(2));

%% Dataset structure

% Defines the DATASET folder(s) structure
DB = struct('folders', ...
      struct('trainset',trainsetpath, ...
             'evalset',evalsetpath), ...
       'train',struct('abnormal',struct([]),'normal',struct([])), ...
       'eval',struct('abnormal',struct([]),'normal',struct([])));

% Find all *.EDF Files in the Subdirectories 
% TrainSet
cd([DB.folders.trainset '\abnormal'])
DB.train.abnormal = dir('**/*.edf');

cd([DB.folders.trainset '\normal'])
DB.train.normal = dir('**/*.edf');

% EvalSet
cd([DB.folders.evalset '\abnormal'])
DB.eval.abnormal = dir('**/*.edf');

cd([DB.folders.evalset '\normal'])
DB.eval.normal = dir('**/*.edf');

cd(workingroot);

%% Define sizes of all sessions in trainsetpath and evalsetpath
n_train_ab = length(DB.train.abnormal);
n_train_n = length(DB.train.normal);

n_train = n_train_ab + n_train_n;

n_eval_ab = length(DB.eval.abnormal);
n_eval_n = length(DB.eval.normal);

n_eval = n_eval_ab + n_eval_n;

n_total = n_train + n_eval;

if strcmp(n_samples_train,'all') % if all TRAIN samples
    n_samples_train_ab = n_train_ab;
    n_samples_train_n = n_train_n;
    n_samples_train = n_train; % total train samples
else
    n_samples_train = str2num(n_samples_train); % if not all convert to num

    % if not all, define stratified # for abnormal and normal TRAIN samples
    % based on original distribution
    n_samples_train_ab = ceil(n_samples_train*(n_train_ab/n_train));
    n_samples_train_n = n_samples_train - n_samples_train_ab;
end

if strcmp(n_samples_eval,'all') % if all EVAL samples
    n_samples_eval_ab = n_eval_ab;
    n_samples_eval_n = n_eval_n;
    n_samples_eval = n_eval;
else
    % if not all, define stratified # for abnormal and normal EVAL samples
    % based on original distribution
    n_samples_eval = str2num(n_samples_eval);
    n_samples_eval_ab = ceil(n_samples_eval*(n_eval_ab/n_eval));
    n_samples_eval_n = n_samples_eval - n_samples_eval_ab;
end

train_start = 1;
train_end = n_samples_train_ab + n_samples_train_n;

eval_start = n_train + 1;
eval_end = eval_start + n_eval_ab + n_eval_n - 1;

n_samples_total = n_samples_train + n_samples_eval;

%% READ DATA
% Reads data from defined indices and returns to db_idx the indices of the
% files within DB variable
if ~ dataload
    read_data_train
    read_data_eval
    
    n_alleeg = length(ALLEEG);
end

%% Creating db_idx with indices for read sessions to use
% Random sampling
% ###############

idx_train_ab = train_start:train_start+n_train_ab-1;
idx_train_n = train_start+n_train_ab:train_start+n_train_ab+n_train_n-1;

idx_eval_ab = eval_start:eval_start+n_eval_ab-1;
idx_eval_n = eval_start+n_eval_ab:eval_start+n_eval_ab+n_eval_n-1;

% If All train samples
if n_samples_train_ab == length(idx_train_ab)
    train_range = [ idx_train_ab idx_train_n ];
else % If a random subset
    train_range = sort([ idx_train_ab(randperm(n_train_ab,n_samples_train_ab)) idx_train_n(randperm(n_train_n,n_samples_train_n)) ]);
end

% If All test samples
if n_samples_eval_ab == length(idx_eval_ab)
    eval_range = [ idx_eval_ab idx_eval_n ];
else % If a random subset
    eval_range = sort([ idx_eval_ab(randperm(n_eval_ab,n_samples_eval_ab)) idx_eval_n(randperm(n_eval_n,n_samples_eval_n)) ]);
end

db_idx = [train_range eval_range];

%% Defines the Number os MicroStates
NMS = str2num(inputs{5});


fprintf('# MicroStates\t|\t%d\n', NMS);

currentpathroot = strcat(workingroot,'\Saved Results\',num2str(n_samples_train),'\',num2str(NMS),'MS\');
try
    cd(currentpathroot);
    cd(workingroot);
catch
    mkdir(currentpathroot);
    cd(workingroot);
end

diary(strcat(currentpathroot,'log');

%% Select ELC CED files
elc_path = uigetfile(strcat(eegfolder,'\plugins\dipfit\standard_BEM\elec\standard_1005.elc'),'Select ''.ELC'' elec file:');
ced_path = uigetfile(strcat(workingroot,'\channel_location_MNI.ced'),'Select ''.CED'' Chan Loc file:');

%% PREPROCESS
% Calls pre_process function if it hasn't been done yet
fprintf('Pre Processing %d Sets.\n', length(db_idx));
for i = db_idx
    if ~ ALLEEG(i).preproc
        pre_process
    else
        fprintf('\nSet %d has already been preprocessed.\n', i)
    end
end

%% SEGMENT ALL DATASETS - CREATE MS PROTOTYPES
% modified k-means clustering algorithm using MS Toolbox 1.0 [Poulsen, 2018]
microstate_segmentation_all

%% Select active number of microstates
EEG = pop_micro_selectNmicro( EEG, 'Nmicro', NMS);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% PREPARE
% creates auxiliary variables to the optimization and classification
prepare

%% Optimize LVQ
% Learning Vector Quantization optimization of the MS prototypes created by
% the default k-means algorythm
if ~ strcmp(inputs{6},'sfs')
    LVQ_optimize
end


%% CLUSTERING COMPARE or SFS
if strcmp(inputs{6},'clustercmp')
    %% LVQ Clustering
    % Learning Vector Quantization clustering of the MS prototypes
    LVQ_cluster

    %% Save Prototype Figures
    for i = 0:2
        EEG = ALLEEG(proto_idx+i);
        % Plot microstate prototype topographies
        figure;MicroPlotTopo( EEG, 'plot_range', [] );title(EEG.setname)
        set(gcf, 'Position', [0 0 1280 1280])
        cd(currentpathroot);
        filename = strcat('MS - ', EEG.setname);
        formattype = 'png';
        saveas(gcf,filename,formattype)
        cd(workingroot);
        close
    end
elseif strcmp(inputs{6},'sfs')
    figure,
    EEG = ALLEEG(proto_idx);
    % Plot kmeans microstate prototype topographies
    MicroPlotTopo( EEG, 'plot_range', [] );title(EEG.setname)
    set(gcf, 'Position', [0 0 1280 1280])
    cd(currentpathroot);
    filename = strcat('MS SFS - ', EEG.setname);
    formattype = 'png';
    saveas(gcf,filename,formattype)
    cd(workingroot);
    close
else
    figure,
    EEG = ALLEEG(proto_idx);
    % Plot kmeans microstate prototype topographies
    subplot(2,1,1);MicroPlotTopo( EEG, 'plot_range', [] );title(EEG.setname)
    EEG = ALLEEG(proto_idx+1);
    % Plot kmeans+lvq microstate prototype topographies
    subplot(2,1,2);MicroPlotTopo( EEG, 'plot_range', [] );title(EEG.setname)
    set(gcf, 'Position', [0 0 1280 1280])
    cd(currentpathroot);
    filename = strcat('MS - ',ALLEEG(proto_idx).setname,'+',ALLEEG(proto_idx+1).setname);
    formattype = 'png';
    saveas(gcf,filename,formattype)
    cd(workingroot);
    close
end

%% BACKFIT, SFS, TRAIN, EVAL
if strcmp(inputs{6},'clustercmp')
    %% multiple tries
    clustering = {'kmeansmod','kmeans+lvq','lvq'}; %Compares multiple clustering algorithms
elseif strcmp(inputs{6},'sfs')
    %% SFS
    clustering = {'kmeans'};
else
    clustering = {'kmeans+lvq'};

    if ~strcmp(inputs{6},'def')
        fprintf('\n"%s" is not a valid implemented trial type...\n', inputs{6});
    end
    fprintf('\nRunning default %s clustering...\n', clustering{:});
end


for i = 1:length(clustering)
    
    clusteropt = clustering{i};
    
    currentpath = strcat(currentpathroot,'\',clusteropt);
    try
        cd(currentpath);
    catch
        mkdir(currentpath);
        cd(currentpath);
    end
    
    fprintf('\n\nBackfit for %s clustering...\n', clusteropt);

    %% BACKFIT
    % Fits back the generated MS prototypes to the original EEG signals,
    % applies the temporal smoothing and generates the Statistics for the
    % fitted MS
    backfit

    %% Feature extraction and t-SNE Visualization
    % Visualization os the data in reduced dimensions for verifying
    % separability
    Viz

  
    %% CLASSIFY
    % Classifies the original signal as either Normal or Abnormal based on the
    % MS prototypes generated
    if strcmp(inputs{6},'sfs')
        %% SFS
        sfs
        %% SAVE RESULTS
        cd(currentpath);
        
        try
            cd sfs;
        catch
            mkdir sfs;
            cd sfs;
        end
        
        save(strcat(num2str(n_samples_train),' -'," ",num2str(NMS),'MS',' -'," ",clusteropt,'.mat'));
        cd(workingroot);
    else
        %% classification test
        classify
        
        %% 10 x hold out
        test_classifiers

        %% Hypothesis test
        hypothesis_test
        
        %% SAVE RESULTS
        cd(currentpath);
        save(strcat(num2str(n_samples_train),' -'," ",num2str(NMS),'MS',' -'," ",clusteropt,'.mat'));
        cd(workingroot);
    end

end

diary off
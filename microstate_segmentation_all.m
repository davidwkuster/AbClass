%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Microstate Segmentation

fprintf('\n\nGenerating microstate Representation for Sets %d - %d\n',1,length(train_range));

CURRENTSET = length(ALLEEG);
EEG = ALLEEG(CURRENTSET);

% Select data for microstate segmentation
[EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG,...
                                      'datatype', 'spontaneous',...
                                      'avgref', 1,...
                                      'normalise', 1,...
                                      'MinPeakDist', 10,...
                                      'Npeaks', 100,...
                                      'GFPthresh', 1,...
                                      'dataset_idx', train_range );

% Store in new EEG structure
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% select the "GFPpeak" dataset and make it the active set
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve', CURRENTSET+1,'study',0);

%% Segmentation
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans',...
        'sorting', 'Global explained variance',...
        'normalise', 1, 'Nmicrostates', NMS,...
        'verbose',0, 'Nrepetitions', 50,...
        'fitmeas', 'CV','max_iterations', 1000,...
        'threshold', 1e-06, 'optimised', 1);

EEG.setname = 'kmeansmod';
% Saves the MS Segmentation using kmeans to ALLEEG at CURRENTSET pos
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Pre_process
% defines location files of the electrodes positioning in 10-20 international
% system for 2D and 3D representations using EEGLab plort functions

idx = i;

%% Retrieve set at idx pos
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',idx,'study',0);
EEG = eeg_checkset( EEG ); %check set integrity

%% 1. PREPROCESSING STEPS
% Select 21 Channels present across all the sets
EEG = pop_select( EEG, 'channel',{'EEG FP1-REF','EEG FP2-REF',...
                                  'EEG F3-REF','EEG F4-REF',...
                                  'EEG C3-REF','EEG C4-REF',...
                                  'EEG P3-REF','EEG P4-REF',...
                                  'EEG O1-REF','EEG O2-REF',...
                                  'EEG F7-REF','EEG F8-REF',...
                                  'EEG T3-REF','EEG T4-REF',...
                                  'EEG T5-REF','EEG T6-REF',...
                                  'EEG A1-REF','EEG A2-REF',...
                                  'EEG FZ-REF','EEG CZ-REF',...
                                  'EEG PZ-REF'});

% overwrite changes to ALLEEG at CURRENTSET pos
% EEGLab automatically updates CURRENTSET when retrieving set with
% pop_newset 'retrieve'
EEG = eeg_checkset( EEG );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off'); 

%% Define Channel Locations

EEG = pop_chanedit(EEG, 'lookup',elc_path,...
                   'load',{ced_path,'filetype','chanedit'},...
                   'eval','chans = pop_chancenter( chans, [],[]);');
% stores channel locations
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% RESAMPLE IF NECESSARY
% Most sets are sampled at 250 Hz
% MS Analysis requires consistent Srates in all samples

if ALLEEG(i).srate ~= 250
    fprintf('Resampling Set %d to 250 Hz ...\n', idx);
    EEG = pop_resample( EEG, 250);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,idx,'overwrite','on','gui','off');
end

%% 1.1 Filter FIR Filter BandPass 1 - 30 Hz
% [Zappasodi, 2017]
% [Poulsen, 2018]

% Retrieve set at idx pos
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',idx,'study',0);
% Filtering
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',30);
% Overwrite set
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');

% Control variable
ALLEEG(idx).preproc = true;

%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Read Data
% Load Sets in DB paths and stores back in DB

for i=1:n_samples_train_ab
    % Read New Set
    setname = ['train_ab_' DB.train.abnormal(i).name(1:end-4)]
    
    fprintf('Reading %s dataset\n',setname);
         
    EEG = pop_biosig([DB.train.abnormal(i).folder '\' DB.train.abnormal(i).name], ...
                     'memorymapped','off',...
                     'blockrange',t_range);
                 
    EEG.preproc = 0;

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                         'setname',setname,...
                                         'gui','off');
end

for i=1:n_samples_train_n
    % Read New Set
    setname = ['train_n_' DB.train.normal(i).name(1:end-4)]
    
    fprintf('Reading %s dataset\n',setname);
         
    EEG = pop_biosig([DB.train.normal(i).folder '\' DB.train.normal(i).name], ...
                     'memorymapped','off',...
                     'blockrange',t_range);
    EEG.preproc = 0;

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                         'setname',setname,...
                                         'gui','off');
end
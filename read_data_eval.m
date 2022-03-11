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

% db_idx = 1;

for i=1:n_samples_eval_ab
    % Read New Set
    setname = ['eval_ab_' DB.eval.abnormal(i).name(1:end-4)]
    
    fprintf('Reading %s dataset\n',setname);
         
    EEG = pop_biosig([DB.eval.abnormal(i).folder '\' DB.eval.abnormal(i).name], ...
                     'memorymapped','off',...
                     'blockrange',t_range);
    EEG.preproc = 0;

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                         'setname',setname,...
                                         'gui','off');
end

for i=1:n_samples_eval_n
    % Read New Set
    setname = ['eval_n_' DB.eval.normal(i).name(1:end-4)]
    
    fprintf('Reading %s dataset\n',setname);
         
    EEG = pop_biosig([DB.eval.normal(i).folder '\' DB.eval.normal(i).name], ...
                     'memorymapped','off',...
                     'blockrange',t_range);
    EEG.preproc = 0;

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                         'setname',setname,...
                                         'gui','off');
end
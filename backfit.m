%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

switch clusteropt
    case 'kmeansmod'
        ms_idx = proto_idx;
    case 'kmeans+lvq'
        ms_idx = proto_idx+1;
    case 'lvq'
        ms_idx = proto_idx+2;
end

fprintf('Importing prototypes and backfitting for %d datasets\n',length(db_idx));
fprintf('Calculating Statistics...\n');

if n_alleeg == n_total
    idx = db_idx;
else
    idx = 1:length(db_idx);
end
    

for i=idx
    
    fprintf('\nBackfitting Sample: %d\n', i);

    %% Backfitting

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',i,'study',0);

    EEG = pop_micro_import_proto( EEG, ALLEEG, ms_idx);

    %% 3.6 Back-fit microstates on EEG
    EEG = pop_micro_fit( EEG, 'polarity', 0 );

    %% 3.7 Temporally smooth microstates labels
    EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
               'smooth_type', 'reject segments', ...
               'minTime', 30, ...
               'polarity', 0 );

    %% 3.9 Calculate microstate statistics
    EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
              'polarity', 0 );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);


    ALLEEG(i).msproc = true;
end
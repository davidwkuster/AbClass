%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Definition of EEG type based on filename convention

for i=1:length(ALLEEG)-1 % All except ms prototypes
    
    setname = ALLEEG(i).setname(end-17:end);
    comments = ALLEEG(i).comments;
    
    type_test = strfind(comments,'train');
    if isempty(type_test)
        type = 'eval';
    else
        type = 'train';
    end
    
    label_test = strfind(comments,'abnormal');
    if isempty(label_test)
        label = 'normal';
    else
        label = 'abnormal';
    end
        DB_PROC(i) = struct('idx', i,'setname', setname,'type',type, 'label',label);
end

%% DATA PREPARATION

% Last position is the MS prototypes index by default of the EEGLab / MST
% 1.0
proto_idx = n_alleeg+1;

% double convertion necessary for some classification algorythms in Matlab
ms_prototypesT = double(ALLEEG(proto_idx).microstate.prototypes.');

% GFPpeaks used for the clustering algorythm by default of the EEGLab / MST
% 1.0
samples_GFPpeaks = ALLEEG(proto_idx).data;

%quantity of GFP peaks from data
n_GFPpeaks = length(samples_GFPpeaks);
n_GFPpeaks_per_sample = length(ALLEEG(proto_idx).microstate.GFPpeakidx{1, 1});
classes_GFPpeaks = ones(1,n_GFPpeaks);

%Generating labels
labels = struct();

%% Definition of the classes of the GFPpeaks
for i = 1:length(db_idx)
    
    labels(i).label = DB_PROC(db_idx(i)).label; %Labels of selected Samples
   
end

%% Create Labels and Classes vectors
labels_train = labels(1:n_samples_train);
labels_eval = labels(n_samples_train+1:n_samples_train+1+n_samples_eval-1);

classes_train = zeros(length(labels_train),1);

for i=1:length(labels_train)
    if strcmp(labels_train(i).label,'normal')
        classes_train(i) = 1;
    else
        classes_train(i) = 2;
    end
end

classes_eval = zeros(length(labels_eval),1);

for i=1:length(labels_eval)
    if strcmp(labels_eval(i).label,'normal')
        classes_eval(i) = 1;
    else
        classes_eval(i) = 2;
    end
end

% Assignment of the class of each individual GFP peak
for k = 1:length(classes_train)
    for i = (k-1)*n_GFPpeaks_per_sample+1:k*n_GFPpeaks_per_sample
        classes_GFPpeaks(i) = classes_train(k);
    end
end
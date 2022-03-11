%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Sequential Feature Selection
c = cvpartition(TrainLabels,'k',10);
opts = statset('Display','iter');
fun = @(train_data,train_labels,test_data,test_labels) ...
       sum(predict(fitcsvm(train_data,train_labels,'KernelFunction','rbf'), test_data) ~= test_labels);

[fs,history] = sequentialfs(fun,TrainSamples,classes_train,'cv',c,'options',opts);

%% Training Classifiers

trainsfs = TrainSamples(:,fs);
evalsfs = EvalSamples(:,fs);

% Optimization Parameters
opts = struct('Optimizer','bayesopt','ShowPlots',false,'CVPartition',CVp,...
    'AcquisitionFunctionName','expected-improvement-plus','verbose', 0);

% 1 - Support Vector Machine Training
fprintf('Training SVM...\n');
AbnormalSVMsfs = fitcsvm(trainsfs,TrainLabels,...
                 'OptimizeHyperparameters','auto',...
                 'HyperparameterOptimizationOptions',opts)
fprintf('Training SVM Finished...\n');

%% testing
test_classifiers_sfs
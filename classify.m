%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% CLASSIFY
% Trains and optimizes 3 classification algorithms with bayesian
% optmization using 10-fold cross validation partitioning

%% Rearrange Samplse
% Train Samples
TrainSamples = train_features.';
TrainLabels = {labels_train(:).label};

% EvalSamples
EvalSamples = eval_features.';
EvalLabels = {labels_eval(:).label};

%% Creating CV partition
% CV partition 10-fold CV
fprintf('Creating 10-fold CV partition for Train Samples...\n');
[samples, features] = size(TrainSamples);
CVp = cvpartition(samples,'KFold',10);

%% Optimizing Classifiers

% Optimization Parameters
opts = struct('Optimizer','bayesopt','ShowPlots',false,'CVPartition',CVp,...
    'AcquisitionFunctionName','expected-improvement-plus','verbose', 0);

%% 1 - Support Vector Machine Training
fprintf('Optmizing Hyperparameters for SVM classifier...\n');
AbnormalSVM = fitcsvm(TrainSamples,TrainLabels,...
                 'OptimizeHyperparameters','auto',...
                 'HyperparameterOptimizationOptions',opts,...
                 'Standardize',1);

SVMParam = struct('KernelFunction', AbnormalSVM.ModelParameters.KernelFunction,...
                  'BoxConstraint', AbnormalSVM.ModelParameters.BoxConstraint,...
                  'KernelScale', AbnormalSVM.ModelParameters.KernelScale);

fprintf('Selected\nKernelFunction: %s\nBoxConstraint: %.2f\n\n', SVMParam.KernelFunction,SVMParam.BoxConstraint);

fprintf('Optmizing SVM Finished...\n');

%% 2 - Random Forest Train
fprintf('Optmizing Hyperparameters for RF classifier...\n');
AbnormalRF = fitcensemble(TrainSamples,TrainLabels,...
             'Method','Bag',...
             'OptimizeHyperparameters','auto',...
             'HyperparameterOptimizationOptions',opts);

ParamRF = struct('NLearn', AbnormalRF.ModelParameters.NLearn,...
                  'Method', AbnormalRF.Method);

fprintf('Selected\nNLearn: %d\n\n', ParamRF.NLearn);

fprintf('Optmizing RF Finished...\n');

%% 3 - kNN Train
fprintf('Optmizing Hyperparameters for kNN classifier...\n');
num = optimizableVariable('n',[1,25],'Type','integer');
dst = optimizableVariable('dst',{'chebychev','euclidean','minkowski'},'Type','categorical');
fun = @(x)kfoldLoss(fitcknn(TrainSamples,TrainLabels,'CVPartition',CVp,'NumNeighbors',x.n,...
    'Distance',char(x.dst),'NSMethod','exhaustive'));
results = bayesopt(fun,[num,dst],...
    'AcquisitionFunctionName','expected-improvement-plus','verbose', 0);

opt_num = results.XAtMinEstimatedObjective.n;
opt_dst = sprintf('%s',results.XAtMinEstimatedObjective.dst);

if mod(opt_num,2) == 0
    opt_num = opt_num+1;
end

AbnormalkNN = fitcknn(TrainSamples,TrainLabels,'NumNeighbors', opt_num,'Distance',opt_dst,'Standardize',1);

ParamkNN = struct('NumNeighbors', AbnormalkNN.NumNeighbors,...
                  'Distance', AbnormalkNN.Distance);

fprintf('Selected\nNumNeighbors: %d\nDistance: %s\n\n', ParamkNN.NumNeighbors,ParamkNN.Distance)

fprintf('Training kNN Finished...\n');
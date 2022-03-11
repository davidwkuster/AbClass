%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% 10 X holdout testing

fprintf('10 times hold out test...\n');
times = 10;

% Variables for storing the Error
SVMerr = zeros(1,times);
RFerr = zeros(1,times);
kNNerr = zeros(1,times);

for i = 1:times
    fprintf('Trial # %d\n',i);
    
    fprintf('Creating partitioning...\n');
    partition = cvpartition(train_classes,'HoldOut',0.1);
    
    % get indices of the subset
    indt = find(training(partition));
    inde = find(test(partition));
    
    
    N = length(inde);
    
    this_train_labels = TrainLabels(indt).';
    this_train_samples = TrainSamples(indt,:);
    
    this_test_labels = TrainLabels(inde).';
    this_test_samples = TrainSamples(inde,:);

    % 1 - Support Vector Machine Test
    fprintf('Training SVM ...\n')
    
    thisSVM = fitcsvm(this_train_samples,this_train_labels,...
                      'KernelFunction',SVMParam.KernelFunction,...
                      'BoxConstraint',SVMParam.BoxConstraint,...
                      'KernelScale',SVMParam.KernelScale,...
                      'Standardize',1);
    
    label_svm_train = predict(thisSVM,this_test_samples);
    SVMerr(i) = 100 - 100*sum(strcmp(label_svm_train,this_test_labels))/N;
    
    % 2 - Random Forest
    fprintf('Training RF ...\n')
    
    thisRF = fitcensemble(this_train_samples,this_train_labels,...
                      'NLearn',ParamRF.NLearn,...
                      'Method',ParamRF.Method);
                  
    label_rf_eval = predict(thisRF,this_test_samples);
    RFerr(i) = 100 - 100*sum(strcmp(label_rf_eval,this_test_labels))/N;
    
    % 3 - k Nearest Neighbors
    fprintf('Training kNN ...\n')
    
    thiskNN = fitcknn(this_train_samples,this_train_labels,...
                      'NumNeighbors',ParamkNN.NumNeighbors,...
                      'Distance',ParamkNN.Distance,...
                      'Standardize',1);
                  
    label_knn_eval = predict(thiskNN,this_test_samples);
    kNNerr(i) = 100 - 100*sum(strcmp(label_knn_eval,this_test_labels))/N;
    
end

%% Plot
fprintf('Plotting All Error boxplots...\n');
Allerr = [SVMerr.' RFerr.' kNNerr.'];
Classifiers = {'RF','CNN-MLP'};
figure,
hold on;
grid on;
title(sprintf('Error Rate for %d Train Samples\n 10 times holdout\n %s clustering', n_samples_train,clusteropt))
xlabel('Classifier')
ylabel('% of Error')
boxplot([Allerr(:,2) 21.2*ones(10,1)],Classifiers)
hold on;
plot([0,0],[21.2,21.2])

%% Save Figure
cd(currentpath);
filename = strcat('all samples 16 MS backfit - ',clusteropt);
formattype = 'png';
saveas(gcf,filename,formattype)
cd(workingroot);
close;

%% Statistical Hypothesis Testing
figure,histfit(SVMerr);title('SVM Classification Error Histogram Normal Distribution Fit')
% Save Figure
cd(currentpath);
filename = strcat('SVM fit - ',clusteropt);
formattype = 'png';
saveas(gcf,filename,formattype)
cd(workingroot);
close;

figure,histfit(RFerr);title('RF Classification Error Histogram Normal Distribution Fit')
% Save Figure
cd(currentpath);
filename = strcat('RF fit - ',clusteropt);
formattype = 'png';
saveas(gcf,filename,formattype)
cd(workingroot);
close;

figure,histfit(SVMerr);title('kNN Classification Error Histogram Normal Distribution Fit')
% Save Figure
cd(currentpath);
filename = strcat('kNN fit - ',clusteropt);
formattype = 'png';
saveas(gcf,filename,formattype)
cd(workingroot);
close;

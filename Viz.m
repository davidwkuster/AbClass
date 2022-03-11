%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% t-SNE and PCA Visualization

train_features = [];
train_classes = zeros(1, n_samples_train);
t_idx = 1;

eval_features = [];
eval_classes = zeros(1, n_samples_eval);
e_idx = 1;
fprintf('\nExtracting Features ...\n');

for i=idx
        
    if strcmp(DB_PROC(i).type, 'train')

        % Acquire stats from backfit for ith set
        stat = ALLEEG(i).microstate.stats; 
        % Feature 
        this_stat = [ stat.Occurence(:) stat.Duration(:) stat.Coverage(:) stat.GEV(:) stat.TP ];
        train_features = [ train_features, this_stat(:) ];        
        train_classes(t_idx) = (ALLEEG(i).setname(7) == 'a') + 1;
        t_idx = t_idx + 1;
    else
        stat = ALLEEG(i).microstate.stats;
        this_stat = [ stat.Occurence(:) stat.Duration(:) stat.Coverage(:) stat.GEV(:) stat.TP ];
        eval_features = [ eval_features, this_stat(:) ];        
        eval_classes(e_idx) = (ALLEEG(i).setname(6) == 'a') + 1;
        e_idx = e_idx + 1;
    end
end

fprintf('Train: %d Eval: %d Samples processed!\n', t_idx-1,e_idx-1);

[samples features] = size(train_features.');
norm_train_features = train_features.';
norm_eval_features = eval_features.';

%% Viz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Y loss] = tsne(eval_features.','Algorithm','exact','Distance','euclidean', 'NumDimensions', 2);

%% plot t-SNE
figure,
scatter(Y(:,1),Y(:,2),30,eval_classes,'filled');
title('t-SNE Euclidean');
grid on;

%% Save Figure
set(gcf, 'Position', [0 0 1280 1280])
cd(currentpath);
filename = strcat('t-SNE');
formattype = 'png';
saveas(gcf,filename,formattype)
cd(workingroot);
close;

%% Voronoi
figure,
voronoi(Y(:,1),Y(:,2));
title('Voronoi t-SNE Euclidean');
grid on;
hold on;
scatter(Y(:,1),Y(:,2),30,10*eval_classes,'filled');
grid on;

%% Save Figure
set(gcf, 'Position', [0 0 1280 1280])
cd(currentpath);
filename = strcat('Voronoi t-SNE');
formattype = 'png';
saveas(gcf,filename,formattype)
cd(workingroot);
close;
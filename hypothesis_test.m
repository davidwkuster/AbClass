%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Friedman Hypothesis Test
fprintf('\n\n FRIEDMAN TEST')
fprintf('\n..............................................................\n')
fprintf('Ho - null hypothesis: The Classifiers are equal.\n')
fprintf('H1 - alternate hypothesis: The Classifiers are different.\n')
fprintf('..............................................................\n')

alpha = 0.05;
[p,tbl,stats] = friedman(Allerr);
c = multcompare(stats);

if p > alpha
    fprintf(' p-value = %.4f > alpha = %.5f \n',p, alpha);
    fprintf('Continue assuming Ho.\n');
else
    fprintf(' p-value = %.4f < alpha = %.4f \n',p, alpha);
    fprintf('Reject Ho.\n');
end

%% Wilcoxon 2-sided rank sum test
fprintf('\n\n WILCOXON 2-SIDED RANK SUM TEST')
fprintf('\n..............................................................\n')
fprintf('Ho - null hypothesis: The Classifiers are equal.\n')
fprintf('H1 - alternate hypothesis: The Classifiers are different.\n')
fprintf('..............................................................\n')

alpha = 0.05;
[p,h,stats] = ranksum(Allerr(:,1),Allerr(:,2));
sprintf('%s vs %s\n',Classifiers{1},Classifiers{2})
if p > alpha
    fprintf(' p-value = %.4f > alpha = %.5f \n',p, alpha);
    fprintf('Continue assuming Ho.\n');
else
    fprintf(' p-value = %.4f < alpha = %.4f \n',p, alpha);
    fprintf('Reject Ho.\n');
end

[p,h,stats] = ranksum(Allerr(:,2),Allerr(:,3));
sprintf('%s vs %s\n',Classifiers{2},Classifiers{3})
if p > alpha
    fprintf(' p-value = %.4f > alpha = %.5f \n',p, alpha);
    fprintf('Continue assuming Ho.\n');
else
    fprintf(' p-value = %.4f < alpha = %.4f \n',p, alpha);
    fprintf('Reject Ho.\n');
end

[p,h,stats] = ranksum(Allerr(:,3),Allerr(:,1));
sprintf('%s vs %s\n',Classifiers{3},Classifiers{1})
if p > alpha
    fprintf(' p-value = %.4f > alpha = %.5f \n',p, alpha);
    fprintf('Continue assuming Ho.\n');
else
    fprintf(' p-value = %.4f < alpha = %.4f \n',p, alpha);
    fprintf('Reject Ho.\n');
end
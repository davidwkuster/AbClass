%% Abnormal Classifier for EEG using Microstate and Machine Learning
%
% This script runs the Abnormal Classifier for EEG
% using Microstate and Machine Learning
%
% Author:
% David Wilkerson Küster
% Universidade Federal do Espírito Santo
% Vitória/Espírito Santo/Brazil

%% Learning Vector Quantization

% Aux var for classes as a vector
classes_GFPpeaks_vec = ind2vec(classes_GFPpeaks);

% Normalization by average chan std
samples_GFPpeaks = samples_GFPpeaks./mean(std(samples_GFPpeaks,0,2));

%% Defining LVQ Net
LVQnetcluster = lvqnet(NMS,0.005);

% LVQ Parameters
LVQnetcluster.trainParam.epochs=50;
LVQnetcluster=configure(LVQnetcluster,samples_GFPpeaks,classes_GFPpeaks_vec);

% Testing LVQ clustering method

%% Training

% EARLY STOPPING
LVQnetcluster.divideFcn = 'dividerand';
% https://www.mathworks.com/help/deeplearning/ug/improve-neural-network-generalization-and-avoid-overfitting.html#bss4gz0-32

LVQnetcluster=train(LVQnetcluster,samples_GFPpeaks,classes_GFPpeaks_vec);

%% normalise
% proto_ms are the prototypes of microstates obtained during training
proto_ms = LVQnetcluster.IW{1,1}.';

[chan prot] = size(proto_ms);

for i = 1:prot
   proto_ms(:,i) =  proto_ms(:,i)/norm(proto_ms(:,i));
end

%% save LVQ clustering MS prototypes
CURRENTSET = proto_idx;
EEG = ALLEEG(CURRENTSET);

% attrib ms to last position
EEG.microstate.Res.A_all{1, 1} = proto_ms;
EEG.microstate.prototypes = proto_ms;

EEG.setname = 'LVQ clustering';

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                     'gui','off');
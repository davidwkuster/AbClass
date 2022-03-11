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
LVQnet = lvqnet(NMS,0.005);

% LVQ Parameters
LVQnet.trainParam.epochs=50;
LVQnet=configure(LVQnet,samples_GFPpeaks,classes_GFPpeaks_vec);

% LVQ adjusting method
LVQnet.IW{1,1} = ms_prototypesT;

%% Training

% EARLY STOPPING
LVQnet.divideFcn = 'dividerand';
% https://www.mathworks.com/help/deeplearning/ug/improve-neural-network-generalization-and-avoid-overfitting.html#bss4gz0-32

LVQnet=train(LVQnet,samples_GFPpeaks,classes_GFPpeaks_vec);

%% normalise
% adj_ms are the adjusted prototypes of ms
adj_ms = LVQnet.IW{1,1}.';

[chan prot] = size(adj_ms);

for i = 1:prot
   adj_ms(:,i) =  adj_ms(:,i)/norm(adj_ms(:,i));
end

%% save adjusted MS prototypes

CURRENTSET = proto_idx;
EEG = ALLEEG(CURRENTSET);

% attrib optimized ms to last position
EEG.microstate.Res.A_all{1, 1} = adj_ms;
EEG.microstate.prototypes = adj_ms;

EEG.setname = 'LVQ adjusted';

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                     'gui','off');
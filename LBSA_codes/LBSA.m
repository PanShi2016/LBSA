function [] = LLSA(sampleMode,algosMode) 
% Local Lanczos Spectral Approximation
% k: number of Lanczos iteration
% alpha: a parameter controls local minimal conductance

if nargin < 1
    sampleMode = 'hk';
end

if nargin < 2
    algosMode = 'Lanczos';
end

graphPath = '../example/Amazon/graph';
communityPath = '../example/Amazon/community';

% load graph
graph = loadGraph(graphPath);

% load truth communities
comm = loadCommunities(communityPath);

% choose a community from truth communities randomly
commId = randi(length(comm));

% choose 3 nodes from selected community randomly
seedId = randperm(length(comm{commId}),3);
seed = comm{commId}(seedId);

% grab subgraph from each seed set
if true == strcmp(sampleMode,'rw')
    steps = 3;
    sample = rwsample(graph,seed,steps);

elseif true == strcmp(sampleMode,'ppr')
    epsil = 1e-6;
    alpha = 0.9;
    sample = pprsample(graph,seed,epsil,alpha);

elseif true == strcmp(sampleMode,'hk')
    t = 3;
    epsil = 1e-6;
    sample = hksample(graph,seed,t,epsil);
end

% preprocessing, delete isolated nodes
subgraph = graph(sample,sample);
idx = find(sum(subgraph)==0);
if length(idx) > 0
    sample = setdiff(sample,sample(idx));
    subgraph = graph(sample,sample);
end

% approximate local eigenvector of transition matrix with largest eigenvalue
p = zeros(length(sample),1);
[~, ind] = intersect(sample,seed);
p(ind) = 1/length(ind);
p = p/norm(p);
p = sparse(p);

% Local spectral approximation
if true == strcmp(algosMode,'Lanczos');
    % Lanczos iteration
    kmax = 4;
    [v,~] = lanczos_Nrw(subgraph,p,kmax,1);
elseif true == strcmp(algosMode,'Power');
    % Power iteration
    kmax = 6;
    [v,~] = Power_iter(subgraph,p,kmax);
end

% bound detected community by local minimal conductance
% compute conductance
[~,I] = sort(v,'descend');
conductance = zeros(1,length(I));
for j = 1 : length(I)
    conductance(j) = getConductance(subgraph,I(1:j));
end

% compute first local minimal conductance
[~,I2] = intersect(I,ind);
startId = max(I2);
beta = 1.03;
index = GetLocalCond(conductance,startId,beta);
detectedComm = sample(I(1:index));

% compute F1 score
jointSet = intersect(detectedComm,comm{commId});
unionSet = union(detectedComm,comm{commId});
jointLen = length(jointSet);
unionLen = length(unionSet);

F1 = 2*jointLen/(length(detectedComm)+length(comm{commId}));
Jaccard = jointLen/unionLen;

% printing out result
fprintf('The detected community is')
disp(detectedComm')
fprintf('The F1 score and Jaccard index between detected community and ground truth community are %.3f and %.3f\n',F1,Jaccard)

% save out result
savePathandName = '../example/Amazon/output_LBSA.txt';
dlmwrite(savePathandName,'The detected community is','delimiter','');
dlmwrite(savePathandName,detectedComm','-append','delimiter','\t','precision','%.0f');
dlmwrite(savePathandName,['The F1 score and Jaccard index between detected community and ground truth community are ' num2str(F1,'%.3f') ' and ' num2str(Jaccard,'%.3f')],'-append','delimiter','');

end

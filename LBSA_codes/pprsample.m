function set = pprsample(graph,seeds,epsil,alpha)
% Sample subgraph by heat kernel diffusion

% use PageRank vector
pprvec = pprvec_mex(graph,seeds,epsil,alpha);
inds = pprvec(:,1);
vals = pprvec(:,2);

[~,I] = sort(vals,'descend');
set = inds(I);
set = union(seeds,set,'stable');

if length(set) > 5000
    set = set(1:5000);
end

function set = hksample(graph,seeds,t,epsil)
% Sample subgraph by heat kernel diffusion

% use heat kernel vector
hkvec = hkvec_mex(graph,seeds,t,epsil);
inds = hkvec(:,1);
vals = hkvec(:,2);

[~,I] = sort(vals,'descend');
set = inds(I);
set = union(seeds,set,'stable');

if length(set) > 5000
    set = set(1:5000);
end

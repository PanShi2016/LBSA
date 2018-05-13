function [v,lambda] = Power_iter(A,q1,kmax)
% Power iteration

n = length(q1);
v = q1;

for i = 1 : kmax
    v = A*v;
    [set,vec] = rwvec_mex(A,v);
    v = sparse(set,1,vec,n,1);
    v = v/norm(v);
end

v2 = A*v;
[set,vec] = rwvec_mex(A,v2);
v2 = sparse(set,1,vec,n,1);
lambda = v'*v2;

end

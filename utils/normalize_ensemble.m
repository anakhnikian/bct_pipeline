function [graphs_nrm] = normalize_ensemble(graphs, type)

%applies a normalization function to all matrices in a given tensor. The
%first two dimension contain the nodes.
%A. Nakhnikian, Apr-Nov 2023

graphs_nrm = zeros(size(graphs));
if ndims(graphs) == 3
    for ii = 1:size(graphs,3)
        graphs_nrm(:,:,ii) = get_normalized_matrix(squeeze(graphs(:,:,ii)),type);
    end
elseif ndims(graphs) == 4
    for ii = 1:size(graphs,3)
        for jj = 1:size(graphs,4)
            graphs_nrm(:,:,ii,jj) = get_normalized_matrix(squeeze(graphs(:,:,ii,jj)),type);
        end
    end
else
    error('Only rank 3 or 4 tensors are supported')
end
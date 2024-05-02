function [tensor_out] = mat_to_tensor(matrix,n_nodes)

%Converts a matrix of concatenated data (features in columns, observations
%in rows) to a nodes by nodes by individuals by features tensor

n_rows = (n_nodes^2-n_nodes)/2; %row length for all tensors
n_inds = size(matrix,1)/n_rows; %number of individuals in sample
n_features = size(matrix,2); %number of data features
mat_re = reshape(matrix,n_rows,n_inds,n_features);

%get output tensor
tensor = zeros(n_nodes,n_nodes-1,n_inds,n_features);  
for ind_idx = 1:n_inds
    k = 1;

    for row_idx = 1:n_nodes 
        for col_idx = 1:n_nodes
            if row_idx <= col_idx
                continue
            end
            tensor(row_idx,col_idx,ind_idx,:) = mat_re(k,ind_idx,:);
            k = k+1;
        end
    end
end
tensor(:,n_nodes,:,:) = zeros(n_nodes,n_inds,n_features);% add zeros for self-connection
tensor_out = tensor+permute(tensor,[2,1,3,4]); %make symmetric connectivity matrices
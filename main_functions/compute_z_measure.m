function [val_z] = compute_z_measure(func_handle, val, null_params, output_ind, opt_inputs, n_nodes,n_networks,n_factors)

%
%FUNCTION: Returns a list of results for a given graph theoretic measure
%and a binary flag that is 0 for local measures and 1 for global measures.
%Local or global properties are automatically determined by checking the
%function output for a representative network.
%
%INPUT: func_handle: A function handle
%
%       val: A array of non-standardized measures for z-score computation
%
%       output_ind: The output index for a BCT function
%
%       n_nodes: Number of network nodes
%
%       n_networks: The number of individuals in the data set
%
%       n_factors:  Number of within-subjects factor levels if defined
%
%OUTPUT: val_z: An array of z-score standardized measures
%
%
%A. Nakhnikian, Apr-Nov 2023

%get parameters and configure analysis
has_tensor      = isfield(null_params, 'tensor');
has_iterations  = isfield(null_params, 'n_iter');
has_func        = isfield(null_params, 'null_func');

if ~has_iterations
    disp('No iteration number given, defaulting to 1000')
    n_iter = 1000;
else
    n_iter = null_params.n_iter;
end

if has_tensor %default to pre-computed tensor when available
    null_data = null_params.tensor;
    if size(null_data,5)<n_iter
        error('N iterations > Number of null adjacency matrices in tensor')
    end
elseif ~has_tensor
    if ~has_func
        error('A tensor of null matrices or null matrix function must be provided')
    else
        null_func = null_params.null_func;
    end

end

%Sample or generate random adjacency matrices and apply measures
set(0,'DefaultTextInterpreter','none') %properly display progress bar
h = waitbar(0, ['Performing Randomizations for ',func2str(func_handle),'...']);
if has_tensor %predefined tensor
    rand_inds = randperm(n_iter); 
    null_vals = zeros([size(val),n_iter]);
    for iter_ind = 1:n_iter
        null_graphs = null_data(:,:,:,:,rand_inds(iter_ind));
        if ndims(null_vals) == 4 %local measures
            null_vals(:,:,:,iter_ind) = compute_measure(func_handle,...
                null_graphs, output_ind, opt_inputs, n_nodes, n_networks, n_factors);
        else %global measure
            null_vals(:,:,iter_ind) = compute_measure(func_handle,...
                null_graphs, output_ind, opt_inputs, n_nodes, n_networks, n_factors);
        end
        waitbar(iter_ind/n_iter,h)
    end
    close(h)
else %generate null matrices on the fly
    null_vals = zeros([size(val),n_iter]);
    for iter_ind = 1:n_iter
        null_graphs = mk_null_tensor(data, 1, null_func);
        if ndims(null_vals) == 4 %local measures
            null_vals(:,:,:,iter_ind) = compute_measure(func_handle,...
                null_graphs, output_ind, opt_inputs, n_nodes, n_networks, n_factors);
        else %global measure
            null_vals(:,:,iter_ind) = compute_measure(func_handle,...
                null_graphs, output_ind, opt_inputs, n_nodes, n_networks, n_factors);
        end
        waitbar(iter_ind/n_iter,h)
    end
    close(h)
end
set(0,'DefaultTextInterpreter','default') %reset interpreter

%get statistics
stats_dim = ndims(null_vals); %randomizations will always be in final dimension
null_mean = mean(null_vals,stats_dim);
null_dev = std(null_vals,[],stats_dim);

val_z = (val-null_mean)./null_dev;
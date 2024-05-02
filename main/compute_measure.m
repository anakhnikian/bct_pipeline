function [val,glb_flag] = compute_measure(func, graphs, output_ind, opt_inputs, n_nodes, n_networks, n_factors)
%
%FUNCTION: Returns a list of results for a given graph theoretic measure
%and a binary flag that is 0 for local measures and 1 for global measures.
%Local or global properties are automatically determined by checking the
%function output for a representative network.
%
%INPUT: func: A function handle
%
%       graphs: An array of networks (see get_network_measures)
%
%       output_ind: The output index for a BCT function
%
%       opt_inputs: Additional inputs to the BCT function if required, can
%       be empty
%
%       n_nodes: Number of network nodes
%
%       n_networks: The number of individuals in the data set
%
%       n_factors: Number of within-subjects factor levels if defined
%
%OUTPUT: Q: A matrix or rank 3 tensor with BCT function outputs. For global
%           measures has dims n_networks by n_factors. For local measures
%           this becomes n_nodes by n_networks by n_factor
%
%        glb_flag: binary flag. 1 if global, zero otherwise
%
%  Note: the last 3 inputs can be determined on the fly from the graphs variable.
%  However, they are passed as inputs to avoid redundancy 
%  because this function is written as a subroutine called by main function 
% "get_network_measures"
%
%A. Nakhnikian, Apr-Nov 2023

input_list = opt_inputs{:}; %concatenate optional inputs from cell

%assign global/local labels
n_out = nargout(func);
outputs = cell(1,n_out);
if isempty(input_list) %generate test value
    [outputs{:}] = func(squeeze(graphs(:,:,1,1)));
    test_val = outputs{output_ind};
else
    [outputs{:}] = func(squeeze(graphs(:,:,1,1)),input_list);
    test_val = outputs{output_ind};
end

%set glb_flag based on dims and presence of wi factor
%global conditions
glb_flag = 0;
if isscalar(test_val) %local measures cannot return scalar
    glb_flag = 1;
end


if glb_flag
    val = zeros(n_networks,n_factors);
    for net_ind = 1:n_networks
        for fact_ind = 1:n_factors
            W = squeeze(graphs(:,:,net_ind,fact_ind)); %get single adj mat
            outputs = cell(1,n_out);
            if isempty(input_list)
                [outputs{:}] = func(W);
            else
                [outputs{:}] = func(W, input_list);
            end
            val(net_ind,fact_ind) = outputs{output_ind};
        end
    end


else
    val = zeros(n_nodes,n_networks,n_factors);
    for net_ind = 1:n_networks
        for fact_ind = 1:n_factors
            W = squeeze(graphs(:,:,net_ind,fact_ind)); %get single adj mat
            outputs = cell(1,n_out);
            if isempty(input_list)
                [outputs{:}] = func(W);
            else
                [outputs{:}] = func(W, input_list);
            end
            val(:,net_ind,fact_ind) = outputs{output_ind};
        end
    end

end


function [null_tensor] = mk_null_tensor(graphs, n_rand, null_function)

%FUNCTION: generates a tensor of null matrices by applying the given
%function to the matrices stored in graphs. 
%
%INPUTS: 
% 
% graphs: a tensor where the first two dimensions are nodes with
% participants along the 3rd dim. An optional 4th dimension can store
% levels of a within-subjects factor
%
% n_rand: number of randomizations to perform. Should be at least equal to
% the number of iterations desired for z scores, preferably higher
%
% null_function: a randomization function from the BCT
%
%OUTPUT: A large tensor containing the desired number of random networks
%
%NOTE: This program can generate large (>2 GB) variables. Make sure you
%have enough RAM or the program might hang in virtual memory
%
%A. Nakhnikian, Apr-Nov 2023

func = str2func(null_function);
n_participants = size(graphs,3);
n_factors = size(graphs,4); %will be 1 if there is no WI factor
null_tensor = zeros([size(graphs),n_rand]);


parfor participant_ind = 1:n_participants
    for comp_ind = 1:n_factors
        mat_temp = squeeze(graphs(:,:,participant_ind,comp_ind));
        for rand_ind = 1:n_rand
            null_tensor(:,:,participant_ind,comp_ind,rand_ind) = func(mat_temp);
        end
    end
end

null_tensor = squeeze(null_tensor); %remove singleton dims if no WI factor
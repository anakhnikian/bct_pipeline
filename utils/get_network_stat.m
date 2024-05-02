function [tensor_out] = get_network_stat(tensor,statistic)

%Reduces a rank 3 or 4 tensor with multiple individual network matrices on
%the 3rd dim to single matrix (rank 3 input) or tensor with submatrices in
%the 3rd dim (rank 4 input) by computing an ensemble statistic. Ensemble
%type is determined by "statistic"
%
%INPUT: 
%   tensor: a collection of network matrices
%
%   statistic:
%       mean -> arithmetic average
%       std  -> standard deviation
%       sem  -> standard error of the mean
%
%OUTPUT: tensor_out: an array of network statistics

switch statistic
    case'mean'
        tensor_out = squeeze(mean(tensor,3));
    case 'std'
        tensor_out = squeeze(std(tensor,[],3));
    case 'sem'
        tensor_out = squeeze(std(tensor,[],3))./sqrt(size(tensor,3));
    otherwise
        error('Supported stats are mean, std, and sem')
end
function [mat_norm] = get_normalized_matrix(graph,type, sig_exp)



%load diagonals for getting minimum. random graphs w/o self-connection are
%a.s. nonzero (off-diagonal) but zeros can occur from prior
%modifications such as threholding
graph_loaded = graph+2*max(graph)*eye(size(graph)); 
max_val = max(graph(:));
min_val = min(graph_loaded(:)); %use diagonal loading to avoid zeros on diagonals

%normalize matrices
switch type
    case 'minmax' %raw -> [0,1], must return at least one true zero
        mat_norm = (graph-min_val)/(max_val-min_val);
    case 'max' %max->1, only returns 0 if in raw data
        mat_norm = graph./max_val;
    case 'logistic' %raw->(0,1), squashes extreme values depending on rate
        if isempty(sig_exp) || ~exist(sig_exp,'variable') %default rate param is one
            mat_norm = (1-exp(graph))^-1;
        else
            mat_norm = (1-exp(graph)^-sig_exp)^-1;
        end
    otherwise
        error('Supported methods are minmax, max, and logistic')
end
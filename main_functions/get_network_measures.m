function [struct] = get_network_measures(graphs,measures,options)

% FUNCTION: Computes a selection of measures on a collection of
% networks(see "graphs") with optional z-score comparisons based on
% approripate null_networks. All inputs except graphs and measures are
% optional
%
%
% See end of preamble for an example of use.
%
%
% INPUTS:
%
%------------------------Graphs: Network Arrays----------------------------
% graphs is a rank 3 or 4 tensor containing binary or weighted
% adjacency matrices. First two dims must be nodes by nodes. Others are
% abitrary
%
%   Cases:
%       Rank 3: Multiple graphs, i.e. one for each individual in a study
%
%       Rank 4: Multiple graphs with a within-subjects factor, such as
%       latent variable, principal component, or frequency band
%
% The order of dimensions is assumed to be nodes by nodes by BT factor by WI
% factor. Current implementation does not support more than one factor for
% WI designs.
%
%------------------------Measures: Graph Theoretic Computation------------
% Measures is cell array with a row for each measure, with 4 mandatory
% columns and an optional 5th column.
%
% Column 1: A list of measures to call from the BCT.
%
% Column 2; A list of corresponding measure names, these will be the field
% names for the structure.
%
% Column 3: Additional inputs to the corresponding BCT function. These can
% be empty, vectors, or cell array. 
%
% Column 4: A binary vector. 1 will return a null standardized z score along
% with the raw value. 0 will return only raw values
%
% Column 5: Defined explicitly if any of the BCT functions called return more
% than one output and it is necessary to specify which one to save. If not
% user defined defaults to all ones
%
%   Example: Compute eigenvector centrality, weighted measures of
%   assortativity, transitivity, modularity, and efficiency with null_standardized
%   values for all measures except centrality
%
%   measures(:,1) = {'eigenvector_centrality_und','assortativity_wei','transitivity_wu','modularity_und','efficiency_wei'}
%   measures(:,2) = {'ev_centrality','assortativity','transitivity','modularity','efficiency'}
%   measures(:,3) = {[],0,[],1,[]}
%   measures(:,4) = {0, 1, 1, 1,1}
%   measures(:,5) = {1,1,1,2,1} %return the second output from [Ci,Q]=modularity_und
%
% measures =
%
%   5×5 cell array
%
%     {'eigenvector_cent…'}    {'ev_centrality'}    {0×0 double}    {[0]}    {0×0 double}
%     {'assortativity_wei'}    {'assortativity'}    {[       0]}    {[1]}    {0×0 double}
%     {'transitivity_wu'  }    {'transitivity' }    {0×0 double}    {[1]}    {0×0 double}
%     {'modularity_und'   }    {'modularity'   }    {[       1]}    {[1]}    {[       2]}
%     {'efficiency_wei'   }    {'efficiency'   }    {0×0 double}    {[1]}    {0×0 double}
%
% Note: Function repitition is permited. For example, to get both Ci and Q
% from modularity_und (w/o null comparisons) use:
%       measures(k,:) = {'modularity_und', 'community vector', 1, 0, 1}
%       measures(k+1,:) = {'modularity_und', 'modularity', 1, 0, 2}
% In both cases, partition resolution is set to the default value (1) and 
% null network comparisons are not generated. The last entry in each row
% specifies whether to save the first or second variable returned by 
% [Ci,Q]=modularity_und
%
%
%----------------------Options-----------------------------
% All options can be entered as key value pairs or a single data structure
% with fields for each argument
%
% NULL NETWORK PARAMETERS
% if the number of iterations is unspecified defaults to raw values only
%
%   null_tensor: A precomputed rank 5 tensor of random matices
%   (see mk_null_tensor)
%
%   null_iterations: number of iterations for generating z scores
%
%   null_func: function to be used to generate random matrices on the fly
%   if a precomputed tensor is not provided
%
%   Examples
%       -precomputed matrices:
%       null_iterations = 1000;
%       null_tenso = X; %X is output of mk_null_tensor
%
%       -generate null matrices as need
%       null_iterations = 5000;
%       null_func = 'null_model_und_sign'
%
%   If tensor and null_func are both present the pre-computed matrices are
%   used by defualt and null_func is ignored.
%
%  GROUPING PARAMETERS
%
%   groups_names: A cell array with group names. Length must equal the
%                 number of unique entries in groups. If not defined the defualt labels are
%                 the numeric assignments
%
%   groups:       A vector with integer assignment values for each
%                 individual
%
%
% WITHIN-SUBJECTS PARAMETERS
%
%   wi_name:       Within-subjects factor name
%   wi_levels:     Level labels 
%
%
% OUTPUT:
%
% A data structure with fields:
%
%       measures: all measures for an analysis
%            |
%             ------- name: i.e. clustering, centrality, etc
%               |
%                -----raw: un-standardized measures
%               |
%                ----type: global (whole network) or local (node-level)
%               |
%                ----z_score: z standardized measures
%
%       wi_factor: within subjects factor (optional)
%            |
%             ------- name: i.e Factor, Freqeuncy Band, etc
%            |
%             ------- levels: names for individual factor levels
%
%       Group: between subjects factor (optional)
%            |
%             ------- names: Label for each data set
%            |
%             ------- vect: numeric mask vector
%
%------------------------------Example----------------------------------
%
%   USE: Get measures for a study comparing 30 healthy controls to 30
%   matched patients with schizophrenia where the within subjects factor is
%   coherence bands
%
% ---REQUIRED INPUTS
%
%   load('path_to_network_data') %get network data
%
%   %select measures of interest
%   measures(:,1) = {'eigenvector_centrality_und','assortativity_wei','transitivity_wu','modularity_und','efficiency_wei'};
%   measures(:,2) = {'ev_centrality','assortativity','transitivity','modularity','efficiency'};
%   measures(:,3) = {[],0,[],1,[]}; %set assort to und and modu to gamma = 1 (see BCT functions)
%   measures(:,4) = {0, 1, 1, 1,1} ;
%   measures(:,5) = {1,1,1,2,1}; %return the second output from [Ci,Q]=modularity_und
%
% ---DEFINE OPTIONS AS KEY VALUE PAIRS OR A STRUCTURE
%
%   *Key value pairs*
%
%   group_names = {'HC','SZ'};
%
%   groups = [ones(1,30),2*ones(1,30)];
%
%   wi_name = 'Frequency Band';
%
%   wi_levels = {'Gamma','Alpha 1', 'Alpha 2', 'Alpha 3', 'Beta','Low Gamma'}
%
%   null_iterations = 1000;
%
%   [null_tensor] = mk_null_tensor(graphs, null_iterations, 'null_model_und_sign')
%
%   [struct] = get_network_measures(graphs,measures,'group_names',group_names,...
%       'null_tensor',null_tensor,'wi_name', wi_name, 'wi_levels', wi_levels, 'null_iterations', null_iterations);
%
%   *Option structure*
%
%   options.group_names = {'HC','SZ'};
%
%   options.groups = [ones(1,30),2*ones(1,30)];
%
%   options.wi_name = 'Frequency Band';
%
%   options.wi_levels = {'Gamma','Alpha 1', 'Alpha 2', 'Alpha 3', 'Beta','Low Gamma'};
%
%   options.null_iterations = 1000;
%
%   [null_tensor] = mk_null_tensor(graphs, null_iterations, 'null_model_und_sign');
%
%   options.null_tensor = null_tensor;
%
%   [struct] = get_network_measures(graphs,measures,'group_names',group_names,...
%       'null_tensor',null_tensor,'wi_name', wi_name, 'wi_levels', wi_levels, 'null_iterations', null_iterations);
%
%A. Nakhnikian, Apr-Nov 2023



%   DEV NOTES: 
% 
% Add functionality to support more than one WI factor
%
% Handling multiple instances of the same measure is a hack.
% The code will be more efficient with minimal calls to subroutines.
% Rework data wrangling in update to allow multiple outputs to be
% returned from one call.

%Declare defaults
arguments
    graphs
    measures
    options.null_tensor                     = []
    options.null_iterations                 = 0
    options.groups                          = []
    options.group_names                     = []
    options.wi_name                         = []
    options.wi_levels                       = []
    options.null_func                       = []
end

%check input------------------------------------
%Get analysis setup
grp_flag = ~isempty(options.groups);
wi_flag = ~isempty(options.wi_name);
null_flag = options.null_iterations > 0;
%Add 5th measure column if needed
if size(measures,2) == 4
    measures(:,5) = repmat({1},size(measures,1),1);
end
%Check group parameters
if isempty(options.groups) && ~isempty(options.group_names)
    error('Group names are defined but no grouping vector is provided')
end
%Group assignments
if grp_flag
    if isempty(options.group_names)
        numeric_labels = unique(options.groups);
        group_names = num2cell(numeric_labels);
    else
        group_names = options.group_names;
    end
end

%check within subjects factor
if wi_flag
    if isempty(options.wi_levels)
        wi_levels = cell(num2str(1:size(tensor,4))); %numeric labels on levels
    else
        wi_levels = options.wi_levels;
    end
end
%set null params
if null_flag
    null_params.n_iter = options.null_iterations;
    if ~isempty(options.null_tensor)
        null_params.tensor = options.null_tensor;
    else
        null_params.tensor = [];
    end
end
%end check intput------------------------------------


%get data and analysis parameters------------------------------------
n_nodes     = size(graphs,1); %network nodes
n_networks  = size(graphs,3); %individual networks
n_factors   = size(graphs,4); %within subjects factors
%extract function handles, field names, and options from measure list
func_list   = measures(:,1);
func_names  = measures(:,2);
func_opts   = measures(:,3);

%end get data and analysis parameters-------------------------------



%get network measures and build structure-------------------------------
%assign group labels if defined
if grp_flag
    struct.group.vect = options.groups;
    for net_ind = 1:n_networks
        struct.group(net_ind).names = group_names(options.groups(net_ind));
    end
end
%assign wi_labels if defined
if wi_flag
    struct.wi_factor.name   = options.wi_name;
    struct.wi_factor.levels = wi_levels;
end
%Loop through measures
n_measures = size(measures,1);
for func_ind = 1:n_measures
    func_handle = str2func(string(func_list{func_ind})); %handle for current function
    opt_inputs = func_opts(func_ind); %options for current handle

    %get measure and assign to structure
    output_ind = measures{func_ind,5};
    [val,glb_flag] = compute_measure(func_handle, graphs, output_ind, opt_inputs, n_nodes, n_networks,n_factors);
    struct.measures.(func_names{func_ind}).raw = val;
    if glb_flag
        struct.measures.(func_names{func_ind}).type = 'global';
    else
        struct.measures.(func_names{func_ind}).type = 'local';
    end
    %add null-standardized measures if requested
    if null_flag && measures{func_ind,4}
        val_z = compute_z_measure(func_handle, val, null_params, output_ind, opt_inputs, n_nodes,n_networks, n_factors);
        struct.measures.(func_names{func_ind}).z_score = val_z;
    end

end
%end get network measures and build structure-------------------------------


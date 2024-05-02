# Brain Connectivity Pipeline

## Overview
This software is designed to streamline analysis using the brain connectivity toolbox (BCT). It consists of functions for performing the major steps of connectivity analysis - measure estimation, network normalization/standardization, null network comparisons - efficiently for a variety of experimental designs. 

The core variables to be passed to the main function are a tensor containing all the connectivity matrices to be analyzed along with a table detailing which BCT functions to apply. Options to specify additional input and output parameters for each function are available. The primary output is a data structure with specified measures stored as fields. See the documentation of the main function, get_network_measures, for details.

The purpose of this pipeline is to provide users with a set of "wrappers" that largely automate the analysis process and handle variable passing using pre-written code. Advanced users may modify and redistribute the code freely. 

The current implementation supports an arbitrary number of groups (between subjects factors) and a single within subjects factor with arbitrarily many levels.

## Installation
Download the files in this repo. Make sure they and the BCT (https://sites.google.com/site/bctnet/) are both on your Matlab path.

## Brain Connectivity Toolbox (BCT)

The Brain Connectivity Toolbox (brain-connectivity-toolbox.net) is a MATLAB toolbox for complex-network analysis of structural and functional brain-connectivity data sets.

#### Reference and citation
Complex network measures of brain connectivity: Uses and interpretations.
Rubinov M, Sporns O (2010) NeuroImage 52:1059-69. 

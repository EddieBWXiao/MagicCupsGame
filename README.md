# MagicCupsGame
Part of the CamRAA project. Documentation for MATLAB functions and a pipeline in R for parameter estimation and statistical analysis on data from the Magic Cups Game (an adaptation of the information bias learning task, from Pulcu & Browning, 2017 eLife)

MCG_Thesis_Section5_analysis.Rmd includes functions for the statistical models and follow-up tests

**Simulate participant behaviour**
Functions beginning with simu_
Produce choices based on block-specific parameter values and outcome sequences, for each behavioural model

** Estimate parameters for each behavioural model**
Functions beginning with gridsearch_
Given choice data from each block, and the outcome sequence, obtain the full posterior for each parameter, as well as the mean of the marginalised distribution of each parameter; also includes code for calculating the Bayesian Information Criteria
Modified from code provided in https://osf.io/k36h4/; the code on which the RW2lrbetabias model was based on was written by Dr Michael Browning and modified by Dr Margot Overman (License: CC-By Attribution 4.0 International). Further modifications were then made to enable parameter estimation for other behavioural models.

**Model-agnostic measures **
Functions beginning with calc_
Calculates the model-agnostic metric indicated in file name, with input being the choice of a specific participant on a specific block, and the outcome sequence from that block.

**Folders:**
PL_simulations: for code simulating tasks with only one outcome type (simple reinforcement learning tasks, for building simple Rescorla-Wagner models)
Goris2020TestAnalysis: code for exploratoration on Goris, J., Silvetti, M., Verguts, T., Wiersema, J. R., Brass, M., & Braem, S. (2020). Autistic traits are related to worse performance in a volatile reward learning task despite adaptive learning rates. Autism, 1362361320962237. https://doi.org/10.1177/1362361320962237
VisualHelperFunctions: custom plotting function stored for future reference


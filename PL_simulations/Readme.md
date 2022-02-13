# PL_simulations

Repository for simulations and model fitting scripts for simple probabilistic learning tasks

To explore the pipeline and the role of each function, see:

**single_ptp_demo.m**: a demo for 1) running a single simulation and 2) perform model fitting for the virtual participant generated

**compare_PL_RW1lrs_1**: script for exploring how WSLS/accuracy/task earning are influenced by learning rate and inverse temperature for a simple Rescorla-Wagner (RW) learning model with Softmax action selection, under different task structures (e.g., stable versus volatile). Also touches on comparing between RW model with or without updating the value of the unchosen option.



*To add:*

Demo for explaining different model fitting procedures available + parameter recovery

Other functions:

response_model_illu: produce plots explaining how inverse temperature and lapse rate influences the relationship between expected values and probability of choice

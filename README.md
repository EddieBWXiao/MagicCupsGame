# MagicCupsGame
Includes: data preprocessing (extraction from spreadsheet in excel), quality control measures, and basic data analysis. A separate fol

Parse_MagicCups: convert .csv output from Gorilla to information about choice & task structure (for one participant)

sim_average_RW2lr_fixed: for a given combination of parameter values, produce average performance on Magic Cups Game. Fixed = no randomisation of feedback within the same fixed task structure, which is the design used for the Magic Cups Game.

gen_: a series of functions able to produce struct variable containing a task design, with contingencies specified in input, and trial-wise outcomes generated randomly with each implementation.

PL_simulations: for code simulating tasks with only one outcome type (simple reinforcement learning tasks, for building simple Rescorla-Wagner models)

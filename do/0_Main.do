/*
Note: 

The do files involved are cited from by Yaxi and by Siyu

*/

clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 30000
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************
//NOTE FOR WINDOWS USERS : use "\" instead of "/" in your paths
global root "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS" 					// adjust 

* Define path for data sources
global SOURCE "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/raw"

* Define path for general output data: 
global OUT "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output"

* Define path for output data with covariants
global COV "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output"

* Define path for intermediate data
global INT "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/intermediate"

* Define path for do-files
global DO "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/do"

******************************
*** Do do files ***
******************************
do "${DO}/1_generate_baseline_covariants.do"
do "${DO}/2_append.do"
do "${DO}/3_death cleaning.do"
do "${DO}/5_weight.do"
do "${DO}/4_generate_followup7w_covariants.do"
do "${DO}/6_label.do"
do "${DO}/7_community.do"
do "${DO}/8_analyses.do"

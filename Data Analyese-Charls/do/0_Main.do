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
global raw "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyese-Charls/raw"

* Define path for general output data: 
global out "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyese-Charls/out"

* Define path for output data with covariants
global output "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyese-Charls/output"

* Define path for intermediate data
global int "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyese-Charls/int"

* Define path for do-files
global do "${root}/P24 End-of-life care expenditure patterns and causes of death/Data Analyese-Charls/do"

******************************
*** Do do files ***
******************************

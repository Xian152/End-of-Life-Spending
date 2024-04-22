
use "${OUT}/dat98_death.dta",clear
	append using "${OUT}/dat00_death.dta" "${OUT}/dat02_death.dta" "${OUT}/dat05_death.dta"  "${OUT}/dat08_death.dta" "${OUT}/dat11_death.dta" "${OUT}/dat14_death.dta"
	
		* rename "_f1" to "_1", "_f2" to "_2", "_f3" to "_3", etc. 
		foreach k in 1 2 3 4 5 6 7 {
			foreach var of varlist *_f`k'{
				local b = subinstr("`var'","_f`k'","",.)
				ren `b'_f`k' `b'_`k'
			}
		}		
	
****check the distribution 
//Dmarry_ Dlivarr_ Durban_ Dprov_ Dhavedoc_ Dhavedoclic_ Dhhsize_ Dincomeperca_ Dlogincomeperca_  Dmedexp12m_ Dpayerhexp_ Dplace_ Dcause_ Dcargiv_ Dbedri_ Dbedday_ Dhypert_ Ddiabet_ Dheart_ Dcvd_ Dpneum_ Dtuberc_ Dglauco_ Dprosta_ Dgastri_ Dparkin_ Dbedsor_ Ddement_ Dpsycho_ Dneuros_ Darthri_ Dothers_ Dbathing_ Ddressing_ Dtoileting_ Dtransferring_ Dcontinence_ Dfeeding_ Dsmkl_ Dalcohol_ Ddril_ Dhhgener_ Dpayercare_ DOOPhexp_ Dcarehexp_ DcarehexpM_ DcaredayM_ Dcaredayneede_ Dincometot_ Dlogincometot_

cls	
	foreach follow in 1 2 3 4 5 6 7{
		foreach k in Dmarry_{     //change
			tab `k'`follow'  
		}
	}

//<0 8 9 88 99 888 999


***从数据里找到对应的变量 加label
	*以下是寻找label的流程，实质上不需要写出来的
	use "${OUT}/dat98_death.dta",clear
		lookfor marry 
	/*

	Variable      Storage   Display    Value
		name         type    format    label      Variable label
	---------------------------------------------------------------------------------------------------------------------------------------
	d0marry         byte    %8.0f      labels791
												  marital status of the deceased elder at death
	d2marry         byte    %8.0f      labels1237
												  marital status of the deceased elder at death
	d5marry         byte    %8.0f      labels2010
												  marital status of the deceased elder at death
	d8marry         byte    %8.0f      labels2838
												  marital status of the deceased elder at death
	d11marry        byte    %8.0f      labels3806
												  marital status of the deceased elder prior to death
	d11marry1       byte    %8.0f      labels3807
												  did the elder have a cohabiting partner but not officially married?
	d14marry        byte    %8.0f      labels4836
												  marital status of the deceased elder prior to death
	d14marry1       byte    %8.0f      labels4837
												  did the elder have a cohabiting partner but not officially married?
	d18marry        byte    %8.0f      labels5636
												  marital status of the deceased elder prior to death
	d18marry1       byte    %8.0f      labels5637
												  did the elder have a cohabiting partner but not officially married?
	*/
	tab d0marry
	codebook d0marry if d0marry>0
	/*
	---------------------------------------------------------------------------------------------------------------------------------------
	d0marry                                                                                   marital status of the deceased elder at death
	---------------------------------------------------------------------------------------------------------------------------------------

					  Type: Numeric (byte)
					 Label: labels791

					 Range: [1,9]                         Units: 1
			 Unique values: 6                         Missing .: 0/3,368

				Tabulation: Freq.   Numeric  Label
							  263         1  married and living with spouse
							   24         2  married but separate with
											 spouse
							   17         3  divorced
							3,020         4  widowed
							   27         5  never married
							   17         9  missing
	*/
	*以下才是真正生成label的流程，注意数据库
	use "${OUT}/dat98_death.dta",clear
		append using "${OUT}/dat00_death.dta" "${OUT}/dat02_death.dta" "${OUT}/dat05_death.dta"  "${OUT}/dat08_death.dta" "${OUT}/dat11_death.dta" "${OUT}/dat14_death.dta"
	label define marry 1"married and living with spouse" 2"married but separate with" 3"divorced" 4"widowed" 5"never married"
	label values Dmarry_*  marry
	tab Dmarry_f1 //最后tab确认



*** 找18年对应的变量
use "${OUT}/dat98_death.dta",clear
	keep d18* 
	
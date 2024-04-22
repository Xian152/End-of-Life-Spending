*****************************************************************
*************** 1. Data Cleaning ********
*****************************************************************'
**********************Recode for weight change only: won't harm the common generation process***********
foreach year in 98 00 02 05 08 11 14 { //
use "${SOURCE}/dat`year'_18F.dta",clear	
	* first wave
	gen a = .
	replace a = 0 if `year' == 98
	replace a = 2 if `year' == 00
	replace a = 5 if `year' == 02
	replace a = 8 if `year' == 05
	replace a = 11 if `year' == 08
	replace a = 14 if `year' == 11
	replace a = 18 if `year' == 14
	
	local i1 = a
	
	* second wave
	gen b = .
	replace b = 2 if `year' == 98
	replace b = 5 if `year' == 00
	replace b = 8 if `year' == 02
	replace b = 11 if `year' == 05
	replace b = 14 if `year' == 08
	replace b = 18 if `year' == 11

	local i2 = b

	* Third wave
	gen c = .
	replace c = 5 if `year' == 98
	replace c = 8 if `year' == 00
	replace c = 11 if `year' == 02
	replace c = 14 if `year' == 05
	replace c = 18 if `year' == 08
	
	local i3 = c
	
	* Forth wave
	gen d = .
	replace d = 8 if `year' == 98
	replace d = 11 if `year' == 00
	replace d = 14 if `year' == 02
	replace d = 18 if `year' == 05

	local i4 = d

	* Fifth wave
	gen e = .
	replace e = 11 if `year' == 98
	replace e = 14 if `year' == 00
	replace e = 18 if `year' == 02

	local i5 = e
	
	* Sixth wave
	gen f = .
	replace f = 14 if `year' == 98
	replace f = 18 if `year' == 00

	local i6 = f
	
	* Seventh wave
	gen g = .
	replace g = 18 if `year' == 98

	local i7 = g	
	
	
	*setup for loop
	gen wave_alt =7 if wave ==98
	replace wave_alt =6 if wave ==0
	replace wave_alt =5 if wave ==2
	replace wave_alt =4 if wave ==5
	replace wave_alt =3 if wave ==8
	replace wave_alt =2 if wave ==11
	replace wave_alt =1 if wave ==14
		
********************** deal with string in d14 ******************
	if inlist(wave_alt,2,3,4,5,6,7){
			foreach var in d14income d14wpayot d14fullda d14medcos d14pcgday d14bedday d14drkmch d14pocket d14carcst{
				replace `var' = "" if !regexm(`var',"^[0-9]*$")		
			}
		destring d14*,replace
	}	
	
	
********************** socialecon ******************
	* married
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dmarry_f`z'=d`i`z''marry if dth`i`z'' == 1  & !inlist(d`i`z''marry,8,9) 
		}		
	}	
	* living arrangement 
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dlivarr_f`z'=d`i`z''livarr if dth`i`z'' == 1  & !inlist(d`i`z''livarr,8,9) 
		}		
	}	

	* place of residence of death
	if inlist(wave_alt,3,4,5,6,7){
		local am = wave_alt-2
		forvalues z = 1/`am'{
			generate Durban_f`z'=d`i`z''resid  if dth`i`z'' == 1 & !inlist(d`i`z''resid,8,9) 
		}
	}			
	
	* place of province
	if inlist(wave_alt,6,7){
		local am = wave_alt-5
		forvalues z = 1/`am'{
			cap ren d2provin d2provid
			generate Dprov_f`z'=d`i`z''provid  if dth`i`z'' == 1 
		}		
	}			

********************** health institute ******************
	* doctor
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dhavedoc_f`z'=d`i`z''doctor if dth`i`z'' == 1  & !inlist(d`i`z''doctor,-1,8,9) 
		}		
	}	
	* doctor with licence 
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dhavedoclic_f`z'=d`i`z''licdoc if dth`i`z'' == 1  & !inlist(d`i`z''licdoc,-1,8,9) 
		}		
	}		

********************** finance & hh condition******************		
	* hhsize
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt-1
		forvalues z = 1/`am'{
			gen Dhhsize_f`z'=d`i`z''person if dth`i`z'' == 1  & !inlist(d`i`z''person,-1,0,88,98,99,888) 
		}		
	}		

	* hhgener
	if inlist(wave_alt,2,3,4,5,6){
		local am = wave_alt-1
		forvalues z = 1/`am'{
			gen Dhhgener_f`z'=d`i`z''gener if dth`i`z'' == 1  & !inlist(d`i`z''gener,-1,8,9,888) 
		}		
	}	
	if inlist(wave_alt,7){
		local am = wave_alt-1
		forvalues z = 2/`am'{
			gen Dhhgener_f`z'=d`i`z''gener if dth`i`z'' == 1  & !inlist(d`i`z''gener,-1,8,9,888) 
		}		
	}	
	
	* income
	if inlist(wave_alt,4,5,6,7){
		local am = wave_alt-3
		forvalues z = 1/`am'{
			generate Dincomeperca_f`z'=d`i`z''income  if dth`i`z'' == 1 & !inlist(d`i`z''income,88888,99999)
			replace Dincomeperca_f`z' =100000  if d`i`z''income == 99998
			generate Dlogincomeperca_f`z'=log(Dincomeperca_f`z')  
		}		
	}	
	
	if inlist(wave_alt,4,5,6,7){
		local am = wave_alt
		local am2 = wave_alt - 2
		forvalues z = `am2'/`am'{	
			generate Dincometot_f`z'=d`i`z''income  if dth`i`z'' == 1 & !inlist(d`i`z''income,99,888,88888,99999) 
			replace Dincometot_f`z'=100000  if d`i`z''income == 99998
			generate Dlogincometot_f`z'=log(Dincometot_f`z')  
		}		
	}

	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			generate Dincometot_f`z'=d`i`z''income  if dth`i`z'' == 1 & !inlist(d`i`z''income,99,888,88888,99999) 
			replace Dincometot_f`z'=100000  if d`i`z''income == 99998
			generate Dlogincometot_f`z'=log(Dincometot_f`z')  
		}		
	}		

	* Insurance
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			cap ren d11insur d11d22
			ren d`i`z''d22 insuranceRetire_f`z'
		}		
	}	
	
	if inlist(wave_alt,4,5,6,7){
		local am1 = wave_alt -2
		local am2 = wave_alt
		forvalues z = `am1'/`am2'{
			cap ren d11insur d11d22
			ren d`i`z''d22 insuranceRetire_f`z'
		}		
	}	
	
	* retirement
	if inlist(wave_alt,2,3,4,5,6,7){
		local am = wave_alt-1
		foreach z in `am'{
			recode d`i`z''retire (-9/-1 9 = .) (1 2 = 1 "Yes") (3= 0 "No" ),gen(retiredWPension_f`z') label("retired_f`z'")
			recode d`i`z''retyr (9999 8888 -9/-1= .),gen(retiredYear_f`z')
			destring d`i`z''retpen ,replace
			recode d`i`z''retpen (9999 8888 -9/-1= .),gen(pensionYearly_f`z')
			replace pensionYearly_f`z' = pensionYearly_f`z'*12  // 居然有0 怎么办？
		
		}		
	}	
	
********************** death cost & care ******************
	* medicine cost
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dmedexp12m_f`z'=d`i`z''medcos if dth`i`z'' == 1  & !inlist(d`i`z''medcos,888,88888,99999) 
			replace Dmedexp12m_f`z'=100000  if d`i`z''medcos = 99998
			
		}		
	}		

	* OOP
	if inlist(wave_alt,4,5,6,7){
		local am1 = wave_alt-3
		local am2 = wave_alt
		forvalues z = `am1'/`am2'{
			gen DOOPhexp_f`z'=d`i`z''pocket if dth`i`z'' == 1  & !inlist(d`i`z''pocket,88888,99999) 
			replace DOOPhexp_f`z'=100000  if d`i`z''pocket = 99998		
		}		
	}	
	if inlist(wave_alt,1,2,3){
		local am2 = wave_alt
		forvalues z = 	1/`am2'{
			gen DOOPhexp_f`z'=d`i`z''pocket if dth`i`z'' == 1  & !inlist(d`i`z''pocket,88888,99999) 
			replace DOOPhexp_f`z'=100000  if d`i`z''pocket = 99998		
		}		
	}		
	* daily care fee
	if inlist(wave_alt,4,5,6,7){
		local am1 = wave_alt-3
		local am2 = wave_alt
		forvalues z = `am1'/`am2'{
			gen DcarehexpD_f`z'=d`i`z''carcst if dth`i`z'' == 1  & !inlist(d`i`z''carcst,88888,99999) 
			replace DcarehexpD_f`z'=100000  if d`i`z''carcst = 99998		
		}		
	}	
	if inlist(wave_alt,1,2,3){
		local am2 = wave_alt
		forvalues z = 1/`am2'{
			gen DcarehexpD_f`z'=d`i`z''carcst if dth`i`z'' == 1  & !inlist(d`i`z''carcst,88888,99999) 
			replace DcarehexpD_f`z'=100000  if d`i`z''carcst = 99998		
		}		
	}	
	
	* payer for health exp
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dpayerhexp_f`z'=d`i`z''whopay if dth`i`z'' == 1  & !inlist(d`i`z''whopay,88,98,99) 
		}		
	}	

	* payer for care services
	if inlist(wave_alt,6,7){
		local am = wave_alt
		local am1 = wave_alt-4
		forvalues z =`am1' /`am'{
			gen Dpayercare_f`z'=d`i`z''carpay if dth`i`z'' == 1  & !inlist(d`i`z''carpay,88,98,99) 
		}		
	}	
	
	if inlist(wave_alt,1,2,3,4,5){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dpayercare_f`z'=d`i`z''carpay if dth`i`z'' == 1  & !inlist(d`i`z''carpay,88,98,99) 
		}		
	}		
	
	* monthly direct care fee
	if inlist(wave_alt,4,5,6,7){
		local am1 = wave_alt-3
		local am2 = wave_alt
		forvalues z = `am1'/`am2'{
			gen DcarehexpM_f`z'=d`i`z''dircst if dth`i`z'' == 1  & !inlist(d`i`z''dircst,888,88888,99999) 
			replace DcarehexpM_f`z'=100000  if d`i`z''dircst = 99998		

		}		
	}	
	if inlist(wave_alt,1,2,3){
		local am2 = wave_alt
		forvalues z = 1/`am2'{
			gen DcarehexpM_f`z'=d`i`z''dircst if dth`i`z'' == 1  & !inlist(d`i`z''dircst,888,88888,99999) 		
			replace DcarehexpM_f`z'=100000  if d`i`z''dircst = 99998		

		}		
	}
	
	* monthly care daies given
	if inlist(wave_alt,4,5,6,7){
		local am1 = wave_alt-3
		local am2 = wave_alt
		forvalues z = `am1'/`am2'{
			gen DcaredayM_f`z'=d`i`z''pcgday if dth`i`z'' == 1  & !inlist(d`i`z''pcgday,88,99,98) 
		}		
	}	
	if inlist(wave_alt,1,2,3){
		local am2 = wave_alt
		forvalues z = 1/`am2'{
			gen DcaredayM_f`z'=d`i`z''pcgday if dth`i`z'' == 1  & !inlist(d`i`z''pcgday,88,99,98)  
		}		
	}	
	
	* care daies required
	if inlist(wave_alt,4,5,6,7){
		local am1 = wave_alt-3
		local am2 = wave_alt
		forvalues z = `am1'/`am2'{
			//cap replace d14fullda = ""  if d14fullda >"365" & d14fullda<"4015"
			//destring d14fullda,replace
			gen Dcaredayneede_f`z'=d`i`z''fullda if dth`i`z'' == 1  & !inlist(d`i`z''fullda,88,98,99,8888,9999) 
			replace Dcaredayneede_f`z'=10000  if d`i`z''fullda = 9998		
			
		}		
	}			
	if inlist(wave_alt,1,2,3){
		local am2 = wave_alt
		forvalues z = 1/`am2'{
			//cap replace d14fullda = ""  if d14fullda >"365" & d14fullda<"4015"
			//destring d14fullda,replace
			gen Dcaredayneede_f`z'=d`i`z''fullda if dth`i`z'' == 1  & !inlist(d`i`z''fullda,88,98,99) 
		}		
	}		
********************** deathrelated ***********
	* place of death
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dplace_f`z'=d`i`z''dplace if dth`i`z'' == 1  & !inlist(d`i`z''dplace,8,9) 
		}		
	}		

	* cause of death
	if inlist(wave_alt,5,6,7){
		local am = wave_alt-4
		forvalues z = 1/`am'{
			gen Dcause_f`z'=d`i`z''cause if dth`i`z'' == 1  & !inlist(d`i`z''cause,66,88,99) 
		}		
	}		
	
	* first caregiver or main caregiver
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dcargiv_f`z'=d`i`z''cargiv if dth`i`z'' == 1  & !inlist(d`i`z''cargiv,8,9,99) 
		}		
	}		
	
	
	* bed bidden
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dbedri_f`z'=d`i`z''bedrid if dth`i`z'' == 1  & !inlist(d`i`z''bedrid,8,9) 
		}		
	}		

	
	* bed bidden day
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen Dbedday_f`z'=d`i`z''bedday if dth`i`z'' == 1  & !inlist(d`i`z''bedday,-1,888,999,998,9999,8888,9998) 
		}		
	}		

********************** health condition but befire dying ***********	
	****************************** disease
	if inlist(wave_alt,1,2,3,4){
		local am = wave_alt-1
		forvalues z = 1/`am'{
			foreach disease in  hypert diabet heart cvd pneum tuberc glauco prosta gastri parkin bedsor dement psycho neuros arthri others{
				gen D`disease'_f`z'=d`i`z''`disease' if dth`i`z'' == 1  & !inlist(d`i`z''`disease',-1,8,9) 
			}
		}		
	}		

	if inlist(wave_alt,5,6,7){
		local am = wave_alt-5
		forvalues z = 1/`am'{
			foreach disease in  hypert diabet heart cvd pneum tuberc glauco prosta gastri parkin bedsor dement psycho neuros arthri others {
				gen D`disease'_f`z'=d`i`z''`disease' if dth`i`z'' == 1  & !inlist(d`i`z''`disease',-1,8,9) 
			}
		}		
	}		
	if inlist(wave_alt,5,6,7){
		local am1 = 4
		local am = wave_alt
		forvalues z = `am1'/`am'{
			foreach disease in  hypert diabet heart cvd pneum tuberc glauco prosta gastri parkin bedsor dement  arthri {
				gen D`disease'_f`z'=d`i`z''`disease' if dth`i`z'' == 1  & !inlist(d`i`z''`disease',-1,8,9) 
			}
		}		
	}	
	if inlist(wave_alt,5,6,7){
		local am1 = 4
		local am = wave_alt-1
		forvalues z = `am1'/`am'{
			foreach disease in  psycho neuros others{
				gen D`disease'_f`z'=d`i`z''`disease' if dth`i`z'' == 1  & !inlist(d`i`z''`disease',-1,8,9) 
			}
		}		
	}	
	if inlist(wave_alt,5,6,7){
		local am1 = wave_alt-3
		local am = wave_alt
		forvalues z = `am1'/`am'{
			foreach disease in  cancer{
				gen D`disease'_f`z'=d`i`z''`disease' if dth`i`z'' == 1  & !inlist(d`i`z''`disease',-1,8,9) 
			}
		}		
	}	
	if inlist(wave_alt,5,6,7){
		local am1 = wave_alt-3
		local am = wave_alt-1
		forvalues z = `am1'/`am'{
			foreach disease in  gyneco{
				gen D`disease'_f`z'=d`i`z''`disease' if dth`i`z'' == 1  & !inlist(d`i`z''`disease',-1,8,9) 
			}
		}		
	}	
	
	
	****************************** ADL
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode d`i`z''bathfu  d`i`z''dresfu d`i`z''toilfu d`i`z''movefu d`i`z''contfu d`i`z''feedfu  (1 = 0 "do not need help") (2 3 = 1 "need help") (-1 -8 -7 -9 8 9 = .),gen(Dbathing_f`z' Ddressing_f`z' Dtoileting_f`z' Dtransferring_f`z' Dcontinence_f`z' Dfeeding_f`z') label(adl_row_f`z')
			
			egen adl_miss_f`z'= rowmiss(Dbathing_f`z' Ddressing_f`z' Dtoileting_f`z' Dtransferring_f`z' Dcontinence_f`z' Dfeeding_f`z')
			egen adl_sum_f`z' = rowtotal(Dbathing_f`z' Ddressing_f`z' Dtoileting_f`z' Dtransferring_f`z' Dcontinence_f`z' Dfeeding_f`z')
			
			replace adl_sum_f`z' = . if adl_miss_f`z' > 1 
			
			gen adl_f`z' = (adl_sum_f`z' > 0) if adl_sum_f`z' != .
			label define adl_f`z' 0"0:without ADL" 1"1:with ADL"
			label value adl_f`z' adl_f`z'			
		}		
	}	

	****************************** lifestyle 
	if inlist(wave_alt,1,2,3,4,5,6,7){
		forvalues z = 1/`am'{
			* Smoking
			recode d`i`z''smoke  (-8 -9 -7 -1 -1 8 9 = .)
			recode d`i`z''smktim (-8 -9 -7 -1 88 99 = .)
			gen Dsmkl_f`z' = 1 if !inlist(d`i`z''smoke,1,.)			// choose to code smk missing if r_smkl_pres is missing
			replace Dsmkl_f`z' = 2 if d`i`z''smoke == 1 & (d`i`z''smktim * 1.4) >= 0 & (d`i`z''smktim * 1.4) < 20
			replace Dsmkl_f`z' = 3 if d`i`z''smoke == 1 & (d`i`z''smktim * 1.4) >= 20 & (d`i`z''smktim * 1.4) <= 50
			label define Dsmkl_f`z' 1 "never" 2"light" 3 "heavy"
			label value Dsmkl_f`z'  Dsmkl_f`z' 
			
			* Drinking alchol
			recode d`i`z''drkmch (-1 88 99 = .)
			recode  d`i`z''drink d`i`z''knddrk (-1 8 9 = .)  
			gen Dalcohol_f`z' = . 

				replace Dalcohol_f`z' = d`i`z''smktim * 50 * 0.53 if d`i`z''knddrk == 1
				replace Dalcohol_f`z' = d`i`z''smktim * 50 * 0.38 if d`i`z''knddrk == 2
				replace Dalcohol_f`z' = d`i`z''smktim * 50 * 0.12 if d`i`z''knddrk == 3
				replace Dalcohol_f`z' = d`i`z''smktim * 50 * 0.15 if d`i`z''knddrk == 4
				replace Dalcohol_f`z' = d`i`z''smktim * 50 * 0.04 if d`i`z''knddrk == 5
				replace Dalcohol_f`z' = d`i`z''smktim * 50 * 0.244 if d`i`z''knddrk == 6
			
			generate Ddril_f`z'=.
			replace Ddril_f`z'=1 if d`i`z''drink==2 
			replace Ddril_f`z'=2 if gender==1 & d`i`z''drink==1 & inrange(Dalcohol_f`z',0, 25)
			replace Ddril_f`z'=2 if gender==0 & d`i`z''drink==1 & inrange(Dalcohol_f`z',0, 15)
			replace Ddril_f`z'=3 if gender==1 & d`i`z''drink==1 & (Dalcohol_f`z' > 25 & Dalcohol_f`z' < . )  // & not |
			replace Ddril_f`z'=3 if gender==0 & d`i`z''drink==1 & (Dalcohol_f`z' > 15 & Dalcohol_f`z' < . )
			label define Ddril_f`z' 1 "never" 2 "current & light" 3 "current & heavy"
			label value Ddril_f`z' Ddril_f`z'
		}
	}

	
	keep if dthdate !=. 
	if inlist(wave_alt,1,2,3,4,5,6,7){
		//gen temp_keep = .
		forvalues z = 1/`am'{
			drop if dth`i`z'' == -9 
			//replace temp_keep = 1 if dth`i`z'' == -8 | dth`i`z'' == 1
			gen dth_f`z' = dth`i`z''
		}
		//keep if temp_keep == 1
		//drop temp_keep
	}	
	

	
	if inlist(wave_alt,2,3,4,5,6,7){
		
		keep id* id_year *wave*  trueage* residenc prov gender ethnicity coresidence edu occupation marital  residence  w_*   ///
	lostdate interview* censor*_* lost*_* survival_bth*_* survival_bas*_*  in*  D*  
	}	
	if inlist(wave_alt,1){
		keep id* id_year *wave*  trueage* residenc prov gender ethnicity coresidence edu occupation marital  residence  w_*   ///
	lostdate interview* censor*_* lost*_* survival_bth*_* survival_bas*_*   D*  
	}		
	
save "${OUT}/dat`year'_death.dta",replace
}	
xx
*****************************************************************
*************** 2. Data Reshape ********
*****************************************************************
use "${OUT}/dat98_death.dta",clear
	append using "${OUT}/dat00_death.dta" "${OUT}/dat02_death.dta" "${OUT}/dat05_death.dta"  "${OUT}/dat08_death.dta" "${OUT}/dat11_death.dta" "${OUT}/dat14_death.dta"
	duplicates drop
	global namenew
		
		* rename "_f1" to "_1", "_f2" to "_2", "_f3" to "_3", etc. 
		foreach k in 1 2 3 4 5 6 7 {
			foreach var of varlist *_f`k'{
				local b = subinstr("`var'","_f`k'","",.)
				ren `b'_f`k' `b'_`k'
			}
		}		
		
		foreach var of varlist *_1{
			local e = subinstr("`var'","_1","_",.)
			global namenew $namenew `e'
		}
		display "$namenew"

		reshape long $namenew ,  i(id) j(followup)

		* rename variable from "var_" to "var"
		foreach var of global namenew{
			local a = subinstr("`var'","_","",.)
			ren `var' `a'
		}
		order id followup

		format *date* %tdY-M-D
		
	
//
d0wcfaci
d0tapwat
d0bathfa
d0heater
d0tvset
d0washma
d0phone	


//
d11retire
d11retyr
d11retpen
d11insur
d11payind
d11paygov
d11inspen
d11noinsu

d14d22
d14d231
d14d232
d14d233
d14d234
d14d24
d14d25

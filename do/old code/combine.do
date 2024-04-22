use "${COV}/Base_dat98_18_f7_covariances.dta",clear
	append using "${COV}/Base_dat00_18_f7_covariances.dta" "${COV}/Base_dat02_18_f7_covariances.dta" "${COV}/Base_dat05_18_f7_covariances.dta"  "${COV}/Base_dat08_18_f7_covariances.dta" "${COV}/Base_dat11_18_f7_covariances.dta" "${COV}/Base_dat14_18_f7_covariances.dta"

	reshape long $namenew ,  i(id) j(followup)

save "${COV}/Base_dat98-18_panel_covariances.dta",replace
	
	
use "${OUT}/dat98_death.dta",clear	
	label define marry 1"married and living with spouse" 2"married but separate with" 3"divorced" 4"widowed" 5"never married"
	label values Dmarry_*  marry

	label define livarr 0 "institution" 1"alone due to never married" 2"alone due to widowed or divorced" 3"with spouse only" 4"with married children and/or grandchildren" 5"with grandchildren only" 6"with unmarried children and/or offspring" 7"other relatives"
	label values Dlivarr_*  livarr

	label define urban 1 "city" 2 "town" 3 "rural"
	label values Durban_* urban
	
	label define prov 11 "beijing" 12 "tianjin" 13 "hebei" 14 "shanxi" 21 "liaoning" 22 "jilin" 23 "heilongjiang" 31 "shanghai" 32 "jiangsu" 33 "zhejiang" 34 "anhui" 35 "fujian" 36 "jiangxi" 37 "shandong" 41 "henan" 42 "hubei" 43 "hunan" 44 "guangdong" 45 "guanxi" 50 "chongqing" 51 "sichuan" 61 "shaanxi"
	label values Dprov_* prov
	
	label define havedoc 1 "no" 2 "yes" 
	label values Dhavedoc_* havedoc
	
	label define havedoclic 1 "licensed with college degree" 2 "licensed without college degree" 3 "unlicensed" 
	label values Dhavedoclic_* havedoclic
	
    label define medexp12m_ 99998 "more than 100,000"
	label values Dmedexp12m_* medexp12mDmedexp12m_
	
	label define place 1 "home" 2 "hospital" 3 "institution" 4 "others" 
	label values Dplace_* place 
	
	label define bedri 1 "no" 2 "yes" 
	label values Dbedri_* bedri
	
	label define bedday 998 "more than 1000 days" 
	label values Dbedday_* bedday
	
	label define others  1 "difficult to classify" 2 "no" 3 "don't know" 4 "mental disease" 5 "orthopedic disease" 6 "internal medical disease" 7 "dermatosis"
	label values Dothers_* others
	
	label define bathing  1 "fully independent in bathing" 2 "partially independent in bathing" 3 "fully dependent in bathing" 
	label values Dbathing_* bathing
	
	label define dressing  1 "fully independent in bathing" 2 "partially independent in bathing" 3 "fully dependent in bathing" 
	label values Ddressing_* dressing
	
	label define toileting  1 "fully independent in toileting" 2 "partially independent in toileting" 3 "fully dependent in toileting" 
	label values Dtoileting_* toileting
	
	label define transferring 1 "fully independent in indoor transferring" 2 "partially independent in indoor transferring" 3 "fully dependent in indoor transferring" 
	label values Dtransferring_* transferring
	
	label define continence  1 "fully independent in continence" 2 "partially independent in continence" 3 "fully dependent in continence" 
	label values Dcontinence_* continence
	
	label define feeding  1 "fully independent in feeding" 2 "partially independent in feeding" 3 "fully dependent in feeding" 
	label values Dfeeding_* feeding
	
	label define hhgener 1 "one generation"2 "two generations"3 "three generations" 4 "four and more generations" 
	label values Dhhgener_* hhgener
	
	label define payercare  1 "medical insurance" 2 "self" 3 "spouse" 4 "children/grandchildren" 5 "state or collectives" 6 "others" 
	label values Dpayercare_* payercare
	
	label define incometot  99998 "more than 100000" 
	label values Dincometot_* incometot
	
	label define logincometot 99998 "more than 100000" 
	label values Dlogincometot_* logincometot
	
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Darthril_`k' "suffering from arthritis before dying?"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedday_`k' "days of being bedridden before dying"
	}
	
	
	
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedri_`k' "bedridden or nor before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dcargiv_`k' "main cause of death"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dcontinence_`k' "functioning of continence before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Ddement_`k' "days of being bedridden before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedday_`k' "days of being bedridden before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedday_`k' "days of being bedridden before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedday_`k' "days of being bedridden before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedday_`k' "days of being bedridden before dying"
	}
	foreach k in 1 2 3 4 5 6 7 8{
		label variable Dbedday_`k' "days of being bedridden before dying"
	}
	
	
 Dcause_2 Dcontinence_2  Ddement_2 Dgastri_2 Dhavedoc_2 Dhavedoclic_2  Dhhsize_2  Dincomeperca_2 Dlivarr_2 Dlogincomeperca_2 Dmedexp12m_2 Dneuros_2 Dothers_2  Dpayerhexp_2 Dplace_2 Dpneum_2 Dprosta_2 Dprov_2 Dpsycho_2  Dtransferring_2 Dtuberc_2 Durban_2 
	
	
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dalcohol_`k' dril_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dbathing_`k' bathing_`k'
	}
	
	
	
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dhypert_`k' hypertension_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren diabet_`k' diabetes_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dheart_`k' heartdisea_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dcvd_`k' strokecvd_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dpneum_`k' copd_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dtuberc_`k' tb_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dglaucoma _`k' glauco_`k' // cataract
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dcancer _`k' cancer_`k' 
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dgastri_`k' ulcer_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dparkin_`k' parkinson_`k'
	}	
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dprosta_`k' prostatetumor_`k'
	}	
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dbedsor_`k' bedsore _`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Darthri_`k' arthritis_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Ddement_`k' dementia_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dpsycho_`k' psychosis_`k'
	}	


	foreach k in 1 2 3 4 5 6 7 8{
		ren Dsmkl_`k' smkl_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dtoileting_`k' toileting_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Ddressing_`k' dressing_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dfeeding_`k' feeding_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dtransferring_`k' transferring_`k'
	}
	foreach k in 1 2 3 4 5 6 7 8{
		ren Dmarry_`k' marital_`k'
	}

	
	// gastri  dement psycho neuros   others
	
		
 Dbedday_2 Dbedri_2  Dcargiv_2 Dcause_2 Dcontinence_2 Dhavedoc_2 Dhavedoclic_2  Dhhsize_2  Dincomeperca_2 Dlivarr_2 Dlogincomeperca_2 Dmedexp12m_2 Dneuros_2 Dothers_2  Dpayerhexp_2 Dplace_2   Dprov_2     Durban_2 
	
save 	"${COV}/Base_death98-18_panel_covariances.dta",replace
xx

use "${COV}/Base_dat98-18_panel_covariances.dta",clear
	append using "${COV}/Base_death98-18_panel_covariances.dta"

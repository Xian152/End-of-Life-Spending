use "${COV}/Base_dat98_18_f7_covariances.dta",clear
	keep id wave* month98 date98 trueage* agebase residenc prov gender ethnicity coresidence edu occupation marital edug residence  *_f1 *_f2 *_f3 *_f4 *_f5 *_f6 *_f7 v_bthyr* v_bthmon* dth dth_* w_* ///
	dthyear dthmonth dthday lostdate dthdate interview2018 censor*_* lost*_* survival_bth*_* survival_bas*_*  intdate intdate_f1 intdate_f2 intdate_f3   /// //dthyear dthmonth dthday lostdate dthdate survival_bas98_14  censor98_14 interview2018 lost98_14 survival_bth98_14 survival_bas_18 censor_18 lost_18 survival_bth_18 survival_bas98_18 survival_bth98_18 censor98_18 lost98_18  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight armlength kneelength  *height* hr hr_irr    ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss  able*  ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi 
	 ren (month98 date98) (monthin dayin) //year9899
	 gen age= agebase
	 drop wave_alt
	 ren wave_baseline wave
	 	foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_1
		}
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_2
		}
		foreach var of varlist *_f2 {
			local b = subinstr("`var'","_f2","",.)
			ren `b'_f2 `b'_3
		}
		foreach var of varlist *_f3 {
			local b = subinstr("`var'","_f3","",.)
			ren `b'_f3 `b'_4
		}
		foreach var of varlist *_f4 {
			local b = subinstr("`var'","_f4","",.)
			ren `b'_f4 `b'_5
		}
		foreach var of varlist *_f5 {
			local b = subinstr("`var'","_f5","",.)
			ren `b'_f5 `b'_6
		}
		foreach var of varlist *_f6 {
			local b = subinstr("`var'","_f6","",.)
			ren `b'_f6 `b'_7
		}
		foreach var of varlist *_f7 {
			local b = subinstr("`var'","_f7","",.)
			ren `b'_f7 `b'_8
		}	
save,replace	

use "${COV}/Base_dat00_18_f7_covariances.dta",clear
	keep id wave* month00 day00 trueage* agebase  residenc prov gender ethnicity coresidence edu occupation marital edug residence *_f1 *_f2 *_f3 *_f4 *_f5 *_f6 v_bthyr* v_bthmon* dth   dth_* w_*  ///
	dthyear dthmonth dthday lostdate censor*_* lost*_* survival_bth*_* survival_bas*_*  dthdate  intdate intdate_f1 intdate_f2 intdate_f3 /// //dthyear dthmonth dthday lostdate survival_bas00_14 dthdate censor00_14 interview2018 lost00_14 survival_bth00_14 survival_bas_18 censor_18 lost_18 survival_bth_18 survival_bas00_18 survival_bth00_18 censor00_18 lost00_18  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight hr hr_irr    ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss  able*  ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi
	ren (month00 day00) (monthin dayin) //year9899
	 gen age= agebase
	 drop wave_alt
	 ren wave_baseline wave
	 gen armlength = .
	 gen kneelength = .
	 foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_2
		} 
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_3
		}
		foreach var of varlist *_f2 {
			local b = subinstr("`var'","_f2","",.)
			ren `b'_f2 `b'_4
		}
		foreach var of varlist *_f3 {
			local b = subinstr("`var'","_f3","",.)
			ren `b'_f3 `b'_5
		}
		foreach var of varlist *_f4 {
			local b = subinstr("`var'","_f4","",.)
			ren `b'_f4 `b'_6
		}
		foreach var of varlist *_f5 {
			local b = subinstr("`var'","_f5","",.)
			ren `b'_f5 `b'_7
		}
		foreach var of varlist *_f6 {
			local b = subinstr("`var'","_f6","",.)
			ren `b'_f6 `b'_8
		}

	
save,replace	


use "${COV}/Base_dat02_18_f7_covariances.dta",clear
	keep id wave* month02 day02 trueage* agebase  residenc prov gender ethnicity coresidence edu occupation marital edug residence  *_f1 *_f2 *_f3 *_f4 *_f5 v_bthyr* v_bthmon* dth  dth_* w_*  ///
	dthyear dthmonth dthday lostdate censor*_* lost*_* survival_bth*_* survival_bas*_*  dthdate  d18vyear d18vmonth d18vday  intdate intdate_f1 intdate_f2 intdate_f3  /// //dthyear dthmonth dthday lostdate survival_bas02_14 dthdate censor02_14 interview2018 lost02_14 survival_bth02_14 d18vyear d18vmonth d18vday survival_bas_18 censor_18 lost_18 survival_bth_18 survival_bas02_18 survival_bth02_18 censor02_18 lost02_18  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight armlength kneelength  *height*    hr hr_irr   ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss   able* ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi
	ren (month02 day02) (monthin dayin) //year9899
	 drop wave_alt
	 ren wave_baseline wave
	 gen age= agebase
		 foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_3
		} 
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_4
		}
		foreach var of varlist *_f2 {
			local b = subinstr("`var'","_f2","",.)
			ren `b'_f2 `b'_5
		}
		foreach var of varlist *_f3 {
			local b = subinstr("`var'","_f3","",.)
			ren `b'_f3 `b'_6
		}
		foreach var of varlist *_f4 {
			local b = subinstr("`var'","_f4","",.)
			ren `b'_f4 `b'_7
		}
		foreach var of varlist *_f5 {
			local b = subinstr("`var'","_f5","",.)
			ren `b'_f5 `b'_8
		}

save,replace	

use "${COV}/Base_dat05_18_f7_covariances.dta",clear
	keep id wave* monthin dayin trueage* agebase  residenc prov gender ethnicity coresidence edu occupation marital edug residence  *_f1 *_f2 *_f3 *_f4 v_bthyr* v_bthmon*  dth  dth_* w_*  ///
	dthyear dthmonth dthday lostdate censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate intdate intdate_f1 intdate_f2 intdate_f3   /// //dthyear dthmonth dthday lostdate survival_bas05_14 dthdate censor05_14 interview2018 lost05_14 survival_bth05_14 survival_bas_18 censor_18 lost_18 survival_bth_18 survival_bas05_18 survival_bth05_18 censor05_18 lost05_18  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight youngheight *height* hr hr_irr   ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss  able*  ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi
	gen age= agebase	
	 drop wave_alt
	 gen armlength = .
	 gen kneelength = .	 
	 gen meaheight = .
	 gen height = .
	 gen bmi = .
	 gen bmi_cat = .
	 ren wave_baseline wave
		 foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_4
		} 
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_5
		}
		foreach var of varlist *_f2 {
			local b = subinstr("`var'","_f2","",.)
			ren `b'_f2 `b'_6
		}
		foreach var of varlist *_f3 {
			local b = subinstr("`var'","_f3","",.)
			ren `b'_f3 `b'_7
		}
		foreach var of varlist *_f4 {
			local b = subinstr("`var'","_f4","",.)
			ren `b'_f4 `b'_8
		}


save,replace

use "${COV}/Base_dat08_18_f7_covariances.dta",clear
	keep id wave* monthin dayin trueage* agebase  residenc prov gender ethnicity coresidence edu occupation marital edug residence  *_f1 *_f2 *_f3  v_bthyr* v_bthmon*  dth  dth_* w_*  ///
	dthyear dthmonth dthday lostdate censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate  d18vyear d18vmonth d18vday  intdate intdate_f1 intdate_f2 intdate_f3  /// //dthyear dthmonth dthday lostdate survival_bas08_14 dthdate censor08_14 interview2018 lost08_14 survival_bth08_14 d18vyear d18vmonth d18vday survival_bas_18 censor_18 lost_18 survival_bth_18 survival_bas08_18 survival_bth08_18 censor08_18 lost08_18  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength  *height*   *bmi*  hr    ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss  able*  ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi
	gen age= agebase
	gen hunchbacked = . 
	gen hearingloss = .
	 drop wave_alt
	 ren wave_baseline wave
		 foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_5
		} 
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_6
		}
		foreach var of varlist *_f2 {
			local b = subinstr("`var'","_f2","",.)
			ren `b'_f2 `b'_7
		}
		foreach var of varlist *_f3 {
			local b = subinstr("`var'","_f3","",.)
			ren `b'_f3 `b'_8
		}

save,replace

use "${COV}/Base_dat11_18_f7_covariances.dta",clear
	keep id wave* monthin dayin trueage* agebase  residenc prov gender ethnicity coresidence edu occupation marital edug residence  *_f1 *_f2 v_bthyr* v_bthmon*  dth_* w_*  dth  ///
	dthyear dthmonth dthday lostdate censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate interview2018  intdate intdate_f1 intdate_f2   /// //dthyear dthmonth dthday lostdate survival_bas11_14 dthdate censor11_14 interview2018 lost11_14 survival_bth11_14 survival_bas_18 censor_18 lost_18 survival_bth_18 survival_bas11_18 survival_bth11_18 censor11_18 lost11_18  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength  *height*   *bmi*  hr hr_irr    hunchbacked ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss  able*  ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi ///
	 hearingloss
	 drop wave_alt
	 ren wave_baseline wave
	 gen age= agebase
		 foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_6
		} 
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_7
		}
		foreach var of varlist *_f2 {
			local b = subinstr("`var'","_f2","",.)
			ren `b'_f2 `b'_8
		}



save,replace

use "${COV}/Base_dat14_18_f7_covariances.dta",clear
	keep id wave* monthin dayin trueage* agebase residenc prov gender ethnicity coresidence edu occupation marital edug residence  *_f1 v_bthyr* v_bthmon*  dth_* w_*  dth  ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate  lostdate  intdate intdate_f1   /// //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq r_pa_pres r_pa_past r_pa_start r_pa_quit  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength  *height*   *bmi*  hr hr_irr   hunchbacked ///
	 psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho psy_miss  able*  ///
	 time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3 copyf ci_missing ci time_orientation orientation registration calculation delayed_recall naming_objects listening_obeying Language orientation_full namefo_full registration_full calculation_full copyf_full delayed_recall_full Language_full mmse ci_cat ci_bi ///
	 hearingloss
	 drop wave_alt
	 ren wave_baseline wave
	 gen age= agebase
		 foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_7
		} 
		foreach var of varlist *_f1 {
			local b = subinstr("`var'","_f1","",.)
			ren `b'_f1 `b'_8
		}
save,replace

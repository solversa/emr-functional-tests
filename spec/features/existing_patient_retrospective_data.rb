require 'spec_helper'

feature "Existing patient retrospective data" do
  scenario "Verify retrospective entry of data" do
    new_patient = {:given_name => "Ram#{(0...5).map { (97 + rand(26)).chr }.join}", :family_name => 'Singh', :gender => 'Male', :age => {:years => "40"}, :village => 'Ganiyari'}
    chief_complaints = [{:name => 'Cough', :duration => {:value => 2, :unit => 'Days'}, :coded => false}]
    chief_complaints_2 = [{:name => 'Headache', :duration => {:value => 3, :unit => 'Days'}, :coded => false}]
    history_and_examinations = {:chief_complaints => chief_complaints, :history_notes => "Smoking", :examination_notes => "Concise text notes", :smoking_history => "No" }
    history_and_examinations_2 = {:chief_complaints => chief_complaints_2, :history_notes => "Drinking", :examination_notes => "Concise text notes by otheruser", :smoking_history => "No" }
    vitals = {:pulse => 76, :diastolic => 77, :systolic => 119, :posture => 'Supine', :temperature => 101, :rr => 18, :spo2 => 98}
    vitals_2 = {:pulse => 78, :diastolic => 79, :systolic => 120, :posture => 'Supine', :temperature => 102, :rr => 19, :spo2 => 99}
    diagnosis = {:index => 0, :name => 'cold', :order => 'PRIMARY', :certainty => 'PRESUMED'}
    gynaecology = {:ps_perSpeculum_cervix => ["Growth", "VIA +ve"] }
    gynaecology_2 = {:ps_perSpeculum_cervix => ["Normal", "VIA -ve"] }

    location= 'OPD-1'
    retrospective_date= '2015-01-03'
    retrospective_date_with_month_in_words='03 Jan 15'

    log_in_to_app(:Registration, :location => 'Registration') do
      register_new_patient_and_start_visit(:patient => new_patient, :visit_type => 'OPD')
    end

    log_in_to_app(:Clinical, :location => location) do
      patient_search_page.enter_retrospective_date(retrospective_date)
      patient_search_page.view_patient_from_active_tab(new_patient[:given_name ])
      patient_dashboard_page.start_consultation

      diagnosis_page.add_non_coded_diagnosis(diagnosis)
      observations_page.fill_history_and_examinations_section(history_and_examinations)
      observations_page.fill_vitals_section(vitals)
      observations_page.fill_gynaecology_section(gynaecology)
      observations_page.save
      observations_page.go_to_dashboard_page

      patient_dashboard_page.verify_retrospective_date(location,retrospective_date_with_month_in_words)
      patient_dashboard_page.verify_observations_on_all_details_page(vitals, "Vitals")

      patient_dashboard_page.verify_gynaecology_values(gynaecology, "Gynaecology")
      patient_dashboard_page.verify_observations_on_all_details_page(gynaecology, "Gynaecology")

      patient_dashboard_page.navigate_to_visit_page(retrospective_date_with_month_in_words)
      visit_page.verify_observations(vitals)
      visit_page.navigate_to_patient_dashboard

    end

    log_in_as_different_user(:Clinical) do

      patient_search_page.enter_retrospective_date(retrospective_date)
      patient_search_page.view_patient_from_active_tab(new_patient[:given_name ])
      patient_dashboard_page.start_consultation

      diagnosis_page.add_non_coded_diagnosis(diagnosis)
      observations_page.fill_history_and_examinations_section(history_and_examinations_2)
      observations_page.fill_vitals_section(vitals_2)
      observations_page.fill_gynaecology_section(gynaecology_2)
      observations_page.save
      observations_page.go_to_dashboard_page

      patient_dashboard_page.verify_retrospective_date(location,retrospective_date_with_month_in_words)
      patient_dashboard_page.verify_observations_on_all_details_page(vitals_2, "Vitals")

      patient_dashboard_page.verify_gynaecology_values(gynaecology_2, "Gynaecology")
      patient_dashboard_page.verify_observations_on_all_details_page(gynaecology_2, "Gynaecology")

      patient_dashboard_page.navigate_to_visit_page(retrospective_date_with_month_in_words)
      visit_page.verify_observations(vitals_2)
      visit_page.navigate_to_patient_dashboard

    end
  end

  scenario "Verify retrospective entry of Drugs data" do
    date = Date.today();
    patient = {:given_name => "Ram#{(0...5).map { (97 + rand(26)).chr }.join}", :family_name => 'Singh', :gender => 'Male', :age => {:years => "40"}, :village => 'Ganiyari'}
    drug1 = {:drug_name => "Albendazole 400mg (Tablet)", :dose => "2", :dose_unit => "Tablet(s)", :frequency => "Twice a day", :sos => false, :start_date => date.strftime("%F"),
             :instructions => "After meals", :duration => "1", :duration_unit => "Day(s)", :drug_route => "Oral", :additional_instructions => "On medication",
             :quantity => "4", :quantity_units => "Tablet(s)"}

    drug2 = {:drug_name => "Albendazole 400mg (Tablet)", :morning_dose => "1.5", :noon_dose => "0", :night_dose => "1", :dose_unit => "Tablet(s)", :sos => true, :start_date => (date + 1).strftime("%F"),
             :instructions => "After meals", :duration => "4", :duration_unit => "Day(s)", :drug_route => "Oral", :additional_instructions => "Take medicine as required",
             :quantity => "10", :quantity_units => "Tablet(s)"}


    location= 'OPD-1'
    retrospective_date= '2015-01-03'
    retrospective_date_with_month_in_words='03 Jan 15'

    log_in_to_app(:Registration, :location => 'Registration') do
      register_new_patient_and_start_visit(:patient => patient, :visit_type => 'OPD')
    end

    log_in_to_app(:Clinical, :location => location) do
      patient_search_page.enter_retrospective_date(retrospective_date)
      patient_search_page.view_patient_from_all_tab(patient[:given_name])
      patient_dashboard_page.start_consultation

      observations_page.go_to_tab("Medications")
      treatment_page.add_new_drug(drug1, drug2)
      treatment_page.save

      treatment_page.verify_drug_on_tab("Recent", drug1, drug2)
      treatment_page.verify_drug_on_tab(retrospective_date_with_month_in_words, drug1, drug2)

      treatment_page.go_to_dashboard_page
      patient_dashboard_page.verify_retrospective_date_in_drug_section(retrospective_date_with_month_in_words)
      patient_dashboard_page.verify_new_drugs(drug1, drug2)

      patient_dashboard_page.navigate_to_visit_page(retrospective_date_with_month_in_words)
      visit_page.verify_new_drugs(drug1, drug2)
      visit_page.navigate_to_patient_dashboard

      patient_dashboard_page.navigate_to_all_treatments_page
      summary_page.verify_new_drugs(drug1, drug2)

    end
  end
end
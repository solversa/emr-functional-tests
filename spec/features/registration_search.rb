require 'spec_helper'

feature "Registration search " do
  scenario "registration search by name results, search by id patient details and patient Visit" do
    updated_patient_details = {:village => 'Nandhigama'}
    new_patient = {:given_name => "Ram#{(0...5).map { (97 + rand(26)).chr }.join}", :family_name => 'Singh', :gender => 'Male', :age => {:years => "40"}, :village => 'Ganiyari'}
    patient_id=""
    visit_info = {:fee => 15, :weight => 70, :height => 170, :comments => 'Billed'}

    log_in_to_app(:Registration, :location => 'OPD-1') do
      register_new_patient(:patient => new_patient)
      patient_id= patient_page.get_patient_id
    end

    log_in_to_app(:Registration, :location => 'OPD-1') do
      verify_search_by_name_results(new_patient)
      verify_details_in_patient_page(patient_id,new_patient)
      verify_back_button_in_visit_page(:visit_type => 'OPD')
      #verify_details_after_update_village(updated_patient_details[:village])
      save_existing_patient_visit(visit_info)
    end

  end

  scenario "close visit for a discharged patient" do
    patient_name="Test CloseVisit"
    patient_id="200061"
    discharge_details = {:action => "Discharge Patient", :notes => "Discharge the patient"}
    log_in_to_app(:Registration, :location => 'OPD-1') do
      #patient_search_page.search_patient_with_name(patient_name)

      patient_search_page.search_patient_with_id(patient_id)
      patient_page.enter_visit_page
      visit_page.close_visit
      visit_page.verify_message_cannot_be_closed_for_admitted
    end
    go_to_app(:InPatient) do
      patient_search_page.view_patient_from_admitted_tab(patient_name)
      patient_dashboard_page.perform_discharge_action(discharge_details)
    end
    go_to_app(:Registration) do
      patient_search_page.search_patient_with_id(patient_id)
      patient_page.enter_visit_page
      visit_page.close_visit
      page.driver.browser.switch_to.alert.accept
      patient_search_page.search_patient_with_id(patient_id)
      patient_page.verify_start_visit_button
    end
    #go_to_app(:InPatient) do
    #  patient_search_page.search_patient_in_all_tab(patient_name)
    #  debugger
    #  patient_dashboard_page.verify_only_undoDischarge_option_available
    #end

  end
end

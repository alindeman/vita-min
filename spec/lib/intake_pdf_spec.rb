require "rails_helper"

RSpec.describe IntakePdf do
  include PdfSpecHelper

  let(:intake_pdf) { IntakePdf.new(intake) }

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake }

      it "returns a pdf with default fields and values" do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including({
          "first_name" => "",
          "middle_initial" => "",
          "last_name" => "",
          "date_of_birth" => "",
          "job" => "",
          "spouse_first_name" => "",
          "spouse_middle_initial" => "",
          "spouse_last_name" => "",
          "spouse_date_of_birth" => "",
          "spouse_job" => "",
          "claimed_by_another" => "unfilled",

          "street_address" => "",
          "apt" => "",
          "city" => "",
          "state" => "",
          "zip_code" => "",
          "phone_number" => "",
          "email_address" => "",
          "student" => "unfilled",
          "spouse_student" => "unfilled",
          "primary_was_on_visa" => "",
          "spouse_was_on_visa" => "",
          "blind" => "unfilled",
          "spouse_blind" => "unfilled",
          "is_disabled" => "unfilled",
          "spouse_is_disabled" => "unfilled",
          "issued_pin" => "unfilled",
          "is_citizen" => "",
          "spouse_is_citizen" => "",

          "direct_deposit" => "unfilled",
          "savings_split_refund" => "unfilled",
          "savings_purchase_bond" => "unfilled",
          "balance_due_transfer" => "unfilled",

          "never_married" => "",
          "married" => "",
          "lived_with_spouse" => "unfilled",
          "divorced" => "",
          "divorced_date" => "",
          "legally_separated" => "",
          "separated_date" => "",
          "widowed" => "",
          "widowed_date" => "",

          "dependent_1_name" => nil,
          "dependent_1_date_of_birth" => nil,
          "dependent_1_relationship" => nil,
          "dependent_1_months_in_home" => nil,
          "dependent_1_marital_status" => nil,
          "dependent_1_citizen" => nil,
          "dependent_1_resident" => nil,
          "dependent_1_student" => nil,
          "dependent_1_disabled" => nil,
          "dependent_2_name" => nil,
          "dependent_2_date_of_birth" => nil,
          "dependent_2_relationship" => nil,
          "dependent_2_months_in_home" => nil,
          "dependent_2_marital_status" => nil,
          "dependent_2_resident" => nil,
          "dependent_2_student" => nil,
          "dependent_2_disabled" => nil,
          "dependent_2_citizen" => nil,
          "dependent_3_name" => nil,
          "dependent_3_date_of_birth" => nil,
          "dependent_3_relationship" => nil,
          "dependent_3_months_in_home" => nil,
          "dependent_3_marital_status" => nil,
          "dependent_3_citizen" => nil,
          "dependent_3_resident" => nil,
          "dependent_3_student" => nil,
          "dependent_3_disabled" => nil,
          "dependent_4_name" => nil,
          "dependent_4_date_of_birth" => nil,
          "dependent_4_relationship" => nil,
          "dependent_4_months_in_home" => nil,
          "dependent_4_marital_status" => nil,
          "dependent_4_citizen" => nil,
          "dependent_4_resident" => nil,
          "dependent_4_student" => nil,
          "dependent_4_disabled" => nil,

          "demographic_english_conversation" => nil,
          "demographic_english_reading" => nil,
          "demographic_household_disability" => nil,
          "demographic_household_veteran" => nil,
          "demographic_primary_race_american_indian_alaska_native" => "Off",
          "demographic_primary_race_asian" => "Off",
          "demographic_primary_race_black_african_american" => "Off",
          "demographic_primary_race_native_hawaiian_pacific_islander" => "Off",
          "demographic_primary_race_white" => "Off",
          "demographic_primary_race_prefer_not_to_answer_race" => "Off",
          "demographic_spouse_race_american_indian_alaska_native" => "Off",
          "demographic_spouse_race_asian" => "Off",
          "demographic_spouse_race_black_african_american" => "Off",
          "demographic_spouse_race_native_hawaiian_pacific_islander" => "Off",
          "demographic_spouse_race_white" => "Off",
          "demographic_spouse_race_prefer_not_to_answer_race" => "Off",
          "demographic_primary_ethnicity" => nil,
          "demographic_spouse_ethnicity" => nil,

          "had_wages" => "unfilled",
          "job_count" => "",
          "had_tips" => "unfilled",
          "had_retirement_income" => "unfilled",
          "had_social_security_income" => "unfilled",
          "had_unemployment_income" => "unfilled",
          "had_disability_income" => "unfilled",
          "had_interest_income" => "unfilled",
          "had_asset_sale_income_loss" => "unfilled",
          "received_alimony" => "unfilled",
          "had_rental_income" => "unfilled",
          "had_local_tax_income" => "unfilled",
          "had_self_employment_income" => "unfilled",
          "had_other_income" => "unfilled",
          "other_income_types" => "",
          "paid_mortgage_interest" => "",
          "paid_local_tax"  => "",
          "paid_medical_expenses" => "",
          "paid_charitable_contributions" => "",
          "paid_student_loan_interest" => "unfilled",
          "paid_dependent_care" => "unfilled",
          "paid_retirement_contributions" => "unfilled",
          "paid_school_supplies" => "unfilled",
          "paid_alimony" => "unfilled",
          "paid_post_secondary_expenses" => "unfilled",
          "had_hsa" => "unfilled",
          "bought_health_insurance" => "unfilled",
          "received_homebuyer_credit" => "unfilled",
          "bought_energy_efficient_items" => "unfilled",
          "had_debt_forgiven" => "unfilled",
          "had_disaster_loss" => "unfilled",
          "adopted_child" => "unfilled",
          "had_tax_credit_disallowed" => "unfilled",
          "received_irs_letter" => "unfilled",
          "made_estimated_tax_payments" => "unfilled",
          "received_stimulus_payment" => "unfilled",
          "additional_comments" => ""
        }))
      end
    end

    context "with a complete intake record" do
      let(:intake) do
        create(
          :intake,
          primary_first_name: "Hoofie",
          primary_last_name: "Heifer",
          primary_birth_date: Date.new(1961, 4, 19),
          email_address: "hoofie@heifer.horse",
          phone_number: "+14158161286",
          spouse_first_name: "Hattie",
          spouse_last_name: "Heifer",
          spouse_birth_date: Date.new(1959, 11, 1),
          primary_consented_to_service: "yes",
          spouse_consented_to_service: "yes",
          filing_joint: "yes",
          street_address: "789 Garden Green Ln",
          city: "Gardenia",
          state: "nj",
          zip_code: "08052",
          multiple_states: "yes",
          ever_married: "yes",
          married: "yes",
          lived_with_spouse: "yes",
          divorced: "no",
          divorced_year: "2015",
          separated: "no",
          separated_year: "2016",
          widowed: "no",
          widowed_year: "2017",
          had_wages: "yes",
          had_tips: "yes",
          had_retirement_income: "yes",
          had_social_security_income: "yes",
          had_unemployment_income: "yes",
          had_disability_income: "no",
          had_interest_income: "yes",
          had_asset_sale_income: "yes",
          reported_asset_sale_loss: "yes",
          received_alimony: "yes",
          had_rental_income: "yes",
          had_farm_income: "no",
          had_gambling_income: "yes",
          had_local_tax_refund: "yes",
          had_self_employment_income: "yes",
          reported_self_employment_loss: "yes",
          had_other_income: "yes",
          other_income_types: "garden gnoming",
          paid_mortgage_interest: "no",
          paid_local_tax: "yes",
          paid_medical_expenses: "yes",
          paid_charitable_contributions: "no",
          paid_student_loan_interest: "yes",
          paid_dependent_care: "unfilled",
          paid_retirement_contributions: "unsure",
          paid_school_supplies: "yes",
          paid_alimony: "yes",
          had_student_in_family: "no",
          sold_a_home: "no",
          had_hsa: "no",
          bought_health_insurance: "yes",
          received_homebuyer_credit: "yes",
          had_debt_forgiven: "yes",
          had_disaster_loss: "yes",
          adopted_child: "no",
          had_tax_credit_disallowed: "yes",
          received_irs_letter: "no",
          bought_energy_efficient_items: "unsure",
          made_estimated_tax_payments: "unsure",
          additional_info: "if there is another gnome living in my garden but only i have an income, does that make me head of household?",
          final_info: "Also here are some additional notes.",
          demographic_disability: "yes",
          demographic_english_conversation: "well",
          demographic_english_reading: "not_well",
          demographic_primary_american_indian_alaska_native: false,
          demographic_primary_asian: false,
          demographic_primary_black_african_american: false,
          demographic_primary_ethnicity: "not_hispanic_latino",
          demographic_primary_native_hawaiian_pacific_islander: true,
          demographic_primary_prefer_not_to_answer_race: nil,
          demographic_primary_white: true,
          demographic_questions_opt_in: "yes",
          demographic_spouse_american_indian_alaska_native: true,
          demographic_spouse_asian: false,
          demographic_spouse_black_african_american: false,
          demographic_spouse_ethnicity: "not_hispanic_latino",
          demographic_spouse_native_hawaiian_pacific_islander: false,
          demographic_spouse_prefer_not_to_answer_race: nil,
          demographic_spouse_white: false,
          demographic_veteran: "no",
          was_full_time_student: "no",
          was_on_visa: "yes",
          had_disability: "yes",
          was_blind: "no",
          issued_identity_pin: "no",
          spouse_was_full_time_student: "yes",
          spouse_was_on_visa: "unfilled",
          spouse_had_disability: "no",
          spouse_was_blind: "no",
          spouse_issued_identity_pin: "no",
          refund_payment_method: "direct_deposit",
          savings_purchase_bond: "yes",
          savings_split_refund: "no",
          balance_pay_from_bank: "no",
          claimed_by_another: "no",
          job_count: 5,
          received_stimulus_payment: "yes"
        )
      end
      before do
        create(
          :dependent,
          intake: intake,
          first_name: "Percy",
          last_name: "Pony",
          relationship: "Child",
          birth_date: Date.new(2005, 3, 2),
          months_in_home: 12,
          was_married: "no",
          disabled: "no",
          north_american_resident: "yes",
          on_visa: "no",
          was_student: "no"
        )
        create(
          :dependent,
          intake: intake,
          first_name: "Parker",
          last_name: "Pony",
          relationship: "Some kid at my house",
           birth_date: Date.new(2001, 12, 10),
          months_in_home: 4,
          was_married: "yes",
          disabled: "no",
          north_american_resident: "yes",
          on_visa: "no",
          was_student: "yes"
        )
        create(
          :dependent,
          intake: intake,
          first_name: "Penny",
          last_name: "Pony",
          relationship: "Progeny",
          birth_date: Date.new(2010, 10, 15),
          months_in_home: 12,
          was_married: "no",
          disabled: "yes",
          north_american_resident: "yes",
          on_visa: "yes",
          was_student: "no"
        )
        create(
          :dependent,
          intake: intake,
          first_name: "Polly",
          last_name: "Pony",
          relationship: "Baby",
          birth_date: Date.new(2018, 8, 27),
          months_in_home: 5,
          was_married: "no",
          disabled: "yes",
          north_american_resident: "yes",
          on_visa: "no",
          was_student: "no"
        )
      end

      it "returns a filled out pdf" do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to match(hash_including({
           "first_name" => "Hoofie",
           "middle_initial" => "",
           "last_name" => "Heifer",
           "date_of_birth" => "4/19/1961",
           "job" => "",
           "spouse_first_name" => "Hattie",
           "spouse_middle_initial" => "",
           "spouse_last_name" => "Heifer",
           "spouse_date_of_birth" => "11/1/1959",
           "spouse_job" => "",
           "claimed_by_another" => "no",
           "spouse_was_on_visa" => "",
           "primary_was_on_visa" => "0",

           "street_address" => "789 Garden Green Ln",
           "apt" => "",
           "city" => "Gardenia",
           "state" => "NJ",
           "zip_code" => "08052",
           "phone_number" => "(415) 816-1286",
           "email_address" => "hoofie@heifer.horse",
           "student" => "no",
           "spouse_student" => "yes",
           "blind" => "no",
           "spouse_blind" => "no",
           "is_disabled" => "yes",
           "spouse_is_disabled" => "no",
           "is_citizen" => "",
           "spouse_is_citizen" => "",
           "issued_pin" => "no",

           "direct_deposit" => "yes",
           "savings_split_refund" => "no",
           "savings_purchase_bond" => "yes",
           "balance_due_transfer" => "no",

           "never_married" => "",
           "married" => "0",
           "lived_with_spouse" => "yes",
           "divorced" => "",
           "divorced_date" => "2015",
           "legally_separated" => "",
           "separated_date" => "2016",
           "widowed" => "",
           "widowed_date" => "2017",
         #
           "dependent_1_name" => "Percy Pony",
           "dependent_1_date_of_birth" => "3/2/2005",
           "dependent_1_relationship" => "Child",
           "dependent_1_months_in_home" => "12",
           "dependent_1_marital_status" => "S",
           "dependent_1_citizen" => "",
           "dependent_1_resident" => "Y",
           "dependent_1_student" => "N",
           "dependent_1_disabled" => "N",
           "dependent_2_name" => "Parker Pony",
           "dependent_2_date_of_birth" => "12/10/2001",
           "dependent_2_relationship" => "Some kid at my house",
           "dependent_2_months_in_home" => "4",
           "dependent_2_marital_status" => "M",
           "dependent_2_resident" => "Y",
           "dependent_2_student" => "Y",
           "dependent_2_disabled" => "N",
           "dependent_2_citizen" => "",
           "dependent_3_name" => "Penny Pony",
           "dependent_3_date_of_birth" => "10/15/2010",
           "dependent_3_relationship" => "Progeny",
           "dependent_3_months_in_home" => "12",
           "dependent_3_marital_status" => "S",
           "dependent_3_citizen" => "On Visa",
           "dependent_3_resident" => "Y",
           "dependent_3_student" => "N",
           "dependent_3_disabled" => "Y",
           "dependent_4_name" => "Polly Pony",
           "dependent_4_date_of_birth" => "8/27/2018",
           "dependent_4_relationship" => "Baby",
           "dependent_4_months_in_home" => "5",
           "dependent_4_marital_status" => "S",
           "dependent_4_citizen" => "",
           "dependent_4_resident" => "Y",
           "dependent_4_student" => "N",
           "dependent_4_disabled" => "Y",
         #
           "demographic_english_conversation" => "well",
           "demographic_english_reading" => "not_well",
           "demographic_household_disability" => "yes",
           "demographic_household_veteran" => "no",
           "demographic_primary_race_american_indian_alaska_native" => "",
           "demographic_primary_race_asian" => "",
           "demographic_primary_race_black_african_american" => "",
           "demographic_primary_race_native_hawaiian_pacific_islander" => "0",
           "demographic_primary_race_white" => "0",
           "demographic_primary_race_prefer_not_to_answer_race" => "",
           "demographic_spouse_race_american_indian_alaska_native" => "0",
           "demographic_spouse_race_asian" => "",
           "demographic_spouse_race_black_african_american" => "",
           "demographic_spouse_race_native_hawaiian_pacific_islander" => "",
           "demographic_spouse_race_white" => "",
           "demographic_spouse_race_prefer_not_to_answer_race" => "",
           "demographic_primary_ethnicity" => "not_hispanic_latino",
           "demographic_spouse_ethnicity" => "not_hispanic_latino",
         #
           "had_wages" => "yes",
           "job_count" => "5",
           "had_tips" => "yes",
           "had_retirement_income" => "yes",
           "had_social_security_income" => "yes",
           "had_unemployment_income" => "yes",
           "had_disability_income" => "no",
           "had_interest_income" => "yes",
           "had_asset_sale_income_loss" => "yes",
           "received_alimony" => "yes",
           "had_rental_income" => "yes",
           "had_local_tax_income" => "yes",
           "had_self_employment_income" => "yes",
           "had_other_income" => "yes",
           "other_income_types" => "garden gnoming",
           "paid_mortgage_interest" => "",
           "paid_local_tax"  => "0",
           "paid_medical_expenses" => "0",
           "paid_charitable_contributions" => "",
           "paid_student_loan_interest" => "yes",
           "paid_dependent_care" => "unfilled",
           "paid_retirement_contributions" => "unsure",
           "paid_school_supplies" => "yes",
           "paid_alimony" => "yes",
           "paid_post_secondary_expenses" => "no",
           "had_hsa" => "no",
           "bought_health_insurance" => "yes",
           "received_homebuyer_credit" => "yes",
           "bought_energy_efficient_items" => "unsure",
           "had_debt_forgiven" => "yes",
           "had_disaster_loss" => "yes",
           "adopted_child" => "no",
           "had_tax_credit_disallowed" => "yes",
           "received_irs_letter" => "no",
           "made_estimated_tax_payments" => "unsure",
           "received_stimulus_payment" => "yes",
           "additional_comments" => "if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.",
        }))
      end
    end
  end
end

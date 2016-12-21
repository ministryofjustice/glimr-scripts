#!/usr/bin/env ruby

# Smoke test the fee payment application by creating a case in GLiMR, and then
# using the fee payment web application to find and pay its fee liability on
# gov.uk pay

require 'bundler/setup'
require 'awesome_print'
require 'colorize'
require 'faker'
require 'glimr_api_client'
require 'mechanize'
require 'slop'

CREDIT_CARD = {
  number: '4444333322221111',
  expiryMonth: '12',
  expiryYear: '2018',
  cvc: '999',
  addressLine1: '20824 Russel Greens',
  addressCity: 'County Armagh',
  addressPostcode: 'R6X 8EN',
  addressCountry: 'GB'
}

def main
  check_prerequisites

  # case_number, confirmation_code = create_case
  case_number, confirmation_code = ['TC/2016/00059', 'QERARN']
  page = find_fees case_number, confirmation_code
  result = pay_fee page
  ap result
  puts_green "    Passed."
end

def check_prerequisites
  ENV.fetch('FEE_PAYMENT_URL')
end

def find_fees(case_number, confirmation_code)
  a = Mechanize.new
  rtn = nil

  a.get(ENV.fetch('FEE_PAYMENT_URL')) do |page|
    search_page  = a.click(page.link_with(text: /Start now/))
    results_page = search_for_case(search_page, case_number, confirmation_code)
    rtn = click_link(a, results_page, 'Pay now')
  end

  rtn
end

def pay_fee(page)
  confirm_page = page.form_with(name: 'cardDetails') do |f|
    set_field(f, 'cardNo', CREDIT_CARD[:number])
    set_field(f, 'expiryMonth', CREDIT_CARD[:expiryMonth])
    set_field(f, 'expiryYear', CREDIT_CARD[:expiryYear])
    set_field(f, 'cardholderName', 'Sidney Queenie')
    set_field(f, 'cvc', CREDIT_CARD[:cvc])
    set_field(f, 'addressLine1', CREDIT_CARD[:addressLine1])
    set_field(f, 'addressCity', CREDIT_CARD[:addressCity])
    set_field(f, 'addressPostcode', CREDIT_CARD[:addressPostcode])
    set_field(f, 'email', 'conner_romaguera@crooks.name')
    set_field(f, 'addressCountry', CREDIT_CARD[:addressCountry])
  end.click_button

  confirm_page.form_with(action: /card_details.*confirm/).click_button
end

def create_case
  case_params = {
    contactPhone: "0380 580 9248",
    contactFax: "011024 83227",
    contactEmail: "conner_romaguera@crooks.name",
    contactPreference: "Unspecified",
    contactFirstName: "Queenie",
    contactLastName: "Sidney",
    contactStreet1: "Suite 100",
    contactStreet2: "20824 Russel Greens",
    contactStreet3: "Waelchiton",
    contactStreet4: nil,
    contactPostalCode: nil,
    contactCity: nil,
    jurisdictionId: 8,
    onlineMappingCode: "TAXPENALTYMED",
    documentsURL: "http://hirthe.co/rylan_rohan",
    repPhone: "0800 817292",
    repFax: "016977 7922",
    repEmail: "flavio@bruen.net",
    repPreference: "Email",
    repReference: "15EKG6MW0LRGHZ0CK",
    repIsAuthorised: "Yes",
    repOrganisationName: "Carter, Bins and Lowe",
    repFAO: "Miss Timmothy Fay",
    repStreet1: "62132 Lois Common",
    repStreet2: "New Trevion",
    repStreet3: nil,
    repStreet4: nil,
    repCity: "County Armagh",
    repPostalCode: "R6X 8EN"
  }

  response = GlimrApiClient::RegisterNewCase.call(case_params)

  case_number = response.response_body[:tribunalCaseNumber]
  confirmation = response.response_body[:confirmationCode]

  [case_number, confirmation]
end

def search_for_case(page, case_reference, confirmation_code)
  page.form_with(action: '/case_requests') do |f|
    set_field(f, 'case_request[case_reference]', case_reference)
    set_field(f, 'case_request[confirmation_code]', confirmation_code)
  end.click_button
end

def click_link(a, page, link_text)
  link = page.links.find {|l| l.text == link_text}
  a.click link
end

def set_field(f, field_name, value)
  field = f.fields.find {|fld| fld.name == field_name}
  field.value = value
end

def puts_red(string)
  puts "\033[0;31m#{string}\033[0m"
end

def puts_green(string)
  puts "\033[0;32m#{string}\033[0m"
end

main

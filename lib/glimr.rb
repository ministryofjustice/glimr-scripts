require 'bundler/setup'
require 'awesome_print'
require 'colorize'
require 'faker'
require 'glimr_api_client'
require 'slop'


Faker::Config.locale = 'en-GB'

raise "Please set GLIMR_API_URL environment variable" unless ENV['GLIMR_API_URL']
# raise "Unable to call GLiMR API" unless GlimrApiClient::Available.call.available?

FIRST_TIER_TAX_TRIBUNAL_JURISDICTION_ID = 8

def representative
  base = {
    repPhone: Faker::PhoneNumber.phone_number,
    repFax: Faker::PhoneNumber.phone_number,
    repEmail: Faker::Internet.email,
    repPreference: preference,
    repReference: Faker::Vehicle.vin,
    repIsAuthorised: %w(Yes No).sample
  }

  additional = case rand(2)
  when 0
    {
      repFirstName: first_name,
      repLastName: last_name,
    }
  else
    {
      repOrganisationName: Faker::Company.name,
      repFAO: Faker::Name.name,
    }
  end

  address = postal_address

  base.merge(additional).merge(
    repStreet1: address[:street1],
    repStreet2: address[:street2],
    repStreet3: address[:street3],
    repStreet4: address[:street4],
    repCity: address[:city],
    repPostalCode: address[:postcode],
  )
end

def contact
  base = {
    contactPhone: Faker::PhoneNumber.phone_number,
    contactFax: Faker::PhoneNumber.phone_number,
    contactEmail: Faker::Internet.email,
    contactPreference: preference,
  }

  additional = case rand(2)
  when 0
    {
      contactFirstName: first_name,
      contactLastName: last_name,
    }
  else
    {
      contactOrganisationName: Faker::Company.name,
      contactFAO: Faker::Name.name,
    }
  end

  address = postal_address

  base.merge(additional).merge(
    contactStreet1: address[:street1],
    contactStreet2: address[:street2],
    contactStreet3: address[:street3],
    contactStreet4: address[:street4],
    contactPostalCode: address[:postcode],
    contactCity: address[:city]
  )
end

def postal_address
  case rand(2)
  when 0
    {
      street1: Faker::Address.street_address,
      street2: Faker::Address.city,
      city: Faker::Address.county,
      postcode: Faker::Address.postcode,
    }
  else
    {
      street1: Faker::Address.secondary_address,
      street2: Faker::Address.street_address,
      street3: Faker::Address.city,
    }
  end
end

def online_mapping_code
  %w(
  APPEAL_INFONOTICE
  APPEAL_PAYECODING
  APPEAL_PENALTY_LOW
  APPEAL_PENALTY_MED
  APPEAL_PENALTY_HIGH
  APPEAL_OTHER
  APPN_DECISION_ENQRY
  APPN_LATE
  APPN_OTHER
  ).sample
end

def country
  ['UK', 'U.K.', 'United Kingdom', 'England', 'Wales', 'Great Britain', 'Britain'].sample
end

def preference
  %w(Unspecified Email Post Fax Phone).sample
end

def first_name
  Faker::Name.name.split(' ').first
end

def last_name
  Faker::Name.name.split(' ')[1]
end

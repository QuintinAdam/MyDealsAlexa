require 'sinatra'
require 'json'
require 'bundler/setup'
require 'alexa_rubykit'
require 'httparty'
require 'access'
# require './deals'

before do
  content_type('application/json')
end

post '/' do
  request_json = JSON.parse(request.body.read.to_s)
  request = AlexaRubykit.build_request(request_json)

  session = request.session

  response = AlexaRubykit::Response.new

  if (request.type == 'LAUNCH_REQUEST')
    response.add_speech('My Deals is running!')
    response.add_hash_card( { title: 'My Deals Run', subtitle: 'My Deals Running!' } )
  end

  if (request.type == 'INTENT_REQUEST')
    case request.name
    when "AccessDeals"
      query = request.slots["DealType"]["value"]
      offer = Access::Offer.search(query: query, member_key: 'TEST12345').first
      if offer
        response.add_speech("Deal find for #{offer.store.name}, #{offer.title}")
        response.add_hash_card( { title: "Deal find for #{offer.store.name}", subtitle: "#{offer.title}" } )
      end
    else
      response.add_speech("I really do not want to help you!")
    end
  end

  if (request.type =='SESSION_ENDED_REQUEST')
    p "#{request.type}"
    p "#{request.reason}"
    halt 200
  end

  response.build_response
end

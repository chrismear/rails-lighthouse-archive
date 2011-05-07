require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class RequestParameterParsingTest < ActiveSupport::TestCase
  
  # Tests the ActionController::UrlEncodedPairParser to make sure it returns the expected result for a more complex request
  # The request string is below, followed by the "k=v" pairs which should be sent to ActionController::UrlEncodedPairParser
  # Finishes by comparing the output of ActionController::UrlEncodedPairParser.new(...).result with what is expected given the input string.
  #  This last step is where the failure occures
  def test_complex_request_string_parse
    request_string = 'authenticity_token=fa80071e23bd38b432c560b5a2d4bfb9665a6a7e' +
      '&email[to_new_contacts][][contact_attributes][first_name]=first'            +
      '&email[to_new_contacts][][contact_attributes][middle_name]=middle'          +
      '&email[to_new_contacts][][contact_attributes][last_name]=last'              +
      '&email[to_new_contacts][][contact_attributes][email]=test%40email.com'      +
      '&email[to_new_contacts][][contact_attributes][birthdate(2i)]=3'             +
      '&email[to_new_contacts][][contact_attributes][birthdate(3i)]=29'            +
      '&email[to_new_contacts][][contact_attributes][birthdate(1i)]=1978'          +
      '&email[to_new_contacts][][contact_attributes][gender]=female'               +
      '&email[to_new_contacts][][relationship]=friend'                             +
                               
      '&email[to_new_contacts][][contact_attributes][first_name]=first2'           +
      '&email[to_new_contacts][][contact_attributes][middle_name]=middle2'         +
      '&email[to_new_contacts][][contact_attributes][last_name]=last2'             +
      '&email[to_new_contacts][][contact_attributes][email]=test2%40email.com'     +
      '&email[to_new_contacts][][contact_attributes][birthdate(2i)]=4'             +
      '&email[to_new_contacts][][contact_attributes][birthdate(3i)]=30'            +
      '&email[to_new_contacts][][contact_attributes][birthdate(1i)]=1979'          +
      '&email[to_new_contacts][][contact_attributes][gender]=female2'              +
      '&email[to_new_contacts][][relationship]=friend2'                            +
      
      '&email[subject]=test'                                                       +
      '&email[body]=body'                                                          +
      '&email[send_at(2i)]=4'                                                      +
      '&email[send_at(3i)]=29'                                                     +
      '&email[send_at(1i)]=2008'                                                   +
      '&email[send_at(4i)]=22'                                                     +
      '&email[send_at(5i)]=22'                                                     +
      '&email[timezone]=America/Los_Angeles'                                       +
      '&save_or_draft=Save As Draft'
    
    expected_pairs = [
      ["authenticity_token", "fa80071e23bd38b432c560b5a2d4bfb9665a6a7e"], 
      ["email[to_new_contacts][][contact_attributes][first_name]", "first"], 
      ["email[to_new_contacts][][contact_attributes][middle_name]", "middle"], 
      ["email[to_new_contacts][][contact_attributes][last_name]", "last"], 
      ["email[to_new_contacts][][contact_attributes][email]", "test@email.com"], 
      ["email[to_new_contacts][][contact_attributes][birthdate(2i)]", "3"], 
      ["email[to_new_contacts][][contact_attributes][birthdate(3i)]", "29"], 
      ["email[to_new_contacts][][contact_attributes][birthdate(1i)]", "1978"], 
      ["email[to_new_contacts][][contact_attributes][gender]", "female"], 
      ["email[to_new_contacts][][relationship]", "friend"], 
      ["email[to_new_contacts][][contact_attributes][first_name]", "first2"], 
      ["email[to_new_contacts][][contact_attributes][middle_name]", "middle2"], 
      ["email[to_new_contacts][][contact_attributes][last_name]", "last2"], 
      ["email[to_new_contacts][][contact_attributes][email]", "test2@email.com"],
      ["email[to_new_contacts][][contact_attributes][birthdate(2i)]", "4"], 
      ["email[to_new_contacts][][contact_attributes][birthdate(3i)]", "30"], 
      ["email[to_new_contacts][][contact_attributes][birthdate(1i)]", "1979"],
      ["email[to_new_contacts][][contact_attributes][gender]", "female2"],
      ["email[to_new_contacts][][relationship]", "friend2"],
      ["email[subject]", "test"],
      ["email[body]", "body"],
      ["email[send_at(2i)]", "4"],
      ["email[send_at(3i)]", "29"],
      ["email[send_at(1i)]", "2008"],
      ["email[send_at(4i)]", "22"],
      ["email[send_at(5i)]", "22"],
      ["email[timezone]", "America/Los_Angeles"],
      ["save_or_draft", "Save As Draft"]
    ]
    
    expected_result = {
      "authenticity_token" => "fa80071e23bd38b432c560b5a2d4bfb9665a6a7e",
      "save_or_draft" => "Save As Draft",
      "email" => {
        "subject" => "test",
        "body" => "body",
        "send_at(2i)" => '4',
        "send_at(3i)" => '29',
        "send_at(1i)" => '2008',
        "send_at(4i)" => '22',
        "send_at(5i)" => '22',
        "timezone" => 'America/Los_Angeles',
        "to_new_contacts" => [
          { "relationship" => 'friend', 
            "contact_attributes" => {
              'first_name' => 'first',
              'middle_name' => 'middle',
              'last_name' => 'last',
              'email' => 'test@email.com',
              'birthdate(2i)' => '3',
              'birthdate(3i)' => '29',
              'birthdate(1i)' => '1978',
              'gender' => 'female'
            }
          },
          
          { "relationship" => 'friend2', 
             "contact_attributes" => {
               'first_name' => 'first2',
               'middle_name' => 'middle2',
               'last_name' => 'last2',
               'email' => 'test2@email.com',
               'birthdate(2i)' => '4',
               'birthdate(3i)' => '30',
               'birthdate(1i)' => '1979',
               'gender' => 'female2'
             }
          }
        ]
        
      }
    }
    
    pairs = parse_query_pairs(request_string)
    assert_equal expected_pairs, pairs
    
    parameters = parse_query_parameters(request_string)
    assert_equal expected_result, parameters
  end
  
  protected 
  
  
  # Direct copy from /actionpack/lib/action_controller/request.rb, except added "ActionController::" before UrlEncodedPairParser
  def parse_query_parameters(query_string)
    return {} if query_string.blank?

    pairs = query_string.split('&').collect do |chunk|
      next if chunk.empty?
      key, value = chunk.split('=', 2)
      next if key.empty?
      value = value.nil? ? nil : CGI.unescape(value)
      [ CGI.unescape(key), value ]
    end.compact

    ActionController::UrlEncodedPairParser.new(pairs).result
  end
  
  # Extracted pairs from #parse_query_parameters to make sure that was as expected
  def parse_query_pairs(query_string)
    return {} if query_string.blank?

    query_string.split('&').collect do |chunk|
      next if chunk.empty?
      key, value = chunk.split('=', 2)
      next if key.empty?
      value = value.nil? ? nil : CGI.unescape(value)
      [ CGI.unescape(key), value ]
    end.compact
  end
end

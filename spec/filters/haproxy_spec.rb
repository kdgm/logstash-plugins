require "./spec/test_utils"

def validate_haproxy_fields
  # fields from haproxy logging
  insist { subject['clientip']             } != nil
  insist { subject['clientport']           } != nil
  insist { subject['timestamp']            } != nil
  insist { subject['frontend_name']        } != nil
  insist { subject['backend_name']         } != nil
  insist { subject['server_name']          } != nil
  insist { subject['time_queue']           } =~ /\A[0-9]*\z/
  insist { subject['time_backend_connect'] } =~ /\A[0-9]*\z/
  insist { subject['time_duration']        } =~ /\A[0-9]*\z/
  insist { subject['bytes']                } =~ /\A[0-9]*\z/
  insist { subject['termination_state']    } != nil
  insist { subject['actconn']              } =~ /\A[0-9]*\z/
  insist { subject['feconn']               } =~ /\A[0-9]*\z/
  insist { subject['beconn']               } =~ /\A[0-9]*\z/
  insist { subject['srvconn']              } =~ /\A[0-9]*\z/
  insist { subject['retries']              } =~ /\A[0-9]*\z/
  insist { subject['srv_queue']            } =~ /\A[0-9]*\z/
end

def validate_haproxy_http_fields
  # fields specific for haproxy http backends
  insist { subject['time_request']             } =~ /\A[0-9]*\z/
  insist { subject['time_backend_response']    } =~ /\A[0-9]*\z/
  insist { subject['response']                 } =~ /\A[0-9]*\z/
  insist { subject['captured_request_cookie']  } != nil
  insist { subject['captured_response_cookie'] } != nil
  insist { subject['http_proto']               } == nil
  insist { subject['http_user']                } == nil
  insist { subject['http_host']                } == nil
  insist { subject['verb']                     } != nil
  insist { subject['request']                  } != nil
  insist { subject['icecast_proto']            } != nil
  insist { subject['http_version']             } != nil
end

shared_examples "a valid haproxy log parser" do

  sample %(46.145.191.22:51472 [19/Sep/2014:14:39:44.501] icecast servers-http/audio-aurum 535/0/1/25/50561 200 19 - - cD-- 44/44/44/7/0 0/0 "SOURCE /10403011 ICE/1.0") do
    insist { subject['tags'] }.include? 'haproxy_icey'
    insist { subject['tags'] }.include? 'haproxy_timestamp'
    insist { subject['tags'] & %w(_grokparsefailure) } == []
    insist { subject['tags'] & %w(billable) } == []

    insist { subject['clientip'] }   == '46.145.191.22'
    insist { subject['clientport'] } == '51472'

    insist { subject['frontend_name'] } == 'icecast'
    insist { subject['backend_name']  } == 'servers-http'
    insist { subject['server_name']   } == 'audio-aurum'

    insist { subject['bytes'] }    == '19'
    insist { subject['response'] } == '200'

    insist { subject['timestamp'] } == '19/Sep/2014:14:39:44.501'
    insist { subject['logsource'] } == 'haproxy-audio-lb-test'

    validate_haproxy_fields
    validate_haproxy_http_fields
  end

  sample %(54.255.254.198:61852 [01/May/2015:11:10:17.902] lb-wowza servers/video-sunfire 0/0/201 296 -- 1/1/1/1/0 0/0) do
    insist { subject['tags'] }.include? 'haproxy_icey'
    insist { subject['tags'] }.include? 'haproxy_timestamp'
    insist { subject['tags'] & %w(_grokparsefailure) } == []
    insist { subject['tags'] & %w(billable) } == []

    insist { subject['clientip'] }   == '54.255.254.198'
    insist { subject['clientport'] } == '61852'

    insist { subject['frontend_name'] } == 'lb-wowza'
    insist { subject['backend_name']  } == 'servers'
    insist { subject['server_name']   } == 'video-sunfire'

    # insist { subject['bytes'] }    == '19'
    # insist { subject['response'] } == '200'

    insist { subject['timestamp'] } == '01/May/2015:11:10:17.902'
    insist { subject['logsource'] } == 'haproxy-audio-lb-test'

    validate_haproxy_fields
  end

end

describe "haproxy filters" do

  extend LogStash::RSpec

  describe "with default config" do
    let(:parse_failure_tag) { '_grokparsefailure'}

    fields \
      'type'    => 'syslog',
      'program' => 'haproxy',
      'host'    => 'audio-lb-test'

    # type 'syslog'
    config [ 'filter{', File.read("conf.d/40_haproxy.conf"), '}' ].join

    it_behaves_like "a valid haproxy log parser"
  end

end

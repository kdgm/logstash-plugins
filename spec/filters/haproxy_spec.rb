require "./spec/test_utils"

def validate_haproxy_fields

  # fields from haproxy_ACCESS_LOG
  insist { subject['clientip']                 } != nil
  insist { subject['clientport']               } != nil
  insist { subject['timestamp']                } != nil
  insist { subject['frontend_name']            } != nil
  insist { subject['backend_name']             } != nil
  insist { subject['server_name']              } != nil
  insist { subject['time_request']             } =~ /\A[0-9]*\z/
  insist { subject['time_queue']               } =~ /\A[0-9]*\z/
  insist { subject['time_backend_connect']     } =~ /\A[0-9]*\z/
  insist { subject['time_backend_response']    } =~ /\A[0-9]*\z/
  insist { subject['time_duration']            } =~ /\A[0-9]*\z/
  insist { subject['response']                 } =~ /\A[0-9]*\z/
  insist { subject['bytes']                    } =~ /\A[0-9]*\z/
  insist { subject['captured_request_cookie']  } != nil
  insist { subject['captured_response_cookie'] } != nil
  insist { subject['termination_state']        } != nil
  insist { subject['actconn']                  } =~ /\A[0-9]*\z/
  insist { subject['feconn']                   } =~ /\A[0-9]*\z/
  insist { subject['beconn']                   } =~ /\A[0-9]*\z/
  insist { subject['srvconn']                  } =~ /\A[0-9]*\z/
  insist { subject['retries']                  } =~ /\A[0-9]*\z/
  insist { subject['srv_queue']                } =~ /\A[0-9]*\z/
  insist { subject['verb']                     } != nil
  # insist { subject['http_proto']               } != nil
  # insist { subject['http_user']                     } != nil
  # insist { subject['http_host']                } != nil
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

    insist { subject['bytes'] } == '19'
    insist { subject['response'] } == '200'

    insist { subject['timestamp'] } == '19/Sep/2014:14:39:44.501'
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

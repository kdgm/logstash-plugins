require "./spec/test_utils"

def validate_icecast_fields

  # fields from ICECAST_ACCESS_LOG
  insist { subject['clientip']    } != nil
  insist { subject['ident']       } != nil
  insist { subject['auth']        } != nil
  insist { subject['timestamp']   } != nil
  insist { subject['verb']        } != nil
  insist { subject['request']     } != nil
  insist { subject['httpversion'] } != nil
  insist { subject['response']    } =~ /\A[0-9]*\z/
  insist { subject['bytes']       } =~ /\A[0-9]*\z/
  insist { subject['referrer']    } != nil
  insist { subject['agent']       } != nil
  insist { subject['duration']    } =~ /\A[0-9]*\z/
end

def validate_188_203_183_17_request
  insist { subject['tags'] & %w(_grokparsefailure) } == []
  insist { subject['tags'] }.include? 'icecast_access_log'
  insist { subject['tags'] }.include? 'access_log_timestamp'
  insist { subject['tags'] }.include? 'billable'
  insist { subject['tags'] }.include? 'import' unless nil == subject['path']

  insist { subject['bytes'] }       == '6918967'
  insist { subject['response'] }    == '200'
  insist { subject['timestamp'] }   == '03/May/2015:08:49:19 +0200'
  insist { subject['logsource'] }   == 'audio-test'
  insist { subject['verb'] }        == 'SOURCE'
  insist { subject['request'] }     == '/10818001'
  insist { subject['clientip'] }    == '188.203.183.17'
  insist { subject['auth'] }        == 'source'
  insist { subject['httpversion'] } == '1.0'
  insist { subject['referrer'] }    == '"-"'
  insist { subject['agent'] }       == '"DarkIce/0.18.1 (http://darkice.tyrell.hu/)"'
  insist { subject['duration'] }    == '2338'

  insist { subject['fingerprint'] } == '8714b2dd78009775d033d5acfdc02523'
end

shared_examples "a valid icecast log parser" do

  sample %(89.99.28.243 - 2cf7e6b063 [19/Sep/2014:06:57:05 +0000] "GET /11723021/2014-09-17-1430.mp3?Signature=BanH0VrdfI%2FXCouvXFXivLBS2PE%3D&Expires=1411116501&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 304 1000 "-" "AppleCoreMedia/1.0.0.11B554a (iPad; U; CPU OS 7_0_4 like Mac OS X; nl_nl)" 0) do

    insist { subject['tags'] & %w(_grokparsefailure) } == []
    insist { subject['tags'] }.include? 'icecast_access_log'
    insist { subject['tags'] }.include? 'access_log_timestamp'
    insist { subject['tags'] }.include? 'billable'
    insist { subject['bytes'] } == '1000'
    insist { subject['response'] } == '304'
    insist { subject['timestamp'] } == '19/Sep/2014:06:57:05 +0000'
    insist { subject['syslog_timestamp'] } == '2015-05-06T12:33:28.495+02:00'
    insist { subject['logsource'] } == 'audio-test'

    validate_icecast_fields
  end

  sample %(89.99.23.76 - - [19/Sep/2014:11:39:31 +0200] "GET /10103060?type=live.mp3 HTTP/1.1" 200 17279640 "http://assets.kerkdienstgemist.nl/player/jw6/6.4.3359/jwplayer.flash.swf"; "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko" 5754) do
    insist { subject['tags'] & %w(_grokparsefailure) } == []
    insist { subject["tags"] }.include? 'icecast_access_log'

    validate_icecast_fields
  end

  sample %(188.203.183.17 - source [03/May/2015:08:49:19 +0200] "SOURCE /10818001 HTTP/1.0" 200 6918967 "-" "DarkIce/0.18.1 (http://darkice.tyrell.hu/)" 2338) do
    validate_icecast_fields
    validate_188_203_183_17_request
  end

end

shared_examples "a valid icecast log message" do

end

describe "Icecast filters" do

  extend LogStash::RSpec

  describe "with default config" do
    let(:parse_failure_tag) { '_grokparsefailure'}

    fields \
      'type'      => 'syslog',
      'program'   => 'icecast.access.log',
      'logsource' => 'audio-test',
      'timestamp' => '2015-05-06T12:33:28.495+02:00'

    # type 'syslog'
    config [
      'filter{',
        File.read("conf.d/10_drop.conf"),
        File.read("conf.d/50_icecast.conf"),
      '}'
    ].join("\n")

    it_behaves_like "a valid icecast log parser"
  end

  describe "from syslog" do
    let(:parse_failure_tag) { '_grokparsefailure'}

    fields \
      'type'      => 'syslog',
      'program'   => 'icecast.access.log',
      'logsource' => 'audio-test',
      'timestamp' => '2015-05-06T12:33:28.495+02:00'

    config [
      'filter{',
        File.read("conf.d/10_drop.conf"),
        File.read("conf.d/45_import_icecast.conf"),
        File.read("conf.d/50_icecast.conf"),
      '}'
    ].join("\n")

    it_behaves_like "a valid icecast log parser"

    sample %(188.203.183.17 - source [03/May/2015:08:49:19 +0200] "SOURCE /10818001 HTTP/1.0" 200 6918967 "-" "DarkIce/0.18.1 (http://darkice.tyrell.hu/)" 2338) do
      insist { subject['syslog_timestamp'] } == '2015-05-06T12:33:28.495+02:00'
    end

  end

  describe "import from icecast file" do
    let(:parse_failure_tag) { '_grokparsefailure'}

    fields \
      'type'      => 'import_icecast',
      'path'      => 'audio-test.log',
      'timestamp' => '2015-05-06T12:33:28.495+02:00'

    config [
      'filter{',
        File.read("conf.d/10_drop.conf"),
        File.read("conf.d/45_import_icecast.conf"),
        File.read("conf.d/50_icecast.conf"),
      '}'
    ].join("\n")

    it_behaves_like "a valid icecast log parser"

    sample %(188.203.183.17 - source [03/May/2015:08:49:19 +0200] "SOURCE /10818001 HTTP/1.0" 200 6918967 "-" "DarkIce/0.18.1 (http://darkice.tyrell.hu/)" 2338) do
      insist { subject['syslog_timestamp'] } == '2015-05-06T12:33:28.495+02:00'
    end

  end

end

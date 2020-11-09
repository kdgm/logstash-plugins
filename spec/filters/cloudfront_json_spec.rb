require './spec/test_utils'

VODCDN_SESSION_SAMPLE = JSON.parse(<<JSON_DOC
  {
    "_index": "cloudfront_sessions-20201026",
    "_type": "_doc",
    "_id": "24.132.188.152|+|GET|+|/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4|+|HTTP/2.0|+|200...",
    "_score": 1,
    "_source": {
      "start_time": "2020-10-26T00:13:53.000+0000",
      "end_time": "2020-10-26T00:14:16.000+0000",
      "clientip": "24.132.188.152",
      "verb": "GET",
      "request": "/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4",
      "protocol": "HTTP/2.0",
      "response": "200",
      "agent": "AppleCoreMedia/1.0.0.16G201 (iPad; U; CPU OS 12_4_8 like Mac OS X; nl_nl)",
      "referrer": [
        "https://kerkdienstgemist.nl/stations/1419/events/recording/160232040001419"
      ],
      "session_id": "24.132.188.152#GET#/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4#HTTP/2.0#200#1603671233000#1603671256000",
      "bytes": 42048967,
      "duration": 23,
      "logsource": [
        "AMS50-C1"
      ],
      "kbps": 14282,
      "hls": {
        "playlist": 1,
        "chunklist": 2,
        "media": 16
      },
      "count": 19
    }
  }
JSON_DOC
)

describe 'Cloudfront filter', if: RUBY_ENGINE == 'jruby' do
  extend LogStash::RSpec

  describe 'with default config' do
    let(:parse_failure_tag) { '_s3parsefailure' }

    fields \
      'type' => 'cloudfront_session',
      'host' => 'cf-logging',
      'codec' => 'json'

    config <<-CONFIG
      filter{
        #{File.read('conf.d/80_cloudfront_json.conf')}
      }
    CONFIG

    sample(VODCDN_SESSION_SAMPLE) do
      # fix time to specific point in time
      allow(Time).to receive(:now).and_return(Time.parse('2020-11-04T00:04:10.000+0000'))

      # ruby filter specs
      insist { subject['received_at'] }  == Time.now
      insist { subject['kafka_key'] }    == '24.132.188.152|+|GET|+|/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4|+|HTTP/2.0|+|200...'
      insist { subject['source_index'] } == 'cloudfront_sessions-20201026'
      insist { subject['start_time'] }   == '2020-10-26T00:13:53.000+0000'
      insist { subject['end_time'] }     == '2020-10-26T00:14:16.000+0000'
      insist { subject['clientip'] }     == '24.132.188.152'
      insist { subject['verb'] }         == 'GET'
      insist { subject['request'] }      == '/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4'
      insist { subject['protocol'] }     == 'HTTP/2.0'
      insist { subject['response'] }     == '200'
      insist { subject['agent'] }        == 'AppleCoreMedia/1.0.0.16G201 (iPad; U; CPU OS 12_4_8 like Mac OS X; nl_nl)'
      insist { subject['referrer'] }     == ['https://kerkdienstgemist.nl/stations/1419/events/recording/160232040001419']
      insist { subject['bytes'] }        == 42_048_967
      insist { subject['duration'] }     == 23
      insist { subject['logsource'] }    == ['AMS50-C1']
      insist { subject['kbps'] }         == 14_282
      insist { subject['hls'] }          == { 'playlist' => 1, 'chunklist' => 2, 'media' => 16 }
      insist { subject['count'] }        == 19

      # parses end_time into @timstamp
      insist { subject['@timestamp'] } == Time.parse('2020-10-26T00:14:16.000+0000')

      # adds program field
      insist { subject['program'] } == 'cloudfront.sessions.log'

      # adds a message field containing Apache Common Log format version of the log line
      insist { subject['message'] } == \
        '24.132.188.152 - - [26/Oct/2020:01:14:16 +0100] "GET /vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4 HTTP/2.0" 200 42048967 "https://kerkdienstgemist.nl/stations/1419/events/recording/160232040001419" "AppleCoreMedia/1.0.0.16G201 (iPad; U; CPU OS 12_4_8 like Mac OS X; nl_nl)" 23 hls=1/2/16/19'
      insist { subject['httpdate'] } == nil

      # httpversion from protocol
      insist { subject['httpversion'] } == '2.0'

      # adds appropriate tag
      insist { subject['tags'] } == %w[cloudfront_timestamp billable geoip protocol]

      # check geoip info
      insist { subject['geoip'] } == {
        'ip' => '24.132.188.152',
        'country_code' => 161,
        'country_code2' => 'NL',
        'country_code3' => 'NLD',
        'country_name' => 'Netherlands',
        'continent_code' => 'EU'
      }

      # adds correct fingerprint (based on kafka_key)
      insist { subject['fingerprint'] } == 'd0defb65dc12fa4c8636ef9de0493462'
    end
  end
end

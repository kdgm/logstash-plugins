require './spec/test_utils'

def validate_cloudfront_json_fields

  # # fields from S3_ACCESS_LOG
  # insist { subject['owner']              } != nil
  # insist { subject['bucket']             } != nil
  # insist { subject['timestamp']          } != nil
  # insist { subject['remote_ip']          } != nil
  # insist { subject['requester']          } != nil
  # insist { subject['request_id']         } != nil
  # insist { subject['operation']          } != nil
  # insist { subject['key']                } != nil
  # insist { subject['request_uri']        } != nil
  # insist { subject['http_status']        } =~ /\A[0-9]*\z/
  # insist { subject['bytes']              } =~ /\A[0-9]*\z/
  # insist { subject['object_size']        } != nil
  # insist { subject['total_time_ms']      } != nil
  # insist { subject['turnaround_time_ms'] } != nil
  # insist { subject['referrer']           } != nil
  # insist { subject['agent']              } != nil

  # # fields from S3_REQUEST_LINE
  # insist { subject['verb']               } != nil
  # insist { subject['request']            } != nil
  # insist { subject['httpversion']        } != nil
end

JSON_SAMPLE = JSON.parse(<<JSON_DOC
  {
    "_index": "cloudfront_sessions-20201026",
    "_type": "_doc",
    "_id": "24.132.188.152|+|GET|+|/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4|+|HTTP/2.0|+|200...",
    "_score": 1,
    "_source": {
      "session_start": "2020-10-26T00:13:53.000+0000",
      "timestamp": "2020-10-26T00:14:16.000+0000",
      "clientip": "24.132.188.152",
      "verb": "GET",
      "request": "/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4",
      "protocol": "HTTP/2.0",
      "response": "200",
      "agent": [
        "AppleCoreMedia/1.0.0.16G201 (iPad; U; CPU OS 12_4_8 like Mac OS X; nl_nl)"
      ],
      "referer": [
        "https://kerkdienstgemist.nl/stations/1419/events/recording/160232040001419"
      ],
      "session_id": "24.132.188.152#GET#/vodcdn/_definst_/mp4:amazons3/media.kerkdienstgemist.nl/90311151-v1520373/20201010085600_15620922-mp4.mp4#HTTP/2.0#200#1603671233000#1603671256000",
      "bytes": 42048967,
      "duration": 23,
      "logsource": [
        "AMS50-C1"
      ],
      "kbps": 14282,
      "hls_files": {
        "playlist": 1,
        "chunklist": 1,
        "media": 16
      },
      "count": 18
    }
  }
JSON_DOC
)

shared_examples "adds a fingerprint" do
  sample(JSON_SAMPLE) do
    insist { subject['fingerprint'] } == 'a9aa8922a71d35ea026c8fb39344acaf'
  end
end

shared_examples 'converts Cloudfront JSON sessions into Apache CLF format' do

  sample(JSON_SAMPLE) do
    insist { subject['_source']['logsource'] } == ['AMS50-C1']

    # validate_cloudfront_json_fields
  end

end

describe 'Cloudfront filter' do
  extend LogStash::RSpec

  describe 'with default config' do

    let(:parse_failure_tag) { '_s3parsefailure'}

    fields \
      'type'  => 'cloudfront_json',
      'host'  => 'cf-logging',
      'codec' => 'json'

    config ['filter{', File.read('conf.d/80_cloudfront_json.conf'), '}'].join

    it_behaves_like 'adds a fingerprint'
    it_behaves_like 'converts Cloudfront JSON sessions into Apache CLF format'
  end

end

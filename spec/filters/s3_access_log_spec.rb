require "./spec/test_utils"
require "logstash/filters/s3_access_log"

shared_examples "converts valid S3 Server Access Log lines into Apache CLF format" do

  sample(%(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -")) do
    insist { subject["message"] } == "77.168.122.24 - 2cf7e6b063 [24/Mar/2013:10:22:56 +0000] \"GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 200 18547033 \"http://kerkdienstgemist.nl/mp3/recorder.php?id=452\" \"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)\" 17"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:44:26 +0000] 10.1.155.11 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 2B8A7289376A942E REST.GET.LOGGING_STATUS - "GET /n-e-w-legacy?logging HTTP/1.1" 200 - 239 - 8 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.1.155.11 - 9ab8c38136 [04/Jun/2012:16:44:26 +0000] \"GET /n-e-w-legacy?logging HTTP/1.1\" 200 239 \"-\" \"S3Console/0.4\" 0"
  end 

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:44:26 +0000] 10.2.7.13 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 F5FB585AB1B363ED REST.GET.BUCKET - "GET /n-e-w-legacy?prefix=&max-keys=100&marker=&delimiter=/ HTTP/1.1" 200 - 434 - 35 35 "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.2.7.13 - 9ab8c38136 [04/Jun/2012:16:44:26 +0000] \"GET /n-e-w-legacy?prefix=&max-keys=100&marker=&delimiter=/ HTTP/1.1\" 200 434 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:45:41 +0000] 10.2.7.13 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 69C2C9367ECAF74E REST.GET.NOTIFICATION - "GET /n-e-w-legacy?notification HTTP/1.1" 200 - 115 - 7 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.2.7.13 - 9ab8c38136 [04/Jun/2012:16:45:41 +0000] \"GET /n-e-w-legacy?notification HTTP/1.1\" 200 115 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:46:31 +0000] 10.2.7.13 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 09517C14877D2976 REST.GET.LOGGING_STATUS - "GET /n-e-w-legacy?logging HTTP/1.1" 200 - 239 - 7 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.2.7.13 - 9ab8c38136 [04/Jun/2012:16:46:31 +0000] \"GET /n-e-w-legacy?logging HTTP/1.1\" 200 239 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:46:31 +0000] 10.3.77.81 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 8132F75D0BDCFF70 REST.GET.LIFECYCLE - "GET /n-e-w-legacy?lifecycle HTTP/1.1" 404 NoSuchLifecycleConfiguration 313 - 28 28 "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.3.77.81 - 9ab8c38136 [04/Jun/2012:16:46:31 +0000] \"GET /n-e-w-legacy?lifecycle HTTP/1.1\" 404 313 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:44:26 +0000] 10.1.155.11 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 2B8A7289376A942E REST.GET.LOGGING_STATUS - "GET /n-e-w-legacy?logging HTTP/1.1" 200 - 239 - 8 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.1.155.11 - 9ab8c38136 [04/Jun/2012:16:44:26 +0000] \"GET /n-e-w-legacy?logging HTTP/1.1\" 200 239 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:44:26 +0000] 10.2.7.13 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 F5FB585AB1B363ED REST.GET.BUCKET - "GET /n-e-w-legacy?prefix=&max-keys=100&marker=&delimiter=/ HTTP/1.1" 200 - 434 - 35 35 "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.2.7.13 - 9ab8c38136 [04/Jun/2012:16:44:26 +0000] \"GET /n-e-w-legacy?prefix=&max-keys=100&marker=&delimiter=/ HTTP/1.1\" 200 434 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:45:41 +0000] 10.2.7.13 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 69C2C9367ECAF74E REST.GET.NOTIFICATION - "GET /n-e-w-legacy?notification HTTP/1.1" 200 - 115 - 7 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.2.7.13 - 9ab8c38136 [04/Jun/2012:16:45:41 +0000] \"GET /n-e-w-legacy?notification HTTP/1.1\" 200 115 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:46:31 +0000] 10.2.7.13 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 09517C14877D2976 REST.GET.LOGGING_STATUS - "GET /n-e-w-legacy?logging HTTP/1.1" 200 - 239 - 7 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.2.7.13 - 9ab8c38136 [04/Jun/2012:16:46:31 +0000] \"GET /n-e-w-legacy?logging HTTP/1.1\" 200 239 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:46:31 +0000] 10.3.77.81 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 8132F75D0BDCFF70 REST.GET.LIFECYCLE - "GET /n-e-w-legacy?lifecycle HTTP/1.1" 404 NoSuchLifecycleConfiguration 313 - 28 28 "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.3.77.81 - 9ab8c38136 [04/Jun/2012:16:46:31 +0000] \"GET /n-e-w-legacy?lifecycle HTTP/1.1\" 404 313 \"-\" \"S3Console/0.4\" 0"
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 assets.staging.kerkdienstgemist.nl [10/Feb/2010:07:17:01 +0000] 10.32.219.38 3272ee65a908a7677109fedda345db8d9554ba26398b2ca10581de88777e2b61 784FD457838EFF42 REST.GET.ACL - "GET /?acl HTTP/1.1" 200 - 1384 - 399 - "-" "Jakarta Commons-HttpClient/3.0" -) do
    insist { subject["message"] } == '10.32.219.38 - 3272ee65a9 [10/Feb/2010:07:17:01 +0000] "GET /?acl HTTP/1.1" 200 1384 "-" "Jakarta Commons-HttpClient/3.0" 0'
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 assets.staging.kerkdienstgemist.nl [10/Feb/2010:07:17:02 +0000] 10.32.219.38 3272ee65a908a7677109fedda345db8d9554ba26398b2ca10581de88777e2b61 6E239BC5A4AC757C SOAP.PUT.OBJECT logs/2010-02-10-07-17-02-F6EFD00DAB9A08B6 "POST /soap/ HTTP/1.1" 200 - 797 686 63 31 "-" "Axis/1.3" -) do
    insist { subject["message"] } == %(10.32.219.38 - 3272ee65a9 [10/Feb/2010:07:17:02 +0000] "POST /soap/ HTTP/1.1" 200 797 "-" "Axis/1.3" 0)
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 assets.staging.kerkdienstgemist.nl [10/Feb/2010:07:24:40 +0000] 10.217.37.15 - 0B76C90B3634290B REST.GET.ACL - "GET /?acl HTTP/1.1" 307 TemporaryRedirect 488 - 7 - "-" "Jakarta Commons-HttpClient/3.0" -) do
    insist { subject["message"] } == %(10.217.37.15 - - [10/Feb/2010:07:24:40 +0000] "GET /?acl HTTP/1.1" 307 488 "-" "Jakarta Commons-HttpClient/3.0" 0)
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [09/Sep/2014:18:33:15 +0000] 79.125.24.185 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 5E493280357FAC3B REST.COPY.OBJECT 10518050/2014-08-31-0930.mp3 "PUT /10518050/2014-08-31-0930.mp3 HTTP/1.1" 200 - 234 16251603 723 27 "-" "-" -) do
    insist { subject["message"] } == "79.125.24.185 - 2cf7e6b063 [09/Sep/2014:18:33:15 +0000] \"PUT /10518050/2014-08-31-0930.mp3 HTTP/1.1\" 200 234 \"-\" \"-\" 1"
  end
end

shared_examples "rejects invalid log lines" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452"" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -) do
    # message unmodified with error tag
    insist { subject["message"] } == %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452"" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -)
    insist { subject["tags"] }.include?(parse_failure_tag)
  end

end

shared_examples "convert REST.COPY.OBJECT_GET to POST" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.staging.kerkdienstgemist.nl [17/Sep/2010:13:38:36 +0000] 85.113.244.146 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 71F7D2AAA93B0A05 REST.COPY.OBJECT_GET 10010150/2010-08-29-0930.mp3 - 200 - - 13538337 - - - - -) do
    insist { subject["message"] } == %(85.113.244.146 - 2cf7e6b063 [17/Sep/2010:13:38:36 +0000] "POST /10010150/2010-08-29-0930.mp3 HTTP/1.1" 200 - "REST.COPY.OBJECT_GET" "-" 0)
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.staging.kerkdienstgemist.nl [17/Sep/2010:13:38:37 +0000] 85.113.244.146 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 7CC5E3D09AE78CAE REST.COPY.OBJECT_GET 10010150/2010-09-05-1000.mp3 - 200 - - 9860402 - - - - -) do
    insist { subject["message"] } == %(85.113.244.146 - 2cf7e6b063 [17/Sep/2010:13:38:37 +0000] "POST /10010150/2010-09-05-1000.mp3 HTTP/1.1" 200 - "REST.COPY.OBJECT_GET" "-" 0)
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [09/Sep/2014:18:33:15 +0000] 79.125.24.185 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 5E493280357FAC3B REST.COPY.OBJECT_GET 10518050/upload/f0a2c702d58183844b064eb49f8b795d.mp3 - 200 - - 16251603 - - - - -) do
    insist { subject["message"] } == "79.125.24.185 - 2cf7e6b063 [09/Sep/2014:18:33:15 +0000] \"POST /10518050/upload/f0a2c702d58183844b064eb49f8b795d.mp3 HTTP/1.1\" 200 - \"REST.COPY.OBJECT_GET\" \"-\" 0"
  end

end

shared_examples "recalculate partial content" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [02/Oct/2010:18:29:16 +0000] 82.168.113.55 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 4F911681022807C6 REST.GET.OBJECT 10028050/2010-09-26-1830.mp3 "GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1" 206 - 4194304 17537676 1600 12 "-" "VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team" -) do
    insist { subject["message"] } == "82.168.113.55 - 2cf7e6b063 [02/Oct/2010:18:29:16 +0000] \"GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1\" 206 135872 \"-\" \"VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team\" 2"
  end

end

shared_examples "don't recalculate partial content" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [02/Oct/2010:18:29:16 +0000] 82.168.113.55 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 4F911681022807C6 REST.GET.OBJECT 10028050/2010-09-26-1830.mp3 "GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1" 206 - 4194304 17537676 1600 12 "-" "VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team" -) do
    insist { subject["message"] } == "82.168.113.55 - 2cf7e6b063 [02/Oct/2010:18:29:16 +0000] \"GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1\" 206 4194304 \"-\" \"VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team\" 2"
  end

end

shared_examples "drop REST.COPY_OBJECT_GET" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [09/Sep/2014:18:33:15 +0000] 79.125.24.185 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 5E493280357FAC3B REST.COPY.OBJECT_GET 10518050/upload/f0a2c702d58183844b064eb49f8b795d.mp3 - 200 - - 16251603 - - - - -) do
    insist { subject }.nil?
  end

end

#
# Equivalent config with grok (S3_ACCESS_LOG) and standard filters.
# The s3_access_log filter is more that six times faster.
#
# S3_REQUEST_LINE (?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})
# S3_ACCESS_LOG %{WORD:owner} %{NOTSPACE:bucket} \[%{HTTPDATE:timestamp}\] %{IP:clientip} %{NOTSPACE:requester} %{NOTSPACE:request_id} %{NOTSPACE:operation} %{NOTSPACE:key} (?:"%{S3_REQUEST_LINE:request_uri}"|-) (?:%{INT:response}|-) (?:-|%{NOTSPACE:error_code}) (?:%{INT:bytes}|-) (?:%{INT:object_size}|-) (?:%{INT:request_time_ms}|-) (?:%{INT:turnaround_time_ms}|-) (?:%{QS:referrer}|-) (?:"?%{QS:agent}"?|-) (?:-|%{NOTSPACE:version_id})
#
describe LogStash::Filters::S3AccessLog do
  extend LogStash::RSpec

  describe "with default config" do

    let(:parse_failure_tag) { '_s3parsefailure'}

    config <<-CONFIG
      filter {
        s3_access_log { }
      }
    CONFIG

    it_behaves_like "converts valid S3 Server Access Log lines into Apache CLF format"
    it_behaves_like "rejects invalid log lines"
    it_behaves_like "convert REST.COPY.OBJECT_GET to POST"
    it_behaves_like "don't recalculate partial content"
  end

  describe "with recalculate_partial_content set to true" do
    config <<-CONFIG
    filter {
      s3_access_log {
        recalculate_partial_content => true
      }
    }
    CONFIG

    it_behaves_like "recalculate partial content"
  end

  describe "with copy_operation set to 'drop'" do
    config <<-CONFIG
      filter {
        s3_access_log {
          copy_operation => 'drop'
        }
      }
    CONFIG

    it_behaves_like "drop REST.COPY_OBJECT_GET"
  end

end

describe "Logstash grok and filter solution" do
  extend LogStash::RSpec

  describe "with default config" do
    let(:parse_failure_tag) { '_grokparsefailure'}

    config <<-CONFIG
      filter {
       mutate {
          'rename' => ['@timestamp', 'received_at']
        }
        grok {
          'patterns_dir' => './patterns'
          'match' => [ 'message', '%{S3_ACCESS_LOG}' ]
          'add_tag' => 's3_access_log'
        }
        if 's3_access_log' in [tags] {
          if 'REST.COPY.OBJECT_GET' == [operation] {
            # mutate {} or drop {}
            mutate {
              'replace' => [ 'request_uri', 'POST /%{key} HTTP/1.1', 'referrer', '"%{operation}"', 'bytes', '-', 'agent', '"-"', 'duration', '0' ]
            }
          }
          ruby { code => "event['requester'] && event['requester'] = event['requester'][0..9]" }
          ruby { code => "event['request_time_ms'] && event['duration'] = (event['request_time_ms'].to_f / 1000.0).round" }
          if [response] == '206' {
            noop {}
          }
          mutate {
            'replace' => [ 'message', '%{clientip} - %{requester} [%{timestamp}] "%{request_uri}" %{response} %{bytes} %{referrer} %{agent} %{duration}']
          }
        }
      }
    CONFIG

    it_behaves_like "converts valid S3 Server Access Log lines into Apache CLF format"
    it_behaves_like "rejects invalid log lines"
    it_behaves_like "convert REST.COPY.OBJECT_GET to POST"
    it_behaves_like "don't recalculate partial content"
  end

  describe "with recalculate_partial_content set to true" do

    config <<-CONFIG
      filter {
       mutate {
          'rename' => ['@timestamp', 'received_at']
        }
        grok {
          'patterns_dir' => './patterns'
          'match' => [ 'message', '%{S3_ACCESS_LOG}' ]
          'add_tag' => 's3_access_log'
        }
        if 's3_access_log' in [tags] {
          if 'REST.COPY.OBJECT_GET' == [operation] {
            mutate {
              'replace' => [ 'request_uri', 'POST /%{key} HTTP/1.1', 'referrer', '"%{operation}"', 'bytes', '-', 'agent', '"-"', 'duration', '0' ]
            }
          }
          ruby { code => "event['requester'] && event['requester'] = event['requester'][0..9]" }
          ruby { code => "event['request_time_ms'] && event['duration'] = (event['request_time_ms'].to_f / 1000.0).round" }
          if [response] == '206' {
            ruby { code => "event['bytes'] = [ 128 * 1024 + 3 * event['request_time_ms'].to_i, event['bytes'].to_i ].min if ((event['bytes'].to_i*8)/event['request_time_ms'].to_i > 2000)" }
          }
          mutate {
            'replace' => [ 'message', '%{clientip} - %{requester} [%{timestamp}] "%{request_uri}" %{response} %{bytes} %{referrer} %{agent} %{duration}']
          }
        }
      }
    CONFIG

    it_behaves_like "recalculate partial content"
  end

  describe "with copy_operation set to 'drop'" do
    config <<-CONFIG
      filter {
       mutate {
          'rename' => ['@timestamp', 'received_at']
        }
        grok {
          'patterns_dir' => './patterns'
          'match' => [ 'message', '%{S3_ACCESS_LOG}' ]
          'add_tag' => 's3_access_log'
        }
        if 's3_access_log' in [tags] {
          if 'REST.COPY.OBJECT_GET' == [operation] {
            drop {}
          }
          ruby { code => "event['requester'] && event['requester'] = event['requester'][0..9]" }
          ruby { code => "event['request_time_ms'] && event['duration'] = (event['request_time_ms'].to_f / 1000.0).round" }
          if [response] == '206' {
            ruby { code => "event['bytes'] = [ 128 * 1024 + 3 * event['request_time_ms'].to_i, event['bytes'].to_i ].min if ((event['bytes'].to_i*8)/event['request_time_ms'].to_i > 2000)" }
          }
          mutate {
            'replace' => [ 'message', '%{clientip} - %{requester} [%{timestamp}] "%{request_uri}" %{response} %{bytes} %{referrer} %{agent} %{duration}']
          }
        }
      }
    CONFIG

    it_behaves_like "drop REST.COPY_OBJECT_GET"
  end

end

require "./spec/test_utils"

def validate_s3_fields

  # fields from S3_ACCESS_LOG
  insist { subject['owner']              } != nil
  insist { subject['bucket']             } != nil
  insist { subject['timestamp']          } != nil
  insist { subject['remote_ip']          } != nil
  insist { subject['requester']          } != nil
  insist { subject['request_id']         } != nil
  insist { subject['operation']          } != nil
  insist { subject['key']                } != nil
  insist { subject['request_uri']        } != nil
  insist { subject['http_status']        } =~ /\A[0-9]*\z/
  insist { subject['bytes']              } =~ /\A[0-9]*\z/
  insist { subject['object_size']        } != nil
  insist { subject['total_time_ms']      } != nil
  insist { subject['turnaround_time_ms'] } != nil
  insist { subject['referrer']           } != nil
  insist { subject['agent']              } != nil

  # fields from S3_REQUEST_LINE
  insist { subject['verb']               } != nil
  insist { subject['request']            } != nil
  insist { subject['httpversion']        } != nil
end

def validate_s3_request_uri_fields
  insist { subject['clientip']           } != nil
  insist { subject['response']           } != nil
  insist { subject['httpversion']        } != nil
end

shared_examples "converts valid S3 Server Access Log lines into Apache CLF format" do

  sample(%(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -)) do
    insist { subject["message"] } == "77.168.122.24 - 2cf7e6b063 [24/Mar/2013:10:22:56 +0000] \"GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 200 18547033 \"http://kerkdienstgemist.nl/mp3/recorder.php?id=452\" \"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)\" 17"
    insist { subject["tags"] }.include? 's3_timestamp'
    insist { subject["tags"] }.include? 'billable'
    insist { subject["timestamp"] } == '24/Mar/2013:10:22:56 +0000'
    insist { subject["s3_message"] } == %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -)
    insist { subject['error_code'] } == nil
    insist { subject['version_id'] } == nil
    insist { subject['trailing_fields'] } == nil
    insist { subject['clientip'] } == subject['remote_ip']
    insist { subject['response'] } == subject['http_status']

    validate_s3_fields
    validate_s3_request_uri_fields
  end

  sample %(9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 n-e-w-legacy [04/Jun/2012:16:44:26 +0000] 10.1.155.11 9ab8c3813615ea8387cf4cc559958ec02531c04954bbbf924321656cc030bce3 2B8A7289376A942E REST.GET.LOGGING_STATUS - "GET /n-e-w-legacy?logging HTTP/1.1" 200 - 239 - 8 - "-" "S3Console/0.4" -) do
    insist { subject["message"] } == "10.1.155.11 - 9ab8c38136 [04/Jun/2012:16:44:26 +0000] \"GET /n-e-w-legacy?logging HTTP/1.1\" 200 239 \"-\" \"S3Console/0.4\" 0"
    insist { subject["tags"] }.include? 's3_timestamp'
    insist { subject["tags"] & [ 'billable' ] } == []
    insist { subject["timestamp"] } == '04/Jun/2012:16:44:26 +0000'
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
    insist { subject["s3_message"] } == %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452"" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -)
    insist { subject["message"] } == nil
    insist { subject["tags"] }.include?(parse_failure_tag)
  end

end

shared_examples "convert REST.COPY.OBJECT_GET to POST" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.staging.kerkdienstgemist.nl [17/Sep/2010:13:38:36 +0000] 85.113.244.146 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 71F7D2AAA93B0A05 REST.COPY.OBJECT_GET 10010150/2010-08-29-0930.mp3 - 200 - - 13538337 - - - - -) do
    insist { subject["message"] } == %(85.113.244.146 - 2cf7e6b063 [17/Sep/2010:13:38:36 +0000] "POST /10010150/2010-08-29-0930.mp3 HTTP/1.1" 200 0 "REST.COPY.OBJECT_GET" "-" 0)
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.staging.kerkdienstgemist.nl [17/Sep/2010:13:38:37 +0000] 85.113.244.146 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 7CC5E3D09AE78CAE REST.COPY.OBJECT_GET 10010150/2010-09-05-1000.mp3 - 200 - - 9860402 - - - - -) do
    insist { subject["message"] } == %(85.113.244.146 - 2cf7e6b063 [17/Sep/2010:13:38:37 +0000] "POST /10010150/2010-09-05-1000.mp3 HTTP/1.1" 200 0 "REST.COPY.OBJECT_GET" "-" 0)
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [09/Sep/2014:18:33:15 +0000] 79.125.24.185 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 5E493280357FAC3B REST.COPY.OBJECT_GET 10518050/upload/f0a2c702d58183844b064eb49f8b795d.mp3 - 200 - - 16251603 - - - - -) do
    insist { subject["message"] } == "79.125.24.185 - 2cf7e6b063 [09/Sep/2014:18:33:15 +0000] \"POST /10518050/upload/f0a2c702d58183844b064eb49f8b795d.mp3 HTTP/1.1\" 200 0 \"REST.COPY.OBJECT_GET\" \"-\" 0"
  end

end

shared_examples "recalculate partial content enabled" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [02/Oct/2010:18:29:16 +0000] 82.168.113.55 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 4F911681022807C6 REST.GET.OBJECT 10028050/2010-09-26-1830.mp3 "GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1" 206 - 4194304 17537676 1600 12 "-" "VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team" -) do
    insist { subject["message"] } == "82.168.113.55 - 2cf7e6b063 [02/Oct/2010:18:29:16 +0000] \"GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1\" 206 135872 \"-\" \"VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team\" 2"
    insist { subject["bytes"].to_i } == 135872
    insist { subject["tags"] }.include? 'bytes_recalculated'
  end

  sample(%(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [24/Mar/2013:10:22:56 +0000] 77.168.122.24 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 A5A6B08FB9342F4D REST.GET.OBJECT 10010160/2013-03-24-0930.mp3 "GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 18547033 18547033 17344 58 "http://kerkdienstgemist.nl/mp3/recorder.php?id=452" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" -)) do
    insist { subject["message"] } == "77.168.122.24 - 2cf7e6b063 [24/Mar/2013:10:22:56 +0000] \"GET /10010160/2013-03-24-0930.mp3?Signature=75eBWlMvIpO357%2FqKLdn0sZRP08%3D&Expires=1364127776&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 200 18547033 \"http://kerkdienstgemist.nl/mp3/recorder.php?id=452\" \"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)\" 17"
    insist { subject["bytes"].to_i } == 18547033
    subject["tags"].should_not include("bytes_recalculated")
  end


  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Oct/2019:15:31:08 +0000] 86.80.226.203 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 BCA2E0AB004F2273 REST.GET.OBJECT 10026021-v1520329/20191018085700_15530042-mp4.mp4 "GET /media.kerkdienstgemist.nl/10026021-v1520329/20191018085700_15530042-mp4.mp4?response-content-disposition=attachment%3Bfilename%3D2019-10-18-1100.mp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=1VYKRTJ5FFKT5B6F4NR2%2F20191019%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20191019T134605Z&X-Amz-Expires=10800&X-Amz-SignedHeaders=host&X-Amz-Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX HTTP/1.1" 206 - 6854150 1251270047 267 89 "-" "Mozilla/5.0 (iPad; CPU OS 13_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) GSA/85.0.274229539 Mobile/15E148 Safari/605.1" - 6eClMtcuQ4C/qVCroMFqlP+UhkS52mjgDEhIKB5QKd+jCd0Pd9RADkMb0T4hjstZZBlzyFkvQJk= SigV4 ECDHE-RSA-AES128-GCM-SHA256 QueryString s3.eu-west-1.amazonaws.com TLSv1.2) do
    insist { subject["bytes"].to_i } == 6854150
    subject["tags"].should_not include("bytes_recalculated")
    subject["tags"].should_not include(parse_failure_tag)
  end

end

shared_examples "recalculate partial content disabled" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [02/Oct/2010:18:29:16 +0000] 82.168.113.55 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 4F911681022807C6 REST.GET.OBJECT 10028050/2010-09-26-1830.mp3 "GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1" 206 - 4194304 17537676 1600 12 "-" "VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team" -) do
    insist { subject["message"] } == "82.168.113.55 - 2cf7e6b063 [02/Oct/2010:18:29:16 +0000] \"GET /10028050/2010-09-26-1830.mp3?Signature=E3ehd6nkXjNg7vr%2F4b3LtxCWads%3D&Expires=1286051333&AWSAccessKeyId=AKIAI3XHXJPFSJW2UQAQ HTTP/1.1\" 206 4194304 \"-\" \"VLC media player - version 1.0.5 Goldeneye - (c) 1996-2010 the VideoLAN team\" 2"
    insist { subject["bytes"].to_i } == 4194304
  end

end

shared_examples "drop REST.COPY_OBJECT_GET" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [09/Sep/2014:18:33:15 +0000] 79.125.24.185 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 5E493280357FAC3B REST.COPY.OBJECT_GET 10518050/upload/f0a2c702d58183844b064eb49f8b795d.mp3 - 200 - - 16251603 - - - - -) do
    insist { subject }.nil?
  end

end

shared_examples "parse HEAD requests correctly" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [14/Sep/2014:17:04:09 +0000] 54.73.228.177 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 B29B27C9138CCF11 REST.HEAD.OBJECT 11829090-v978102/20140914075051_15126453-mp4.mp4 "HEAD /11829090-v978102/20140914075051_15126453-mp4.mp4 HTTP/1.1" 200 - - 431614646 9 - "-" "-" -) do
    insist { subject["message"] } == ''
    insist { subject["timestamp"] } == '14/Sep/2014:17:04:09 +0000'
    insist { subject["tags"] }.include? 's3_timestamp'
    insist { subject["verb"] } == 'HEAD'
  end

end

shared_examples "trailing fields" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [14/Sep/2014:17:04:09 +0000] 54.73.228.177 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 B29B27C9138CCF11 REST.HEAD.OBJECT 11829090-v978102/20140914075051_15126453-mp4.mp4 "HEAD /11829090-v978102/20140914075051_15126453-mp4.mp4 HTTP/1.1" 200 - - 431614646 9 - "-" "-" - any other fields) do
    insist { subject["trailing_fields"] } == 'any other fields'
  end

end

shared_examples "handling regression cases" do

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Sep/2014:07:57:28 +0000] 84.31.184.148 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 50F3B3FA4D044EF4 REST.GET.OBJECT 13325060/2014-05-12-1400.mp3 "GET /13325060/2014-05-12-1400.mp3?Signature=jXRvfsf9W7mGaCulqa5t7013kuM%3D&Expires=1411120647&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 304 - - 10750830 11 - "-" "NSPlayer/12.00.7601.17514 WMFSDK/12.00.7601.17514" -) do
    insist { subject["message"] } == "84.31.184.148 - 2cf7e6b063 [19/Sep/2014:07:57:28 +0000] \"GET /13325060/2014-05-12-1400.mp3?Signature=jXRvfsf9W7mGaCulqa5t7013kuM%3D&Expires=1411120647&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 304 0 \"-\" \"NSPlayer/12.00.7601.17514 WMFSDK/12.00.7601.17514\" 0"
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Sep/2014:07:53:40 +0000] 79.125.24.185 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 F8E64FC85895C101 REST.DELETE.OBJECT 90704041-v1037416/20140914090032_15200524-mp4.mp4 "DELETE /90704041-v1037416/20140914090032_15200524-mp4.mp4 HTTP/1.1" 204 - - 167213670 13 - "-" "-" -) do
    insist { subject["message"] } == "79.125.24.185 - 2cf7e6b063 [19/Sep/2014:07:53:40 +0000] \"DELETE /90704041-v1037416/20140914090032_15200524-mp4.mp4 HTTP/1.1\" 204 0 \"-\" \"-\" 0"
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Sep/2014:07:53:11 +0000] 195.64.67.149 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 2C1FAFE37EA7067F REST.PUT.ACL 92221041-v1014211/20140914075120_15201610-mp4.mp4 "PUT /92221041-v1014211%2F20140914075120_15201610-mp4.mp4?acl HTTP/1.1" 200 - - - 40 - "-" "Cyberduck/4.2.1 (Mac OS X/10.9.4) (i386)" -) do
    insist { subject["message"] } == "195.64.67.149 - 2cf7e6b063 [19/Sep/2014:07:53:11 +0000] \"PUT /92221041-v1014211%2F20140914075120_15201610-mp4.mp4?acl HTTP/1.1\" 200 0 \"-\" \"Cyberduck/4.2.1 (Mac OS X/10.9.4) (i386)\" 0"
  end

  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Sep/2014:06:57:05 +0000] 89.99.28.243 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 465300DDC1822DE5 REST.GET.OBJECT 11723021/2014-09-17-1430.mp3 "GET /11723021/2014-09-17-1430.mp3?Signature=BanH0VrdfI%2FXCouvXFXivLBS2PE%3D&Expires=1411116501&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 304 - - 31128609 9 - "-" "AppleCoreMedia/1.0.0.11B554a (iPad; U; CPU OS 7_0_4 like Mac OS X; nl_nl)" -) do
    insist { subject["message"] } == "89.99.28.243 - 2cf7e6b063 [19/Sep/2014:06:57:05 +0000] \"GET /11723021/2014-09-17-1430.mp3?Signature=BanH0VrdfI%2FXCouvXFXivLBS2PE%3D&Expires=1411116501&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 304 0 \"-\" \"AppleCoreMedia/1.0.0.11B554a (iPad; U; CPU OS 7_0_4 like Mac OS X; nl_nl)\" 0"
  end
end

shared_examples "drop unsigned accesses from vod-raven" do

  # don't drop this
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Dec/2015:14:49:22 +0000] 95.96.20.131 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 93B36098060014B9 REST.GET.OBJECT 11506070-v1159918/20151216095500_15248755-mp4.mp4 "GET /11506070-v1159918/20151216095500_15248755-mp4.mp4?Signature=hQVMyGYcvev%2Fi8jndOOlWAzhQ8I%3D&Expires=1450543754&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 200 - 4852709 944933685 202 66 "http://kerkdienstgemist.nl/assets/1241862-Afscheidsdienst-dhr-J-de-Vos/embed" "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko" -) do
    insist { subject["message"] } == "95.96.20.131 - 2cf7e6b063 [19/Dec/2015:14:49:22 +0000] \"GET /11506070-v1159918/20151216095500_15248755-mp4.mp4?Signature=hQVMyGYcvev%2Fi8jndOOlWAzhQ8I%3D&Expires=1450543754&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 200 4852709 \"http://kerkdienstgemist.nl/assets/1241862-Afscheidsdienst-dhr-J-de-Vos/embed\" \"Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko\" 0"
  end

  # but drop this
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Dec/2015:14:49:22 +0000] 79.125.15.123 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 93B36098060014B9 REST.GET.OBJECT 11506070-v1159918/20151216095500_15248755-mp4.mp4 "GET /11506070-v1159918/20151216095500_15248755-mp4.mp4 HTTP/1.1" 200 - 4852709 944933685 202 66 "http://kerkdienstgemist.nl/assets/1241862-Afscheidsdienst-dhr-J-de-Vos/embed" "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko" -) do
    insist { subject } == nil
  end

  # don't drop this
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Dec/2015:19:40:25 +0000] 77.167.232.181 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 49810B026E01F80E REST.GET.OBJECT 90701051-v1127425/20151217185400_15249572-mp4.mp4 "GET /90701051-v1127425/20151217185400_15249572-mp4.mp4?Signature=loSAbSlTKuvHBQDA%2Buph1Z1CdwE%3D&Expires=1450560528&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1" 206 - 8745905 1639187062 10424 42 "http://kerkdienstgemist.nl/playlists/9783/embed?media=video&playerheight=480" "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko" -) do
    insist { subject["message"] } == "77.167.232.181 - 2cf7e6b063 [19/Dec/2015:19:40:25 +0000] \"GET /90701051-v1127425/20151217185400_15249572-mp4.mp4?Signature=loSAbSlTKuvHBQDA%2Buph1Z1CdwE%3D&Expires=1450560528&AWSAccessKeyId=1VYKRTJ5FFKT5B6F4NR2 HTTP/1.1\" 206 162344 \"http://kerkdienstgemist.nl/playlists/9783/embed?media=video&playerheight=480\" \"Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko\" 10"
  end

  # but drop this
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Dec/2015:19:40:25 +0000] 77.167.232.181 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 49810B026E01F80E REST.GET.OBJECT 90701051-v1127425/20151217185400_15249572-mp4.mp4 "GET /90701051-v1127425/20151217185400_15249572-mp4.mp4 HTTP/1.1" 206 - 8745905 1639187062 10424 42 "http://kerkdienstgemist.nl/playlists/9783/embed?media=video&playerheight=480" "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko" -) do
    insist { subject } == nil
  end

end

shared_examples "drop requests for images" do

  # drop .svg poster image
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Oct/2019:16:49:23 +0000] 94.214.154.36 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 8981914CC7324702 REST.GET.OBJECT 10522060/2019-09-29-1820/poster_thumb.svg "GET /media.kerkdienstgemist.nl/10522060/2019-09-29-1820/poster_thumb.svg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=1VYKRTJ5FFKT5B6F4NR2%2F20191019%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20191019T164922Z&X-Amz-Expires=10800&X-Amz-SignedHeaders=host&X-Amz-Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX HTTP/1.1" 200 - 2546 2546 38 38 "https://beta.kerkdienstgemist.nl/stations/150-Hervormde-Gemeente-Bleskensgraaf/events/live" "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36" - GbgC6AC+f3LX2JovtQZ1zxMKnLxlaWK8pNFwkuJsg96BL/lCGJ+HUXLKAQLrPYG+PNg/Gmxkwak= SigV4 ECDHE-RSA-AES128-GCM-SHA256 QueryString s3.eu-west-1.amazonaws.com TLSv1.2) do
    insist { subject } == nil
  end

  # drop .jpg upload
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Oct/2019:17:14:49 +0000] 34.245.174.106 148c961344704acc761dd011016226d36f06f24ff6bb890beb414040f1f866a6 DAA2447D01DBB414 REST.HEAD.OBJECT 10104090/upload/82ca8ef474c4a7b1651731ac90ec2ce1_1.jpg "HEAD /media.kerkdienstgemist.nl/10104090/upload/82ca8ef474c4a7b1651731ac90ec2ce1_1.jpg HTTP/1.1" 404 NoSuchKey 325 - 4 - "-" "fog/1.37.0 fog-core/1.42.0" - f0hrDe0SG296vuOclyAFFpeZ/agYlG6YpsfsZfc+PXJB9fCBMAxTLjOH3xrdXFw38qkd6ugx+gw= SigV4 ECDHE-RSA-AES128-GCM-SHA256 AuthHeader s3-eu-west-1.amazonaws.com TLSv1.2) do
    insist { subject } == nil
  end
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [29/Sep/2019:07:06:39 +0000] 84.87.16.86 2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 36BD23E9C1A89753 REST.GET.OBJECT 10202180-v1520443/20190901165800_15273346-mp4/poster_small.jpg "GET /media.kerkdienstgemist.nl/10202180-v1520443/20190901165800_15273346-mp4/poster_small.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=1VYKRTJ5FFKT5B6F4NR2%2F20190929%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20190929T070639Z&X-Amz-Expires=10800&X-Amz-SignedHeaders=host&X-Amz-Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX HTTP/1.1" 200 - 9423 9423 18 18 "https://beta.kerkdienstgemist.nl/" "Mozilla/5.0 (iPad; CPU OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1" - g5HrxUw9U25o+kpS29O8TtMRZgWrC+/JPG/LmUva3CTGLWjitZD1zc0/UUlBaqGSZgf/nh8Dcwg= SigV4 ECDHE-RSA-AES128-GCM-SHA256 QueryString s3.eu-west-1.amazonaws.com TLSv1.2) do
    insist { subject } == nil
  end

  # drop requests for .png
  sample %(2cf7e6b06335c0689c6d29163df5bb001c96870cd78609e3845f1ed76a632621 media.kerkdienstgemist.nl [19/Oct/2019:16:58:39 +0000] 145.132.86.71 - 097C7E137F28E7E1 REST.GET.OBJECT apple-touch-icon-152x152.png "GET /apple-touch-icon-152x152.png HTTP/1.1" 403 AccessDenied 243 - 4 - "-" "MobileSafari/604.1 CFNetwork/901.1 Darwin/17.6.0" - DHRF/yI6kSrtg1gFEiWE4XUQqDo2JVt6IXhVDjWjigKgSZuDY1tMhlhgBfLunDge8ifmRZd2XYA= - - - media.kerkdienstgemist.nl -) do
    insist { subject } == nil
  end

end

describe "Custom s3_access_log filter solution" do
  extend LogStash::RSpec

  describe "with default config" do

    let(:parse_failure_tag) { '_s3parsefailure'}

    type 's3'
    config [ 'filter{', File.read("conf.d/70_s3.conf"), '}' ].join

    it_behaves_like "converts valid S3 Server Access Log lines into Apache CLF format"
    it_behaves_like "rejects invalid log lines"
    it_behaves_like "convert REST.COPY.OBJECT_GET to POST"
    it_behaves_like "recalculate partial content enabled"
    it_behaves_like "handling regression cases"
    it_behaves_like "drop unsigned accesses from vod-raven"
    it_behaves_like "drop requests for images"
  end

  describe "with recalculate_partial_content set to false" do
    config %q(
      filter {
        mutate { rename => [ 'message', 's3_message' ] }
        s3_access_log {
          source => 's3_message'
          recalculate_partial_content => false
        }
      }
    )
    it_behaves_like "recalculate partial content disabled"
  end

  describe "with copy_operation set to 'drop'" do
    config %q(
      filter {
        mutate { rename => [ 'message', 's3_message' ] }
        s3_access_log {
          source => 's3_message'
          copy_operation => 'drop'
        }
      }
    )

    it_behaves_like "drop REST.COPY_OBJECT_GET"
  end

end

describe "Logstash grok and filter solution" do
  extend LogStash::RSpec

  describe "with default config" do
    let(:parse_failure_tag) { '_grokparsefailure'}

    type 's3_test_grok'
    config [ 'filter{', File.read("conf.d/71_s3_test_grok.conf"), '}' ].join

    it_behaves_like "converts valid S3 Server Access Log lines into Apache CLF format"
    it_behaves_like "rejects invalid log lines"
    it_behaves_like "convert REST.COPY.OBJECT_GET to POST"
    it_behaves_like "recalculate partial content enabled"
    it_behaves_like "handling regression cases"
  end

end

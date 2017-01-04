# Logstash plugins

This repo contains a number of logstash (1.3.3) plugins use by Kerkdienst Gemist B.V.

## Filter: `s3_access_log.rb`

Filter to convert Amazon S3 Server Access Log format to Apache Combined Log Format (CLF) applying some Kerkdienst Gemist specific adjustments along the way.

## Filter: `fingerprint.rb`

Backport (copy) of the logstash 1.4 fingerprint filter (used to generate unique MD5 for unique log lines).

## Input: `s3.rb`

Copy of the logstash 1.3.3 `s3.rb` input module with a single patch applied to allow an empty sincedb file. With this we can specify `sincedb_path = '/dev/null'` to cause the s3 input to always process all log files from a S3 bucket (regardless of the timestamp).

See: [Issue Multiple Files Being Left Unprocessed with Identical Timestamps](https://github.com/logstash-plugins/logstash-input-s3/issues/57)

# Setup

Assuming the logstash (1.3.3) repository has been cloned into `../logstash`.

## Running all specs

To run the specs simply run `make` or `make spec`. This will run all specs in spec/**/*.rb

    $ make

    ............................................
    Finished in 2.56 seconds
    44 examples, 0 failures

## Running a specific spec

    $ HOME=`pwd` ../logstash/bin/logstash rspec spec/filters/icecast_spec.rb
    ...........

    Finished in 11.23 seconds
    11 examples, 0 failures

## Running the logstash agent

To run the agent run `make agent`. This will run the logstash agent with the configuration from conf.d.
This configuration is created by concactenating all files in conf.d together (in sorted order).

	make agent
    # this will run ../logstash/bin/logstash agent --pluginpath lib -f logstash.conf

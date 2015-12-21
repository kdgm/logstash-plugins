
# Setup

Assuming the logstash repository has been cloned into `../logstash`.

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

# Setup

Assuming the logstash repository is checked out in `../logstash`.

# Running specs

To run the specs simply run `make` or `make spec`.

	make
    # this will run ../logstash/bin/logstash rspec spec/**/*.rb 

    ............................................

	Finished in 2.56 seconds
	44 examples, 0 failures


# Running agent

To run the agent run `make agent`.

	make agent
    # this will run ../logstash/bin/logstash agent --pluginpath lib -f logstash.conf
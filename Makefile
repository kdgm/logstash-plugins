default: spec

.PHONY: spec
spec:
	HOME=`pwd` ../logstash/bin/logstash rspec spec/**/*.rb

agent:
	HOME=`pwd` ../logstash/bin/logstash --pluginpath lib -f conf.d -v

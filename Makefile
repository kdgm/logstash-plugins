default: spec

.PHONY: spec
spec:
	../logstash/bin/logstash rspec spec/filters/*.rb

agent:
	HOME=`pwd` ../logstash/bin/logstash --pluginpath lib -f conf.d -v

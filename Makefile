default: spec

.PHONY: spec
spec:
	../logstash/bin/logstash rspec spec/filters/*.rb

agent:
	../logstash/bin/logstash --pluginpath lib -f logstash.conf

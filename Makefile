default: spec

.PHONY: spec
spec:
	HOME=`pwd` ../logstash/bin/logstash rspec spec

# brew install fswatch
watch:
	fswatch spec conf.d | xargs -L1 make spec

agent:
	HOME=`pwd` ../logstash/bin/logstash --pluginpath lib -f conf.d -v

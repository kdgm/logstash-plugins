default: spec

.PHONY: spec
spec:
	HOME=`pwd` ../logstash/bin/logstash rspec spec/**/*.rb

# brew install fswatch
watch:
	fswatch spec | xargs -L1 make spec

agent:
	HOME=`pwd` ../logstash/bin/logstash --pluginpath lib -f conf.d -v

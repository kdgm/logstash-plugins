## Release 2021-06-11-1348
Merge branch 'feature/fix/large-backlog-issues' into develop
- [enh] if there are more objects available, keep going instead of waiting `interval` seconds
- [fix] limit the number of objects returned to 1000 by default

## Release 2020-12-05-1714
- [enh] switch to date tags for releases
- [fix] join logsources into single string (with comma)
- [fix] join referrer strings with semicolon (;) into single string
- [add] message field containing Apache Common Log format representation of the session
- [add] rubocop and solargraph to have a more pleasant vscode experience

## Release 0.1.1
- [fix] only recalculate bytes for partial content when key extension is .mp3 (MP3 audio content)

## Release 0.1.0
- [fix] ignore image (svg,jpg,png) requests (most importantly poster images)

## Release v0.0.1 - 0.0.8
- Previous releases of logstash-plugins

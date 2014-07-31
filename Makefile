
serve:
	python -m SimpleHTTPServer

watch:	
	watchify -v -t coffeeify --extension=".coffee" src/main.coffee -o bundle.js -d

test:
	node_modules/jasmine-node/bin/jasmine-node --coffee spec

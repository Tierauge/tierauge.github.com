all: build

build:
	hugo --minify --cleanDestinationDir

preview:
	hugo server

publish: build
	git add -A docs content data static themes hugo.toml
	git commit -m "automatic commit"
	git push origin master

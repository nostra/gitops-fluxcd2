MAIN = build

all: presentation.html

clean:
	rm -f presentation.html
	rm -rf build

%.html: %.md prefix.htx postfix.htx; cat prefix.htx  $<  postfix.htx > $@

build: presentation.html
	mkdir -p build
	cp presentation.html build/index.html
	cp -r image build/.

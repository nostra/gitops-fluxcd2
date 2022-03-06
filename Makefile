MAIN = build

all: presentation.html

clean:
	rm -f presentation.html

%.html: %.md prefix.htx postfix.htx; cat prefix.htx  $<  postfix.htx > $@

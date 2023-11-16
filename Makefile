OBJCFLGS := -framework Foundation -framework NaturalLanguage -fobjc-arc

all: libEMT.dylib
libEMT.dylib: emt.m
	clang -O -Wall -shared $(OBJCFLGS) -o libEMT.dylib emt.m

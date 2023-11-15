OBJCFLGS := -framework Foundation -framework NaturalLanguage -objc-noarc

all: libEMT.dylib
libEMT.dylib: emt.m
	clang -O -Wall -shared $(OBJCFLGS) -o libEMT.dylib emt.m

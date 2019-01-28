
#Compiler and Linker
CC          := gcc
GCC         := gcc

#The Target Binary Program
TARGET      := main
TESTTARGET  := test_suite

#The Directories, Source, Includes, Objects, Binary and Resources
SRCDIR      := src
EXTDIR      := ext
TESTDIR     := test
INCDIR      := inc
LIBDIR      := lib
BUILDDIR    := obj
TARGETDIR   := bin
RESDIR      := res
SRCEXT      := c
DEPEXT      := d
OBJEXT      := o

current_dir = $(shell pwd)

#Flags, Libraries and Includes
CXXSTD      := -Wno-deprecated-register -g -O0
CFLAGS      := $(CXXSTD) -fopenmp -Wall -O3 -g
DYNLIBPARAM := -dynamiclib
INC         := -I$(INCDIR) -I/usr/local/include -Isrc -Isrc/test -I$(LIBDIR) -I$(EXTDIR)

PROGRAMFILES := $(shell find $(SRCDIR)/ -type f -name *.$(SRCEXT))
TESTFILES  := $(shell find $(TESTDIR)/ $(SRCDIR)/ ! -name 'main.c' -type f -name *.$(SRCEXT) )
OBJECTS     := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(PROGRAMFILES:.$(SRCEXT)=.$(OBJEXT)))

all: directories main tests

directories:
	mkdir -p $(TARGETDIR)
	mkdir -p $(BUILDDIR)
	mkdir -p $(TESTDIR)
	mkdir -p $(INCDIR)

main_nodeps:
	$(CC) $(CXXSTD) $(INC) $(PROGRAMFILES) -lm -o $(TARGETDIR)/$(TARGET)

main: $(OBJECTS)
	$(CC) -o $(TARGETDIR)/$(TARGET) $^

$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(dir $@)
	$(CC) $(CXXSTD) $(INC) -c -o $@ $<
	@$(CC) $(CXXSTD) $(INC) -MM $(SRCDIR)/$*.$(SRCEXT) > $(BUILDDIR)/$*.$(DEPEXT)
	@cp -f $(BUILDDIR)/$*.$(DEPEXT) $(BUILDDIR)/$*.$(DEPEXT).tmp
	@sed -e 's|.*:|$(BUILDDIR)/$*.$(OBJEXT):|' < $(BUILDDIR)/$*.$(DEPEXT).tmp > $(BUILDDIR)/$*.$(DEPEXT)
	@sed -e 's/.*://' -e 's/\\$$//' < $(BUILDDIR)/$*.$(DEPEXT).tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILDDIR)/$*.$(DEPEXT)
	@rm -f $(BUILDDIR)/$*.$(DEPEXT).tmp

tests:
	$(CC) $(CXXSTD) $(INC) $(TESTFILES) -lcspec -lm -o $(TARGETDIR)/$(TESTTARGET)
	find ./test/ -name "*.c" -exec rm -f {} \;

.PHONY: all tests clean
clean:
	rm -rf obj && mkdir obj
	rm -rf bin/* obj/*

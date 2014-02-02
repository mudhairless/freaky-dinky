include common.mki
##########################

EXENAME := game$(EXE_EXT)

SRCS := $(wildcard src/*.bas)

OBJS := $(patsubst %.bas,%.o,$(SRCS))

DEPLIBS := lib/lisp/lib/$(TARGET)/liblisp.a lib/dialogs/lib/$(TARGET)/libdialogs.a

ifndef EXTDIR
	EXTDIR := ~/projects/ext
endif

TGF := $(wildcard toepk/*)

##########################

all: $(EXENAME)

%.o : %.bas
	$(FBC) -m game $(FBC_CFLAGS) -i $(EXTDIR)/include/freebasic -i lib/dialogs/inc -i lib/lisp/inc $(FBC_FLAGS) -c $< -o $@

$(EXENAME): $(OBJS) $(DEPLIBS)
	$(FBC) -m game $(FBC_CFLAGS) $(OBJS) -p $(EXTDIR)/bin/$(TARGET) -p $(EXTDIR)/lib/$(TARGET) -p lib/dialogs/lib/$(TARGET) -p lib/lisp/lib/$(TARGET) -x $(EXENAME)

.PHONY : clean
clean:
	$(RM) $(OBJS) $(EXENAME) game.epk
	$(CD) lib/lisp/src && make clean
	$(CD) lib/dialogs && make clean

.PHONY :
game.epk: $(TGF)
	@echo "**** Building test game... ****"
	@$(CD) toepk && $(RM) game.epk && zip -rq game.epk * && mv game.epk ..

.PHONY :
lib/lisp/lib/$(TARGET)/liblisp.a :
	$(CD) lib/lisp/src && make

.PHONY :
lib/dialogs/lib/$(TARGET)/libdialogs.a :
	$(CD) lib/dialogs && make

.PHONY : test
test: $(EXENAME) game.epk
	@echo "**** Running test game...  ****"
	@$(EXE_PFX)$(EXENAME)
	

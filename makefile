include common.mki
##########################

EXENAME := game$(EXE_EXT)

SRCS := $(wildcard src/*.bas)

OBJS := $(patsubst %.bas,%.o,$(SRCS))

ifndef EXTDIR
	EXTDIR := ~/projects/ext
endif

TGF := $(wildcard toepk/*)

##########################

all: $(EXENAME)

%.o : %.bas
	$(FBC) -m game $(FBC_CFLAGS) -i $(EXTDIR)/include/freebasic -i lib/lisp/inc $(FBC_FLAGS) -c $< -o $@

$(EXENAME): $(OBJS)
	$(FBC) -m game $(FBC_CFLAGS) $(OBJS) -p $(EXTDIR)/bin/$(TARGET) -p $(EXTDIR)/lib/$(TARGET) -p lib/lisp/lib/$(TARGET) -x $(EXENAME)

.PHONY : clean
clean:
	$(RM) $(OBJS) $(EXENAME) game.epk

.PHONY :
game.epk: $(TGF)
	@echo "**** Building test game... ****"
	@$(CD) toepk && $(RM) game.epk && zip -rq game.epk * && mv game.epk ..

.PHONY : test
test: $(EXENAME) game.epk
	@echo "**** Running test game...  ****"
	@$(EXE_PFX)$(EXENAME)
	

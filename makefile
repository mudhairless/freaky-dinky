include common.mki
##########################

EXENAME := game$(EXE_EXT)

SRCS := $(wildcard src/*.bas)

OBJS := $(patsubst %.bas,%.o,$(SRCS))

ifndef EXTDIR
	EXTDIR := ~/projects/ext
endif

##########################

all: $(EXENAME)

%.o : %.bas
	$(FBC) -m game -i $(EXTDIR)/include/freebasic -i lib/lisp/inc $(FBC_FLAGS) -c $< -o $@

$(EXENAME): $(OBJS)
	$(FBC) -m game $(FBC_FLAGS) $(OBJS) -p $(EXTDIR)/lib/$(TARGET) -p lib/lisp/lib/$(TARGET) -x $(EXENAME)

.PHONY : clean
clean:
	$(RM) $(OBJS) $(EXENAME) game.epk

.PHONY : test
test: $(EXENAME)
	@echo "**** Building test game... ****"
	@$(CD) toepk && $(RM) game.epk && zip -rq game.epk * && mv game.epk ..
	@echo "**** Running test game...  ****"
	@$(EXE_PFX)$(EXENAME)
	

DIRPREFIX = ..
include $(DIRPREFIX)/common.mki
LIBNAME := $(DIRPREFIX)/$(LIBRARY_DIR)/liblisp.a
SOURCES = $(wildcard *.bas)
OBJECTS = $(patsubst %.bas,%$(EXE_EXT),$(SOURCES))

all : $(OBJECTS)

.PHONY :
%$(EXE_EXT) : %.bas 
	$(FBC) $(FBC_CFLAGS) -p $(DIRPREFIX)/$(LIBRARY_DIR) -i $(DIRPREFIX)/$(INCLUDE_DIR) $< -x $@

.PHONY : clean
clean:
	rm -f $(OBJECTS)

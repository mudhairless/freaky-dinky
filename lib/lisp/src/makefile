DIRPREFIX = ..
include $(DIRPREFIX)/common.mki
##########################

LIBNAME := $(DIRPREFIX)/$(LIBRARY_DIR)/liblisp.a

SRCS := $(wildcard *.bas)

HDRS := $(wildcard ../inc/*.bi)

OBJS := $(patsubst %.bas,obj/%.o,$(SRCS))

##########################

all: $(LIBNAME)

obj/%.o : %.bas $(HDRS)
	@test -d obj || $(MD) obj
	$(FBC) -i $(DIRPREFIX)/$(INCLUDE_DIR) $(FBC_FLAGS) -c $< -o $@

$(LIBNAME): $(OBJS)
	@test -d $(DIRPREFIX)/$(LIBRARY_DIR) || $(MD) $(DIRPREFIX)/$(LIBRARY_DIR)
	$(FBC) -lib $(FBC_FLAGS) $(OBJS) $(LIBS) -x $(LIBNAME)

.PHONY : clean
clean:
	$(RM) $(OBJS) $(LIBNAME)

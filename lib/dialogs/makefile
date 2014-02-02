include common.mki
##########################

LIBNAME := $(LIBRARY_DIR)/libdialogs.a

SRCS := $(wildcard src/*.bas)

HDRS := $(wildcard $(INCLUDE_DIR)/*.bi)

OBJS := $(patsubst %.bas,%.o,$(SRCS))

##########################

all: $(LIBNAME)

%.o : %.bas $(HDRS)
	$(FBC) $(FBC_CFLAGS) -i $(EXT_DIR)/include/freebasic -i $(INCLUDE_DIR) $(FBC_FLAGS) -c $< -o $@

$(LIBNAME): $(OBJS)
	@test -d $(LIBRARY_DIR) || $(MD) $(LIBRARY_DIR)
	$(FBC) -lib $(FBC_CFLAGS) $(OBJS) $(LIBS) -x $(LIBNAME)

.PHONY : clean
clean:
	$(RM) $(OBJS) $(LIBNAME)

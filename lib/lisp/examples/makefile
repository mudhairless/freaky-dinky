FBC := fbc
EXE_EXT := .bin
LIB := ../lib/liblisp.a

ifdef DEBUG
FBCFLAGS += -g -d DEBUG -w pedantic
endif

all : hello$(EXE_EXT) bindfunc$(EXE_EXT) runlisp$(EXE_EXT) printout$(EXE_EXT)

bindfunc$(EXE_EXT) : bindfunc.bas $(LIB)
	$(FBC) $(FBCFLAGS) bindfunc.bas -i ../src -i ../inc -p ../lib -x bindfunc$(EXE_EXT) 

runlisp$(EXE_EXT) : runlisp.bas $(LIB)
	$(FBC) $(FBCFLAGS) runlisp.bas -i ../inc -p ../lib -x runlisp$(EXE_EXT)

hello$(EXE_EXT) : hello.bas $(LIB)
	$(FBC) $(FBCFLAGS) hello.bas -i ../inc -p ../lib -x hello$(EXE_EXT)

printout$(EXE_EXT) : printout.bas $(LIB)
	$(FBC) $(FBCFLAGS) printout.bas -i ../src -i ../inc -p ../lib -x printout$(EXE_EXT)


.PHONY : clean
clean:
	rm -f hello$(EXE_EXT) bindfunc$(EXE_EXT) runlisp$(EXE_EXT) printout$(EXE_EXT)

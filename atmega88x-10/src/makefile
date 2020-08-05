

#	makefile for building ForCy


TAR		= fcy.exe
OBJS	= main.obj compiler.obj interprt.obj lint.obj


all: $(TAR) $(OBJS)


.c.obj:
	cl		-c -Ox -ML -W4 -nologo $<


$(TAR):  $(OBJS) makefile
	link	/nologo /out:$(TAR) $(OBJS)
	@copy	$(TAR) ..\


clean:
    @if exist $(TAR) del $(TAR)
    @if exist *.obj del *.obj


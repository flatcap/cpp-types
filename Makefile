CC	= g++
RM	= rm -fr
MKDIR	= mkdir -p

SRC	+= main.cpp

#HDR	= $(SRC:%.cpp=%.h)

DEPDIR	= .dep
OBJDIR	= .obj

OBJ	= $(SRC:%.cpp=$(OBJDIR)/%.o)

OUT	= main

CFLAGS	+= -std=c++11
CFLAGS	+= -g -Wall -Wextra -Wpedantic

#CFLAGS	+= -fdiagnostics-color=always
CFLAGS	+= -fno-omit-frame-pointer
CFLAGS	+= -fno-inline-functions
CFLAGS	+= -fno-inline-functions-called-once
CFLAGS	+= -fno-optimize-sibling-calls
CFLAGS	+= -O0

V	?= 0

ifeq ($(V),1)
	quiet=
else
	quiet=quiet_
endif

ifneq ($(filter s% -s%,$(MAKEFLAGS)),)
	quiet=silent_
endif

all:	$(OBJDIR) $(DEPDIR) $(OBJ) $(OUT) tags

# ----------------------------------------------------------------------------

# If quiet is set, only print short version of command
cmd	= @$(if $($(quiet)cmd_$(1)),\
		echo '$($(quiet)cmd_$(1))' &&) $(cmd_$(1))

# ----------------------------------------------------------------------------

quiet_cmd_TAGS	= CTAGS	$@
      cmd_TAGS	= ctags $(SRC)

tags:	$(SRC) $(HDR)
	$(call cmd,TAGS)

# ----------------------------------------------------------------------------

# TODO
# Execute command, saving output to a TMP file
#	g++ -g -Wall `pkg-config glibmm-2.4 lvm2app --cflags` -c gpt.cpp -o .obj/gpt.o
# $? = 0 && TMP file empty
#	echo "CC	gpt.c"
# ?$ = 0 && TMP file non-empty
#	echo "CC	gpt.c"
#	cat TMP file
# ?$ = 1
#	echo "CC	gpt.c"
#	cat TMP file
#	stop compilation

quiet_cmd_CC	= CC	$<
      cmd_CC	= $(CC) $(CFLAGS) -c $< -o $@ && (												\
		  $(CC) -MM $(CFLAGS) -c $< | sed 's/.*:/'$(OBJDIR)'\/\0/' > $(DEPDIR)/$*.d;							\
		  cp -f $(DEPDIR)/$*.d $(DEPDIR)/$*.d.tmp;											\
		  sed -e 's/.*://' -e 's/\\$$//' < $(DEPDIR)/$*.d.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(DEPDIR)/$*.d;		\
		  rm -f $(DEPDIR)/$*.d.tmp)

$(OBJDIR)/%.o: %.cpp
	$(call cmd,CC)

# ----------------------------------------------------------------------------

quiet_cmd_LD	= LD	$@
      cmd_LD	= $(CC) -o $@ $(OBJ) $(LDFLAGS)

main:	$(OBJ)
	$(call cmd,LD)

# ----------------------------------------------------------------------------

quiet_cmd_MKDIR	= MKDIR	$@
      cmd_MKDIR	= $(MKDIR) $@

$(DEPDIR) $(OBJDIR):
	$(call cmd,MKDIR)

# ----------------------------------------------------------------------------

clean:	force
	$(RM) $(OUT) $(OBJ)

distclean: clean
	$(RM) $(DEPDIR) $(OBJDIR) tags html

force:

-include $(SRC:%.cpp=$(DEPDIR)/%.d)


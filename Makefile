#----------------------------------------------------------------------------------------------------------------------
# Check if DEVKITPRO exists in current environment
#----------------------------------------------------------------------------------------------------------------------
ifndef DEVKITPRO
$(error DEVKITPRO is not present in your environment. This can be fixed by sourcing switchvars.sh from /opt/devkitpro/)
endif
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Include switch build toolchain file
#----------------------------------------------------------------------------------------------------------------------
include $(DEVKITPRO)/libnx/switch_rules
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Defination of few variables holding various directories and files used during make
#----------------------------------------------------------------------------------------------------------------------
TARGET		:=  Aether
OUTPUT		:=	lib/lib$(TARGET).a
BUILD		:=	build
LIB			:=	lib
SOURCE		:=	source
INCLUDE		:=	include
OBJSDIR		:=	$(BUILD)/objs
DEPSDIR		:=	$(BUILD)/deps
DOCS_CONFIG	:=	Doxyfile
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Defination of code generation related variables
#----------------------------------------------------------------------------------------------------------------------
ARCH		:=	-march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIC -ftls-model=local-exec
DEFINES		:=	-D__SWITCH__
LIBDIRS		:=	$(PORTLIBS) $(LIBNX)
INCLUDE		:=	$(foreach dir,$(LIBDIRS),-I$(dir)/include) -I$(INCLUDE)
CFLAGS		:=	-w -O3 -ffunction-sections -fdata-sections $(shell sdl2-config --cflags)\
				$(shell freetype-config --cflags) $(ARCH) $(INCLUDE) $(DEFINES)
CXXFLAGS	:=	$(CFLAGS) -fno-rtti -fno-exceptions -std=gnu++17
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Defination of variables holding all sources files, object files and dependant file locations
#----------------------------------------------------------------------------------------------------------------------
CFILES		:=	$(wildcard $(SOURCE)/*.c) $(wildcard $(SOURCE)/*/*.c)
CPPFILES	:=	$(wildcard $(SOURCE)/*.cpp) $(wildcard $(SOURCE)/*/*.cpp)
OFILES		:=	$(foreach CPPFILE,$(CPPFILES),$(patsubst $(SOURCE)/%.cpp,$(OBJSDIR)/%.o,$(CPPFILE)))\
				$(foreach CFILE,$(CFILES),$(patsubst $(SOURCE)/%.c,$(OBJSDIR)/%.o,$(CFILE)))
DEPENDS		:=	$(foreach OFILE,$(OFILES),$(patsubst $(OBJSDIR)/%.o,$(DEPSDIR)/%.d,$(OFILE)))
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Defination of variables holding all required sub-directories
#----------------------------------------------------------------------------------------------------------------------
SRCSUBDIRS	:=	$(wildcard $(SOURCE)/*/)
OBJSSUBDIRS	:=	$(foreach SRCSUBDIR,$(SRCSUBDIRS),$(patsubst $(SOURCE)/%/,$(OBJSDIR)/%,$(SRCSUBDIR)))
DEPSSUBDIRS	:=	$(foreach SRCSUBDIR,$(SRCSUBDIRS),$(patsubst $(SOURCE)/%/,$(DEPSDIR)/%,$(SRCSUBDIR)))
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Include dependant files if they already exist, nothing if they don't
#----------------------------------------------------------------------------------------------------------------------
-include $(DEPENDS)
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define few virtual make targets
#----------------------------------------------------------------------------------------------------------------------
.PHONY: $(BUILD) library install uninstall docs clean cleandocs
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define target rule pre-requisites
#----------------------------------------------------------------------------------------------------------------------
library : $(LIB) $(OUTPUT)
install : library
$(OUTPUT) : $(OFILES)
$(OFILES) : $(OBJSDIR) $(OBJSSUBDIRS) $(DEPSDIR) $(DEPSSUBDIRS)
$(OBJSDIR) : $(BUILD)
$(DEPSDIR) : $(BUILD)
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(BUILD)`
#----------------------------------------------------------------------------------------------------------------------
$(BUILD):
	@echo Creating build directory \($@\) if it doesn\'t exist...
	@[ -d $@ ] || mkdir -p $@

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(LIB)`
#----------------------------------------------------------------------------------------------------------------------
$(LIB):
	@echo Creating output lib directory \($@\) if it doesn\'t exist...
	@[ -d $@ ] || mkdir -p $@
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(OBJSDIR)`
#----------------------------------------------------------------------------------------------------------------------
$(OBJSDIR):
	@echo Creating object directory \($@\) if it doesn\'t exist...
	@[ -d $@ ] || mkdir -p $@
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(OBJSSUBDIRS)`
#----------------------------------------------------------------------------------------------------------------------
$(OBJSSUBDIRS):
	@echo Creating object sub-directory \($@\) if it doesn\'t exist...
	@[ -d $@ ] || mkdir -p $@
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(DEPSDIR)`
#----------------------------------------------------------------------------------------------------------------------
$(DEPSDIR):
	@echo Creating object dependent directory \($@\) if it doesn\'t exist...
	@[ -d $@ ] || mkdir -p $@
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(DEPSSUBDIRS)`
#----------------------------------------------------------------------------------------------------------------------
$(DEPSSUBDIRS):
	@echo Creating object dependent sub-directory \($@\) if it doesn\'t exist...
	@[ -d $@ ] || mkdir -p $@
#----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `clean`
#----------------------------------------------------------------------------------------------------------------------
clean:
	@echo -n Cleaning build files...
	@rm -fr $(OUTPUT) $(OBJSDIR)/*.o $(DEPSDIR)/*.d $(OBJSDIR)/*/*.o $(DEPSDIR)/*/*.d
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `cleandocs`
#----------------------------------------------------------------------------------------------------------------------
cleandocs:
	@echo -n Cleaning generated doc files...
	@rm -fr docs/*
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `install`
#----------------------------------------------------------------------------------------------------------------------
install:
	@echo -n Installing Aether headers files...
	@mkdir -p $(PORTLIBS_PREFIX)/include/Aether/
	@cp -r $(INCLUDES)/Aether/* $(PORTLIBS_PREFIX)/include/Aether/
	@echo Done!
	@echo -n Installing Aether library files...
	@mkdir -p $(PORTLIBS_PREFIX)/lib/
	@cp $(OUTPUT) $(PORTLIBS_PREFIX)/lib/
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `uninstall`
#----------------------------------------------------------------------------------------------------------------------
uninstall:
	@echo -n Un-installing Aether headers files if it is installed...
	@rm -fr $(PORTLIBS_PREFIX)/include/Aether/
	@echo Done!
	@echo -n Un-installing Aether library files if it is installed...
	@rm $(PORTLIBS_PREFIX)/lib/libAether.a
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `$(OUTPUT)`
#----------------------------------------------------------------------------------------------------------------------
$(OUTPUT):
	@rm -rf $(OUTPUT)
	@echo -n Creating Aether library archive at $(OUTPUT)...
	@$(AR) -rc $(OUTPUT) $(OFILES)
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe `docs`
#----------------------------------------------------------------------------------------------------------------------
docs:
	@echo Creating docs directory if it doesn't exist
	@[ -d $@ ] || mkdir -p $@
	@echo -n Generating docs
	@doxygen $(DOCS_CONFIG)
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe to create objects from CPP Files
#----------------------------------------------------------------------------------------------------------------------
$(OBJSDIR)/%.o: $(SOURCE)/%.cpp
	@echo -n Creating object $@...
	@$(CXX) -MMD -MP -MF $(DEPSDIR)/$*.d $(CXXFLAGS) -c $< -o $@ $(ERROR_FILTER)
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------
# Define rule recipe to create objects from C Files
#----------------------------------------------------------------------------------------------------------------------
$(OBJSDIR)/%.o: $(SOURCE)/%.c
	@echo -n Creating object $@...
	@$(CC) -MMD -MP -MF $(DEPSDIR)/$*.d $(CFLAGS) -c $< -o $@ $(ERROR_FILTER)
	@echo Done!
#----------------------------------------------------------------------------------------------------------------------
# Copyright 2015, Pablo Ridolfi
# All rights reserved.
#
# This file is part of lpc1769_template.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Default application to be compiled
PROJECT ?= examples/blink

# Path for compiled files (libraries and binaries)
OUT_PATH := out

# Path for object files
OBJ_PATH := $(OUT_PATH)/obj

# include target Makefile
include target.mk

# Selected application by user
-include project.mk

# include project Makefile
include $(PROJECT)/Makefile

# include modules Makefiles
include $(foreach MOD,$(MODULES),$(MOD)/Makefile)

# application object files
APP_OBJ_FILES := $(addprefix $(OBJ_PATH)/,$(notdir $(APP_C_FILES:.c=.o)))
APP_OBJ_FILES += $(addprefix $(OBJ_PATH)/,$(notdir $(APP_ASM_FILES:.S=.o)))
APP_OBJS := $(notdir $(APP_OBJ_FILES))

# include paths
INCLUDES := $(addprefix -I,$(APP_INC_FOLDERS))
INCLUDES += $(addprefix -I,$(foreach MOD,$(notdir $(MODULES)),$($(MOD)_INC_FOLDERS)))

# Add object path to search paths
vpath %.o $(OBJ_PATH)
vpath %.c $(APP_SRC_FOLDERS) $(foreach MOD,$(notdir $(MODULES)),$($(MOD)_SRC_FOLDERS))
vpath %.S $(APP_SRC_FOLDERS) $(foreach MOD,$(notdir $(MODULES)),$($(MOD)_SRC_FOLDERS))
vpath %.a $(OUT_PATH)

# All rule: Compile all libs and executables
all: $(APPLICATION)

# rule to make modules
define makemod
lib$(1).a: $(2)
	@echo "*** Archiving module $(1) ***"
	@$(CROSS_PREFIX)ar rcs $(OUT_PATH)/lib$(1).a $(addprefix $(OBJ_PATH)/,$(2))
	@$(CROSS_PREFIX)size $(OUT_PATH)/lib$(1).a
endef

$(foreach MOD,$(notdir $(MODULES)), $(eval $(call makemod,$(MOD),$(notdir $($(MOD)_C_FILES:.c=.o)))))

%.o: %.c
	@echo "*** Compiling C file $< ***"
	@$(CROSS_PREFIX)gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$(notdir $@)
	@$(CROSS_PREFIX)gcc -MM $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< > $(OBJ_PATH)/$(notdir $(@:.o=.d))

%.o: %.S
	@echo "*** Compiling Assembly file $< ***"
	@$(CROSS_PREFIX)gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	@$(CROSS_PREFIX)gcc -MM $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< > $(OBJ_PATH)/$(@:.o=.d)

-include $(wildcard $(OBJ_PATH)/*.d)

$(APPLICATION): $(APP_OBJS) $(foreach MOD,$(notdir $(MODULES)),lib$(MOD).a)
	@echo "*** Linking project $(APPLICATION) ***"
	@$(CROSS_PREFIX)gcc $(LFLAGS) $(LD_FILE) -o $(OUT_PATH)/$(APPLICATION).axf $(APP_OBJ_FILES) -L$(OUT_PATH) $(addprefix -l,$(notdir $(MODULES))) $(addprefix -L,$(LIBS_FOLDERS)) $(addprefix -l,$(LIBS))
	@$(CROSS_PREFIX)size $(OUT_PATH)/$(APPLICATION).axf
	@$(CROSS_PREFIX)objcopy -v -O binary $(OUT_PATH)/$(APPLICATION).axf $(OUT_PATH)/$(APPLICATION).bin
	@make --no-print-directory ctags

# Clean rule: remove generated files and objects
clean:
	rm -f $(OBJ_PATH)/*.*
	rm -f $(OUT_PATH)/*.*
	rm -f *.launch

download: $(APPLICATION)
	@echo "Downloading $(APPLICATION).bin to $(TARGET_NAME)..."
	openocd -f $(CFG_FILE) -c "init" -c "reset halt" -c "flash write_image erase unlock $(OUT_PATH)/$(APPLICATION).bin $(BASE_ADDR) bin" -c "reset halt" -c "resume" -c "shutdown"
	@echo "Download done."

erase:
	@echo "Erasing flash memory..."
	openocd -f $(CFG_FILE) -c "init" -c "halt 0" -c "flash erase_sector 0 0 last" -c "exit"
	@echo "Erase done."

info:
	@echo MODULES: $(notdir $(MODULES))
	@echo SRC_FOLDERS: $(foreach MOD,$(notdir $(MODULES)),$($(MOD)_SRC_FOLDERS))
	@echo OBJS: $(OBJS)
	@echo INCLUDES: $(INCLUDES)
	@echo SRC_FOLDERS: $(SRC_FOLDERS)

ctags: ./tags
	@echo "Generating tags file"
	@ctags -R .

help:
	@echo Seleccionar la aplicación a compilar copiando project.mk.template a project.mk y modificando la variable PROJECT.
	@echo Ejemplos disponibles:
	@printf "\t$(sort $(notdir $(wildcard examples/*)))\n"

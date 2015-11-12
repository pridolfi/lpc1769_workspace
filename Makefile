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

# Selected application by user
-include project.mk

# include project Makefile
include $(PROJECT)/Makefile

# include modules Makefiles
include $(foreach MOD,$(MODULES),modules/$(MOD)/Makefile)

# Path for compiled files (libraries and binaries)
OUT_PATH := out

# Path for object files
OBJ_PATH := $(OUT_PATH)/obj

# Defined symbols
SYMBOLS := -DDEBUG -DCORE_M3 -D__USE_LPCOPEN -D__LPC17XX__ -D__CODE_RED

# Compilation flags
CFLAGS  := -Wall -ggdb3 -mcpu=cortex-m3 -mthumb -fdata-sections -ffunction-sections -c

# Linking flags
LFLAGS  := -nostdlib -fno-builtin -mcpu=cortex-m3 -mthumb -Xlinker -Map=$(OUT_PATH)/$(APPLICATION).map -Wl,--gc-sections

# Linker scripts
LD_FILE := -Tld/lpc17xx.ld

# object files
OBJ_FILES := $(addprefix $(OBJ_PATH)/,$(notdir $(C_FILES:.c=.o)))
OBJ_FILES += $(addprefix $(OBJ_PATH)/,$(notdir $(ASM_FILES:.S=.o)))
OBJS := $(notdir $(OBJ_FILES))

# include paths
INCLUDES := $(addprefix -I,$(INC_FOLDERS))

# Add object path to search paths
vpath %.o $(OBJ_PATH)
vpath %.c $(SRC_FOLDERS)
vpath %.S $(SRC_FOLDERS)

# All rule: Compile all libs and executables
all: $(APPLICATION)

%.o: %.c
	@echo "*** Compiling C file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	arm-none-eabi-gcc -MM $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< > $(OBJ_PATH)/$(@:.o=.d)
	@echo ""

%.o: %.S
	@echo "*** Compiling Assembly file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	arm-none-eabi-gcc -MM $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< > $(OBJ_PATH)/$(@:.o=.d)
	@echo ""

-include $(wildcard $(OBJ_PATH)/*.d)

$(APPLICATION): $(OBJS)
	@echo "*** Linking project $(APPLICATION) ***"
	arm-none-eabi-gcc $(LIB_PATH) $(LFLAGS) $(LD_FILE) -o $(OUT_PATH)/$(APPLICATION).axf $(OBJ_FILES) $(addprefix -L,$(LIBS_FOLDERS)) $(addprefix -l,$(LIBS))
	arm-none-eabi-size $(OUT_PATH)/$(APPLICATION).axf
	arm-none-eabi-objcopy -v -O binary $(OUT_PATH)/$(APPLICATION).axf $(OUT_PATH)/$(APPLICATION).bin
	@echo ""

# Clean rule: remove generated files and objects
clean:
	rm -f $(OBJ_PATH)/*.*
	rm -f $(OUT_PATH)/*.*
	rm -f *.launch

download: $(APPLICATION)
	@echo "Downloading $(APPLICATION).bin to LPC1769..."
	openocd -f cfg/lpc1769.cfg -c "init" -c "halt 0" -c "flash write_image erase unlock $(OUT_PATH)/$(APPLICATION).bin 0x00000000 bin" -c "reset run" -c "shutdown"
	@echo "Download done."

erase:
	@echo "Erasing flash memory..."
	openocd -f cfg/lpc1769.cfg -c "init" -c "halt 0" -c "flash erase_sector 0 0 last" -c "exit"
	@echo "Erase done."

info:
	@echo C_FILES: $(C_FILES)
	@echo OBJ_FILES: $(OBJ_FILES)
	@echo OBJS: $(OBJS)
	@echo INCLUDES: $(INCLUDES)
	@echo SRC_FOLDERS: $(SRC_FOLDERS)

help:
	@echo Seleccionar la aplicación a compilar copiando project.mk.template a project.mk y modificando la variable PROJECT.
	@echo Ejemplos disponibles:
	@printf "\t$(sort $(notdir $(wildcard examples/*)))\n"

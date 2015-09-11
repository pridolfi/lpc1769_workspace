# User project folder
export APPLICATION  := $(notdir $(shell pwd))

# List of libraries and project to be compiled
PROJECTS := lpc_chip_175x_6x lpc_board_nxp_lpcxpresso_1769 freertos app

# Paths
ROOT_PATH := $(shell pwd)

# Path for compiled files (libraries and binaries)
export OUT_PATH := $(ROOT_PATH)/out

# Path for object files
export OBJ_PATH := $(OUT_PATH)/obj

# Defined symbols
export SYMBOLS := -DDEBUG -DCORE_M3 -D__USE_LPCOPEN -D__LPC17XX__ -D__CODE_RED

# Compilation flags
export CFLAGS  := -Wall -ggdb3 -mcpu=cortex-m3 -mthumb -fdata-sections -ffunction-sections -c

# Linking flags
export LFLAGS  := -nostdlib -fno-builtin -mcpu=cortex-m3 -mthumb -Xlinker -Map=$(OUT_PATH)/$(PROJECT).map -Wl,--gc-sections

# Add object path to search paths
vpath %.o $(OBJ_PATH)
vpath %.a $(OUT_PATH)

# All rule: Compile all libs and executables
$(APPLICATION):
	@for PROJECT in $(PROJECTS) ; do \
		echo "*** Building project $$PROJECT ***" ; \
		make -C $$PROJECT ; \
		echo "" ; \
	done

# Clean rule: remove generated files and objects
clean:
	rm -f $(OBJ_PATH)/*.*
	rm -f $(OUT_PATH)/*.*

download: $(APPLICATION)
	@echo "Downloading $(APPLICATION).bin to LPC1769..."
	openocd -f cfg/lpc1769.cfg -c "init" -c "halt 0" -c "flash write_image erase unlock $(OUT_PATH)/$(APPLICATION).bin 0x00000000 bin" -c "reset run" -c "shutdown"
	@echo "Download done."

erase:
	@echo "Erasing flash memory..."
	openocd -f cfg/lpc1769.cfg -c "init" -c "halt 0" -c "flash erase_sector 0 0 last" -c "exit"
	@echo "Erase done."

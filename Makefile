PROJECT  := app
PROJECTS := lpc_chip_175x_6x lpc_board_nxp_lpcxpresso_1769 $(PROJECT)

ROOT_PATH := $(shell pwd)
export OUT_PATH := $(ROOT_PATH)/out
export OBJ_PATH := $(OUT_PATH)/obj

export CFLAGS  := -Wall -ggdb3 -mcpu=cortex-m3 -mthumb -c
export SYMBOLS := -DDEBUG -DCORE_M3 -D__USE_LPCOPEN -D__LPC17XX__ -D__CODE_RED
export LFLAGS  := -nostdlib -fno-builtin -mcpu=cortex-m3 -mthumb -Xlinker -Map=$(OUT_PATH)/$(PROJECT).map

vpath %.o $(OBJ_PATH)

all:
	@for PROJECT in $(PROJECTS) ; do \
		echo "*** Building project $$PROJECT ***" ; \
		make -C $$PROJECT ; \
		echo "" ; \
	done

clean:
	rm -f $(OBJ_PATH)/*.*
	rm -f $(OUT_PATH)/*.*

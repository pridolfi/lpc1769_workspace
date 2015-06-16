mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

SRC_PATH := ./src
INC_PATH := ./inc
OUT_PATH := ./out
OBJ_PATH := $(OUT_PATH)/obj

SYMBOLS  := -DDEBUG -DCORE_M3 -D__USE_LPCOPEN -D__LPC17XX__ -D__CODE_RED
INCLUDES := -I./inc -I../lpc_chip_175x_6x/inc -I../lpc_board_nxp_lpcxpresso_1769/inc
CFLAGS   := -Wall -ggdb3 -mcpu=cortex-m3 -mthumb -c

LFLAGS   := -nostdlib -fno-builtin -mcpu=cortex-m3 -mthumb -Xlinker -Map=$(OUT_PATH)/$(PROJECT).map
LIB_PATH := -L../lpc_board_nxp_lpcxpresso_1769/out -L../lpc_chip_175x_6x/out 
LIBS	 := -llpc_board_nxp_lpcxpresso_1769 -llpc_chip_175x_6x 
LD_FILE  := -T./ld/lpc17xx.ld

SRC_FILES := $(wildcard $(SRC_PATH)/*.c)
ASM_FILES := $(wildcard $(SRC_PATH)/*.S)
INC_FILES := $(wildcard $(INC_PATH)/*.h)
OBJ_FILES := $(subst $(SRC_PATH),$(OBJ_PATH),$(SRC_FILES:.c=.o))
OBJ_FILES += $(subst $(SRC_PATH),$(OBJ_PATH),$(ASM_FILES:.S=.o))

$(PROJECT): $(OBJ_FILES)
	@echo "*** Linking project $(PROJECT) ***"
	arm-none-eabi-gcc $(LIB_PATH) $(LFLAGS) $(LD_FILE) -o $(OUT_PATH)/$(PROJECT).axf $(OBJ_FILES) $(LIBS) 
	arm-none-eabi-size $(OUT_PATH)/$(PROJECT).axf
	arm-none-eabi-objcopy -v -O binary $(OUT_PATH)/$(PROJECT).axf $(OUT_PATH)/$(PROJECT).bin
	@echo ""

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.c
	@echo "*** Compiling C file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $@ 
	@echo ""

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.S
	@echo "*** Compiling Assembly file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $@
	@echo ""

clean:
	rm -f $(OBJ_PATH)/*.*
	rm -f $(OUT_PATH)/*.*

PROJECT := $(notdir $(shell pwd))

SRC_PATH  := src
INC_PATH  := inc

INCLUDES := -Iinc -I../lpc_chip_175x_6x/inc -I../lpc_board_nxp_lpcxpresso_1769/inc -I../freertos/inc

LIB_PATH := -L$(OUT_PATH)
LIBS	 := -lfreertos -llpc_board_nxp_lpcxpresso_1769 -llpc_chip_175x_6x
LD_FILE  := -T./ld/lpc17xx.ld

SRC_FILES := $(wildcard $(SRC_PATH)/*.c)
ASM_FILES := $(wildcard $(SRC_PATH)/*.S)
OBJ_FILES := $(subst $(SRC_PATH),$(OBJ_PATH),$(SRC_FILES:.c=.o))
OBJ_FILES += $(subst $(SRC_PATH),$(OBJ_PATH),$(ASM_FILES:.S=.o))
OBJS := $(notdir $(OBJ_FILES))

vpath %.c $(SRC_PATH)
vpath %.S $(SRC_PATH)
vpath %.a $(OUT_PATH)

%.o: %.c
	@echo "*** Compiling C file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	@echo ""

%.o: %.S
	@echo "*** Compiling Assembly file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	@echo ""

$(PROJECT): $(OBJS) libfreertos.a liblpc_board_nxp_lpcxpresso_1769.a liblpc_chip_175x_6x.a
	@echo "*** Linking project $(APPLICATION) ***"
	arm-none-eabi-gcc $(LIB_PATH) $(LFLAGS) $(LD_FILE) -o $(OUT_PATH)/$(APPLICATION).axf $(OBJ_FILES) $(LIBS)
	arm-none-eabi-size $(OUT_PATH)/$(APPLICATION).axf
	arm-none-eabi-objcopy -v -O binary $(OUT_PATH)/$(APPLICATION).axf $(OUT_PATH)/$(APPLICATION).bin
	@echo ""

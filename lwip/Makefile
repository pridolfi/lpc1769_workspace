PROJECT := $(notdir $(shell pwd))

LPROJECT  := lib$(PROJECT).a

SRC_PATH  := src
INC_PATH  := inc

INCLUDES  := -Iinc -Iinc/ipv4 -I../lpc_chip_175x_6x/inc -I../lpc_board_nxp_lpcxpresso_1769/inc -I../freertos/inc

SRC_FILES := $(wildcard $(SRC_PATH)/api/*.c)
SRC_FILES += $(wildcard $(SRC_PATH)/arch/*.c)
SRC_FILES += $(wildcard $(SRC_PATH)/core/*.c)
SRC_FILES += $(wildcard $(SRC_PATH)/netif/*.c)

OBJ_FILES := $(addprefix $(OBJ_PATH)/,$(notdir $(SRC_FILES:.c=.o)))

OBJS 		 := $(notdir $(OBJ_FILES))

vpath %.a $(OUT_PATH)
vpath %.o $(OBJ_PATH)
vpath %.c $(SRC_PATH)/api $(SRC_PATH)/arch $(SRC_PATH)/core $(SRC_PATH)/netif

%.o: %.c
	@echo "*** Compiling C file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	@echo ""

$(LPROJECT): $(OBJS)
	@echo "*** Archiving project $(PROJECT) ***"
	arm-none-eabi-ar -r $(OUT_PATH)/$(LPROJECT) $(OBJ_FILES)
	arm-none-eabi-size $(OUT_PATH)/$(LPROJECT)
	@echo ""

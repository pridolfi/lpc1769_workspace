PROJECT   := lpc_chip_175x_6x
LPROJECT  := lib$(PROJECT).a

SRC_PATH  := ./src
INC_PATH  := ./inc
OUT_PATH  := ./out
OBJ_PATH  := $(OUT_PATH)/obj

SYMBOLS   := -DDEBUG -DCORE_M3 -D__USE_LPCOPEN -D__LPC17XX__
INCLUDES  := -I./inc
CFLAGS    := -Wall -ggdb3 -mcpu=cortex-m3 -mthumb -c

SRC_FILES := $(wildcard $(SRC_PATH)/*.c)
INC_FILES := $(wildcard $(INC_PATH)/*.h)
OBJ_FILES := $(subst $(SRC_PATH),$(OBJ_PATH),$(SRC_FILES:.c=.o))

$(LPROJECT): $(OBJ_FILES)
	arm-none-eabi-ar -r $(OUT_PATH)/$(LPROJECT) $(OBJ_FILES)
	arm-none-eabi-size $(OUT_PATH)/$(LPROJECT)

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.c
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $@ 

clean:
	rm -f $(OBJ_PATH)/*.*
	rm -f $(OUT_PATH)/*.*


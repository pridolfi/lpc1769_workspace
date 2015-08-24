PROJECT := $(notdir $(shell pwd))

LPROJECT  := lib$(PROJECT).a

SRC_PATH  := src
INC_PATH  := inc

INCLUDES  := -Iinc

SRC_FILES := $(wildcard $(SRC_PATH)/*.c)
OBJ_FILES := $(subst $(SRC_PATH),$(OBJ_PATH),$(SRC_FILES:.c=.o))
OBJS	  := $(notdir $(OBJ_FILES))

vpath %.c $(SRC_PATH)

%.o: %.c
	@echo "*** Compiling C file $< ***"
	arm-none-eabi-gcc $(SYMBOLS) $(INCLUDES) $(CFLAGS) $< -o $(OBJ_PATH)/$@
	@echo ""

$(LPROJECT): $(OBJS)
	@echo "*** Archiving project $(PROJECT) ***"
	arm-none-eabi-ar -r $(OUT_PATH)/$(LPROJECT) $(OBJ_FILES)
	arm-none-eabi-size $(OUT_PATH)/$(LPROJECT)
	@echo ""

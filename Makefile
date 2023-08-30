OUT_DIR  := build
ROOT = $(shell pwd)

PROJ_NAME = base
TARGET = STM32F40XX

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

CFLAGS  = -O2 -Tlink.ld -Iinc -I src -nostdlib
CFLAGS += -D $(TARGET) -DUSE_STDPERIPH_DRIVER -D"HSE_VALUE=((uint32_t)8000000)"
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16


C_SRCS     = $(shell find src -name "*.c")
LIB_SRCS   = $(shell find lib -name "*.c")
OTHER_OBJS = $(addprefix $(OUT_DIR)/, startup_stm32f40_41xxx.o)
#CPP_SRCS  = $(shell find src -name "*.cpp")

C_OBJS    = $(addprefix $(OUT_DIR)/, $(C_SRCS:.c=.o))
LIB_OBJS  = $(LIB_SRCS:.c=.o)
#CPP_OBJS  = $(CPP_SRCS:.c=.o)

OBJS     := $(C_OBJS)


build: prebuild $(PROJ_NAME).elf

lib_only: $(LIB_OBJS)

openocd:
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

prebuild:
	mkdir -p $(OUT_DIR)/src

$(PROJ_NAME).elf: $(C_OBJS) $(OTHER_OBJS) $(LIB_OBJS)
	#$(CC) $(CFLAGS) $(C_SRCS) src/startup_stm32f40_41xxx.s -o $@
	$(CC) $(CFLAGS) $^ -o $@
	$(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).ihx

$(C_OBJS): $(OUT_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

$(OUT_DIR)/startup_stm32f40_41xxx.o: src/startup_stm32f40_41xxx.s
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	@rm -rf build *.elf *.ihx *.bin
	@rm -rf lib/*.o

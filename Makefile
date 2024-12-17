ASM=nasm
CC=gcc

TOOLS_DIR=tools
BUILD_DIR=build

.PHONY: all floppy_image kernel bootloader clean always tools_fat

all: floppy_image tools_fat

#
# Floppy image
#

floppy_image: $(BUILD_DIR)/atlas_floppy.img

# for linux
# dd if=/dev/zero of=$(BUILD_DIR)/atlas_floppy.img bs=512 count=2880
# mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/atlas_floppy.img

$(BUILD_DIR)/atlas_floppy.img: bootloader kernel
	hdiutil create -size 1440k -fs "MS-DOS FAT12" -layout NONE -ov $(BUILD_DIR)/main_floppy.img
	mv $(BUILD_DIR)/main_floppy.img.dmg $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/atlas_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/atlas_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/atlas_floppy.img test.txt "::test.txt"

#
# Bootloader
#
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

#
# Tools
#
tools_fat: $(BUILD_DIR)/tools/fat
$(BUILD_DIR)/tools/fat: always $(TOOLS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g -o $(BUILD_DIR)/tools/fat $(TOOLS_DIR)/fat/fat.c

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	rm -rf $(BUILD_DIR)/*
# jackBoot
JackBoot is a simple bootloader capable to print some message to the user (a welcome message and the quantity of memory available in real mode) and create a simple graphical effect.

To compile the project, you should first of all change the Makefile writing in the TARGET section the prefix of your toolchain (i'm using the i486 toolchain available with the slitaz distro). After saving the change on the Makefile, you can execute make and it will create: 
    - an object file (boot.o) 
    - a binary file which contains the plain binary code of the boot loader(jackBoot.bin)
    - a floppy image which we’ll use to start our boot loader

In order to write the boot loader in a real floppy disk, change the IMAGE section of the Makefile in /dev/fd0 (which usually is the device file linked with the floppy device) and then run make.
    
# Usage
If you want to emulate the boot you can simply use a virtual machine like qemu giving the floppy image as a floppy drive to boot. Usually i execute:
   qemu-system-i386 -fda floppy.img 

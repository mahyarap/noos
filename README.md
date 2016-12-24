# No Operating System

### Requirements
    sudo apt-get install build-essential qemu

### Building
`cd` into the project directory and run `make` to compile and link the code.

### Running
Run `qemu-system-i386 -drive format=raw,file=noos.img` from the project
directory.

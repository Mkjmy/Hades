# hades

slapped some x86_64 assembly together. it breaks things. that's about it.

### why use this

- **raw assembly:** no libraries, just syscalls because i hate myself.
- **sigkill spree:** nukes every process you own the second it starts.
- **immortal fork loop:** fills your process table until the cpu starts screaming.
- **disk siphon:** writes junk to your disk until the i/o wait freezes everything.
- **tty hijack:** displays red text in your terminal while you watch your system die.

### install (in a vm, obviously)

#### 1. prep your lab
get a vm (alpine is light, arch is for the brave). backups are for the weak, but snapshots are for people who don't want to reinstall their OS every 10 minutes.

#### 2. compile and pray
you'll need `nasm` and `binutils`. 
```bash
# build the beast
nasm -f elf64 hades.asm -o h.o
ld h.o -o hades
```

### execution

**warning:** there are no locks. this is raw.
```bash
./hades
```

### note

i did skim through the register logic, but not enough to actually understand what the kernel is doing half the time. so if something breaks and your vm never boots again, i probably won't know why. 

### disclaimer

this works for me in an alpine vm. 

if you didn't take a snapshot and everything is gone, well... now you know why people do snapshots. 

i don't really know what i'm doing either. use it if you want, or don't. good luck.

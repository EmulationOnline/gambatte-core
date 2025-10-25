# force rebuild, while deps isn't working
.PHONY: libgb.so clean run runc all ci deps deps-main

all: libgb.so main

deps:
	apt install -y g++
debs-main: deps
	apt install -y libsdl2-dev

ci: deps libgb.so

# TODO: re-add O3
EMBEDFLAGS=-O3 -fvisibility=hidden -static-libstdc++ -fPIC -Wfatal-errors -Werror -Wno-narrowing
# CFLAGS=-fvisibility=hidden -ffreestanding -nostdlib -fPIC -O3 -Wfatal-errors -Werror
SRCS := $(wildcard libgambatte/src/**/*.cpp libgambatte/src/*.cpp) -x c++ libgambatte/libretro/blipper.c
libgb.so: libgb.cpp corelib.h
	$(CXX) $(CFLAGS) $(EMBEDFLAGS) -D__LIBRETRO__ -I libgambatte/include -I libgambatte/src -I common/ -shared -o libgb.so libgb.cpp $(SRCS)
	cp libgb.so libapu.so
	echo "libgb done"

main: main.c corelib.h
	$(CXX) -O3 -o main main.c -L. -l:libgb.so -lSDL2 -lc -lm ${WARN}
	echo "main done"

clean:
	rm -f libgb.so

gdb:
	LD_LIBRARY_PATH=$(shell pwd) gdb --args ./main "$(ROM)"
run:
	LD_LIBRARY_PATH=$(shell pwd) ./main "$(ROM)"
runc:
	LD_LIBRARY_PATH=$(shell pwd) ./main "$(ROM)" c
	

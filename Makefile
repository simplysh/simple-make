program = sample

# config
srcprefix := ./src
sdlprefix := C:\libsdl

# shell
rm := $(if $(filter $(OS),Windows_NT),del /Q,rm -f)
cp := $(if $(filter $(OS),Windows_NT),copy,cp)
cat := $(if $(filter $(OS),Windows_NT),type,cat)

# sdl
ifdef sdlprefix
	sdllibs := -lSDL2main -lSDL2 -lSDL2_image -lSDL2_ttf
	sdlflags := $(sdllibs)
endif

# windows-only
ifeq ($(filter $(OS),Windows_NT), Windows_NT)
	winflags := -static-libgcc -static-libstdc++

	ifdef sdlprefix
		sdlflags := -I${sdlprefix}\include\SDL2 -L${sdlprefix}\lib -lmingw32 $(sdllibs) -mwindows
	endif
endif

# linux-only
ifeq ($(shell uname -s), Linux)
	linuxflags := -no-pie
endif

# compiler
cxx := g++
cxxflags := -std=c++14 -pedantic-errors
varflags = -DVERSION="\"$(shell $(cat) VERSION)\""
out := $(if $(filter $(OS),Windows_NT),.\$(program).exe,./$(program))
dest := $(if $(filter $(OS),Windows_NT),$(shell echo %SYSTEMROOT%),/usr/local/bin)
src := $(wildcard $(srcprefix)/*.cpp)
obj := $(src:$(srcprefix)/%.cpp=./%.o)
flags := $(cxxflags) $(winflags) $(linuxflags)

all: $(out)
	@echo success!

$(out): $(obj)
	$(cxx) $(flags) $^ $(sdlflags) -o $@

main.o: $(srcprefix)/main.cpp
	$(cxx) -c $(cxxflags) $(varflags) $(srcprefix)/main.cpp -o main.o

./%.o: $(srcprefix)/%.cpp $(srcprefix)/%.h
	$(cxx) -c $(cxxflags) $< -o $@

.PHONY: clean
clean:
	$(rm) *.o $(out)

.PHONY: install
install:
	@echo installing to $(dest)
	$(cp) $(out) $(dest)

# target: dependencies
# 	action

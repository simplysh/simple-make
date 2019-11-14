program = sample

# config
sdlprefix = C:\libsdl

# shell
rm = $(if $(filter $(OS),Windows_NT),del /Q,rm -f)
cp = $(if $(filter $(OS),Windows_NT),copy,cp)
cat = $(if $(filter $(OS),Windows_NT),type,cat)

# sdl
ifdef sdlprefix
	sdllibs = -lSDL2main -lSDL2 -lSDL2_image -lSDL2_ttf
	sdlflags = $(sdllibs)
endif

# windows-only
ifeq ($(filter $(OS),Windows_NT), Windows_NT)
	winflags = -static-libgcc -static-libstdc++

	ifdef sdlprefix
		sdlflags = -I${sdlprefix}\include\SDL2 -L${sdlprefix}\lib -lmingw32 $(sdllibs) -mwindows
	endif
endif

# compiler
cxx = g++
cxxflags = -std=c++14 -pedantic-errors
out = $(if $(filter $(OS),Windows_NT),.\$(program).exe,./$(program))
dest = $(if $(filter $(OS),Windows_NT),$(shell echo %SYSTEMROOT%),/usr/local/bin)
src = $(wildcard ./*.cpp)
obj = $(src:.cpp=.o)
flags = $(cxxflags) $(winflags) -DVERSION="\"$(shell $(cat) VERSION)\""

all: $(out)

$(out): $(obj)
	$(cxx) $(flags) $^ $(sdlflags) -o $@

main.o: main.cpp
	$(cxx) -c $(flags) main.cpp $(sdlflags) -o main.o

./%.o: ./%.cpp ./%.h
	$(cxx) -c $(flags) $< $(sdlflags) -o $@

clean:
	$(rm) *.o $(out)

install:
	@echo installing to $(dest)
	$(cp) $(out) $(dest)

# target: dependencies
# 	action

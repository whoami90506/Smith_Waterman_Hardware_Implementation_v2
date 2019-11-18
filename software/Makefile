file := src
target := SmithWaterman

CC := g++
CFLAGS := -Wall -g --std=c++11 -I $(file)  
CFLAGS := -Wall -O3 --std=c++11 -I $(file)

SRCS := $(wildcard $(file)/*.cpp)
OBJS := $(patsubst %.cpp,%.o,$(SRCS))

.PHONY: all clean matrix trace both old

all : MAKEFLAGS = $(CFLAGS)
matrix : MAKEFLAGS = -D DEBUG_PRINTMATRIX $(CFLAGS)
trace : MAKEFLAGS = -D TRACE $(CFLAGS)
both : MAKEFLAGS = -D DEBUG_PRINTMATRIX -D TRACE $(CFLAGS)
old : MAKEFLAGS = $(CFLAGS)

all: $(file)/linear.o
	$(CC) -o $(target) $(MAKEFLAGS) $^
matrix: $(file)/matrix.o
	$(CC) -o $(target) $(MAKEFLAGS) $^
trace: $(file)/matrix.o
	$(CC) -o $(target) $(MAKEFLAGS) $^
both: $(file)/matrix.o
	$(CC) -o $(target) $(MAKEFLAGS) $^
old: $(file)/matrix.o
	$(CC) -o $(target) $(MAKEFLAGS) $^

%.o: %.cpp
	$(CC) $(MAKEFLAGS) -c $< -o $@

clean:
	rm -rf $(file)/*.o
	rm -rf $(target)

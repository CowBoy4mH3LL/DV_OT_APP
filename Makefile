#~ Args
dflags=$(DFLAGS)

#~ Settings
app=vuln_app
BLD=objects
SRC=src
comm=comm
dma=dma
main=main
flags_file=commands.sh
common_header=common.h

all: vuln_app

$(BLD)/$(comm).o:$(SRC)/$(comm).c $(flags_file) $(SRC)/$(common_header)
	gcc $(dflags) -c -fPIC -o $@ $<

$(BLD)/lib$(comm).so:$(BLD)/$(comm).o
	gcc -shared $< -o $@

$(BLD)/$(dma).o:$(SRC)/$(dma).c $(flags_file) $(SRC)/$(common_header)
	gcc $(dflags) -c -fPIC -o $@ $<

$(BLD)/lib$(dma).so:$(BLD)/$(dma).o
	gcc -shared $< -o $@

vuln_app:$(SRC)/$(main).c $(BLD)/lib$(comm).so $(BLD)/lib$(dma).so $(flags_file) $(SRC)/$(common_header)
	echo $(shell pwd) 
	gcc $(dflags) $< -o $(app) -L$(BLD) -l$(comm) -l$(dma) -Wl,-rpath=$(shell pwd)/$(BLD)

.PHONY:clean
clean:
	rm -rf $(BLD)/*
	rm -rf $(app)

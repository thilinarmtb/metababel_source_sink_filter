CC ?= icx
CFLAGS = -fPIC -shared -Werror
MPICC = mpicc
RUBY = ruby
BBT2 = babeltrace2
IPROF = $(THAPIDIR)/bin/iprof --no-analysis
THAPIDIR = ../THAPI/ici
MBDIR =../metababel/

################# Don't touch what follows ####################
TRACEDIR=traces
BBT2FLAGS = $(shell pkg-config --cflags $(BBT2)) $(shell pkg-config --libs $(BBT2))
INCFLAGS = -I$(THAPIDIR)/include
LDFLAGS = -Wl,-rpath,$(THAPIDIR)/lib -L$(THAPIDIR)/lib -lThapi
BINS = mpi

all: run_mpi

source: toggle.yaml btx_source/callbacks.c
	$(RUBY) -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SOURCE --downstream toggle.yaml -o btx_source
	$(CC) -g -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I./btx_source -I$(MBDIR)/include $(CFLAGS) $(BBT2FLAGS)

sink: toggle.yaml btx_sink/callbacks.c
	$(RUBY) -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SINK --upstream toggle.yaml -o btx_sink
	$(CC) -g -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I ./btx_sink -I$(MBDIR)/include $(CFLAGS) $(BBT2FLAGS)

run_source: source
	babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.text.details

run_sink: sink source
	babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

bins: $(BINS)

%: %.c
	$(MPICC) $(INCFLAGS) $< -o $@ $(LDFLAGS)

trace_%: % bins
	@rm -rf $(TRACEDIR)
	$(IPROF) --trace_output $(TRACEDIR) -- ./$<

run_%: trace_% sink
	$(BBT2) --plugin-path=. run  --component source:source.ctf.fs --params "inputs=[\"$(shell find $(TRACEDIR) -iname metadata)/..\"]" --component=sink:sink.text.details --connect=source:sink

clean:
	@rm -rf btx_source/btx_main.c btx_source/metababel
	@rm -rf btx_sink/btx_main.c btx_sink/metababel
	@rm -rf btx_*.so
	@rm -rf $(BINS) $(TRACEDIR)

print-%:
	$(info [          name]: $*)
	$(info [        origin]: $(origin $*))
	$(info [        flavor]: $(flavor $*))
	$(info [         value]: $(value $*))
	$(info [expanded value]: $($*))
	$(info)
	@true

CC ?= icx
CFLAGS = -fPIC -shared -Werror -g
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
	$(CC) $(CFLAGS) -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I./btx_source -I$(MBDIR)/include $(BBT2FLAGS)

sink: toggle.yaml btx_sink/callbacks.c
	$(RUBY) -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SINK --upstream toggle.yaml -o btx_sink
	$(CC) $(CFLAGS) -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I ./btx_sink -I$(MBDIR)/include $(BBT2FLAGS)

filter: toggle.yaml btx_filter/callbacks.c
	$(RUBY) -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type FILTER --upstream toggle.yaml --downstream toggle.yaml -o btx_filter
	$(CC) $(CFLAGS) -o btx_filter.so btx_filter/*.c btx_filter/metababel/*.c -I ./btx_filter -I$(MBDIR)/include $(BBT2FLAGS)

bins: $(BINS)

run_source: source
	$(BBT2) --plugin-path=. --component=source.metababel_source.btx --component=sink.text.details

run_txt_sink: source
	$(BBT2) --plugin-path=. --component=source.metababel_source.btx --component=sink.text.details

run_mb_sink: sink source
	$(BBT2) --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

run_filter: source filter
	$(BBT2) --plugin-path=. --component=source.metababel_source.btx --component=filter.metababel_filter.btx --component=sink.text.pretty

%: %.c
	$(MPICC) $(INCFLAGS) $< -o $@ $(LDFLAGS)

trace_%: % bins
	@rm -rf $(TRACEDIR)
	$(IPROF) --trace_output $(TRACEDIR) -- ./$<

run_%_mb_sink: trace_% sink
	$(BBT2) --plugin-path=. --component source:source.ctf.fs --params "inputs=[\"$(shell dirname $(shell find $(TRACEDIR) -iname metadata))\"]" --component=sink:sink.metababel_sink.btx

run_%_txt_sink: trace_% sink
	$(BBT2) --plugin-path=. --component source:source.ctf.fs --params "inputs=[\"$(shell dirname $(shell find $(TRACEDIR) -iname metadata))\"]" --component=sink:sink.text.pretty

run_%_filter: trace_% filter
	$(BBT2) --plugin-path=. --component source:source.ctf.fs --params "inputs=[\"$(shell dirname $(shell find $(TRACEDIR) -iname metadata))\"]" --component=filter:filter.metababel_filter.btx \
		--component=sink:sink.text.pretty

clean:
	@rm -rf btx_source/btx_main.c btx_source/metababel
	@rm -rf btx_sink/btx_main.c btx_sink/metababel
	@rm -rf btx_filter/btx_main.c btx_filter/metababel
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

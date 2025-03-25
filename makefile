CC ?= icc
CFLAGS ?= -fpic -shared -Werror
CXX ?= icpx
CXXFLAGS= -fsycl
RUBY ?= ruby
IPROF ?= iprof
BBT2 ?= babeltrace2
MBDIR ?=../metababel/

################# Don't touch what follows ####################
CFLAGS += $(shell pkg-config --cflags $(BBT2)) $(shell pkg-config --libs $(BBT2))
all: sink

source: toggle.yaml btx_source/callbacks.c
	$(RUBY) -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SOURCE --downstream toggle.yaml -o btx_source
	$(CC) -g -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I./btx_source -I$(MBDIR)/include $(CFLAGS)
	babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.text.details

sink: toggle.yaml btx_sink/callbacks.c source
	$(RUBY) -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SINK --upstream toggle.yaml -o btx_sink
	$(CC) -g -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I ./btx_sink -I$(MBDIR)/include $(CFLAGS)
	babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

sycl: device_discovery

%: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

run_%: % sycl
	$(IPROF) --trace_output traces -- ./$<
	$(BBT2) run  --component source:source.ctf.fs --params "inputs=[\"./traces/x4605c4s6b0n0/trace\"]" --component=sink:sink.text.details --connect=source:sink

clean:
	@rm -rf btx_source/btx_main.c btx_source/metababel
	@rm -rf btx_sink/btx_main.c btx_sink/metababel
	@rm -rf btx_*.so
	@rm -rf device_discovery traces

print-%:
	$(info [          name]: $*)
	$(info [        origin]: $(origin $*))
	$(info [        flavor]: $(flavor $*))
	$(info [         value]: $(value $*))
	$(info [expanded value]: $($*))
	$(info)
	@true

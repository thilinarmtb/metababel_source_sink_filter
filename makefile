CC=gcc
CFLAGS=$(shell pkg-config --cflags babeltrace2) $(shell pkg-config --libs babeltrace2) -fpic -shared -Werror
MBDIR=../metababel/

all: source sink

source: toggle.yaml btx_source/callbacks.c
	@ruby -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SOURCE --downstream toggle.yaml -o btx_source
	$(CC) -g -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I./btx_source -I$(MBDIR)/include $(CFLAGS)
	babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.text.details

sink: toggle.yaml btx_sink/callbacks.c
	@ruby -I$(MBDIR)/lib $(MBDIR)/bin/metababel --component-type SINK --upstream toggle.yaml -o btx_sink
	$(CC) -g -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I ./btx_sink -I$(MBDIR)/include $(CFLAGS)
	babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

clean:
	@rm -rf btx_source/btx_main.c btx_source/metababel
	@rm -rf btx_sink/btx_main.c btx_sink/metababel
	@rm -rf btx_*.so 

print-%:
	$(info [          name]: $*)
	$(info [        origin]: $(origin $*))
	$(info [        flavor]: $(flavor $*))
	$(info [         value]: $(value $*))
	$(info [expanded value]: $($*))
	$(info)
	@true

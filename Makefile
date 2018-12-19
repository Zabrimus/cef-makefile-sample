CEF_INSTALL_DIR = /opt/cef
CEF_BUILD = http://opensource.spotify.com/cefbuilds/cef_binary_3.3578.1860.g36610bd_linux64_minimal.tar.bz2

CC = g++
CFLAGS = -c -Wall
LDFLAGS =

SOURCES = cefsimple_linux.cc simple_app.cc simple_handler.cc simple_handler_linux.cc
OBJECTS = $(SOURCES:.cc=.o)

EXECUTABLE = cefsimple

CFLAGS += `pkg-config --cflags cef`
LDFLAGS += `pkg-config --libs cef`


all: prepareexe $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
	mv cefsimple Release
	cd Release && ./cefsimple

prepareexe:
	sed -i "/.*const char\* resourcepath/c \ \ const char* resourcepath = \"$(CEF_INSTALL_DIR)/lib\";" cefsimple_linux.cc
	sed -i "/.*const char\* localespath/c \ \ const char* localespath = \"$(CEF_INSTALL_DIR)/lib/locales\";" cefsimple_linux.cc
	sed -i "/.*const char\* frameworkpath/c \ \ const char* frameworkpath = \"$(CEF_INSTALL_DIR)/lib\";" cefsimple_linux.cc
	mkdir -p Release && \
	cd Release && \
	rm -f icudtl.dat natives_blob.bin v8_context_snapshot.bin && \
	ln -s $(CEF_INSTALL_DIR)/lib/icudtl.dat && \
	ln -s $(CEF_INSTALL_DIR)/lib/natives_blob.bin && \
	ln -s $(CEF_INSTALL_DIR)/lib/v8_context_snapshot.bin

.cc.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)
	rm -Rf cef_binary*
	rm -Rf Release


# download and install cef binary
prepare:
	mkdir -p $(CEF_INSTALL_DIR)/lib
	mkdir -p /usr/local/lib/pkgconfig
	curl -L $(CEF_BUILD)  -o - | tar -xjf -
	cd cef_binary* && \
	cmake . && \
        make -j 6 && \
	cp -r include $(CEF_INSTALL_DIR) && \
	cp -r Release/* $(CEF_INSTALL_DIR)/lib && \
	cp -r Resources/* $(CEF_INSTALL_DIR)/lib && \
	cp libcef_dll_wrapper/libcef_dll_wrapper.a $(CEF_INSTALL_DIR)/lib
	sed "s:CEF_INSTALL_DIR:$(CEF_INSTALL_DIR):g" < cef.pc.template > cef.pc
	mv cef.pc /usr/local/lib/pkgconfig
	echo "$(CEF_INSTALL_DIR)/lib" > /etc/ld.so.conf.d/cef.conf
	ldconfig



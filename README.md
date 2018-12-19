# cef-makefile-sample
Simple Makefile project which prepares a shared CEF (chromium embedded framework) installation and compiles a sample appication.

The usage of CEF (chrome embedded framework) has several disadvantages:
- it's not easy to use a shared installation of CEF for multiple applications
- the final binary expects some CEF libraries in the same directory as the application itself

This project demonstrates how to prepare a CEF installation to allow a shared installation.

The Makefile consists of several targets:
### make prepare
- Downloads a prebuild CEF binary from http://opensource.spotify.com/cefbuilds/index.html
- Compiles the library libcef_dll_wrapper.a
- install all libraries, include files of CEF into a common directory
- install cef.pc into /usr/local/lib/pkgconfig to be able to use pkg-config
- install cef.conf into /etc/ld.so.conf.d to be able to use CEF without setting LD_LIBRARY_PATH

### make all
- compiles and starts the CEF sample application cefsimple. The application can be found in the directory Release
- creates 3 links into the CEF installation, because of a CEF restriction described below
- The source file cefsimple_linux.cc is patched before compiling to set the CEF installation directory. This is the worst possible solution, but the easiest one. A better solution would be to use command line arguments or a different configuration file.

### CEF Restrictions
A CEF binary expects at least the files icudtl.dat, natives_blob.bin and v8_context_snapshot.bin to be in the same directory as the binary itself. 
Unfortunately this restriction currently cannot be dropped. In this project soft-links are created to fulfill the requirement.
The usage of icudtl.dat can be easily removed by patching CEF. But this requires a CEF recompile. But the other restrictions are not that easy to be removed.

Another restriction is the usage of the precompiled binary. Some build flags are not set to enable some video and audio codecs.

SHELL:=bash
SLEEPT:=3s
PORTS:=1738 1739 1740

all: tests

tests: anybar
	@echo "Starting..." && \
    echo -n " WHITE " && \
    for port in $(PORTS) ; do ANYBAR_PORT=$$port open -n ../build/Debug/AnyBar.app ; done && \
    sleep $(SLEEPT) && \
    echo -n " ORANGE " && \
    for port in $(PORTS) ; do echo -n "orange" | nc -4u -w0 localhost $$port ; done && \
    sleep $(SLEEPT) && \
    echo -n " RGB " && \
    echo -n "red" | nc -4u -w0 localhost 1738 && \
    echo -n "green" | nc -4u -w0 localhost 1739 && \
    echo -n "blue" | nc -4u -w0 localhost 1740 && \
    sleep $(SLEEPT) && \
    echo -n " BLACK " && \
    for port in $(PORTS) ; do echo -n "black" | nc -4u -w0 localhost $$port ; done && \
    sleep $(SLEEPT) && \
    echo -n " WHITE " && \
    for port in $(PORTS) ; do echo -n "white" | nc -4u -w0 localhost $$port ; done && \
    sleep $(SLEEPT) && \
    echo && \
    echo "Stopping..." && \
    for port in $(PORTS) ; do echo -n "quit" | nc -4u -w0 localhost $$port ; done && \
    sleep $(SLEEPT) && \
    echo "Done."

anybar: ../AnyBar.xcodeproj
	@xcodebuild -configuration Debug -target AnyBar -project $< build

clean: ../AnyBar.xcodeproj
	-@xcodebuild -configuration Debug -target AnyBar -project $< clean 2>&1>/dev/null
	-@rm -rf ../build

.PHONY: all tests anybar clean

.SILENT: clean


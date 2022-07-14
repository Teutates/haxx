PROGS = haxx launchd
CC ?= clang
STRIP ?= strip
CFLAGS ?= -Os -isysroot $(shell xcrun -sdk iphoneos --show-sdk-path) -miphoneos-version-min=14.0 -arch arm64
LDLFAGS ?= -lSystem

all: $(PROGS)
	ldid -Slaunchd.xml -Kdev_certificate.p12 -Upassword launchd

clean:
	rm -f $(PROGS)

%: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@
	$(STRIP) $@
	ldid -Sentitlements.xml -Kdev_certificate.p12 -Upassword $@

pack: all
	mkdir -p ./tmp/{DEBIAN,sbin}
	for file in control postrm preinst; do \
		cp -a template.$$file ./tmp/DEBIAN/$$file; \
	done
	cp -a $(PROGS) ./tmp/sbin
	dpkg-deb --root-owner-group -b ./tmp ./u0inaru_0.0.1_iphoneos-arm.deb
	rm -rf ./tmp

.PHONY: all clean

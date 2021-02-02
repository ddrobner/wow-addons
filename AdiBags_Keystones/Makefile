VERSION = $(shell awk '/Version/ {print $$3;}' *.toc)

package: AdiBags_Keystones-${VERSION}.zip

AdiBags_Keystones-${VERSION}.zip: AdiBags_Keystones.toc AdiBags_Keystones.lua
	install -d AdiBags_Keystones
	cp $^ AdiBags_Keystones
	zip -r AdiBags_Keystones-${VERSION}.zip AdiBags_Keystones
	rm -rf AdiBags_Keystones

clean:
	rm -f *.zip

.PHONY: package clean

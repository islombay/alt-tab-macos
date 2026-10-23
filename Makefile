# Local prod build of AltTab. Signing identity lives in config/local.xcconfig.

# CI injects CURRENT_PROJECT_VERSION at release time, so a plain local build has no
# version at all; derive it from the newest tag to stay correct across master merges.
VERSION := $(patsubst v%,%,$(shell git describe --tags --abbrev=0 2>/dev/null))
APP := DerivedData/Build/Products/Release/AltTab.app

.PHONY: build install reset zip clean

build:
	xcodebuild -project alt-tab-macos.xcodeproj -scheme Release -configuration Release \
	  -derivedDataPath DerivedData CURRENT_PROJECT_VERSION=$(VERSION) build

install: build
	-osascript -e 'quit app "AltTab"'
	rm -rf /Applications/AltTab.app
	ditto $(APP) /Applications/AltTab.app
	open /Applications/AltTab.app

# Only needed when the signing identity changes; a stable identity keeps its grants.
reset:
	tccutil reset Accessibility com.lwouis.alt-tab-macos
	tccutil reset ScreenCapture com.lwouis.alt-tab-macos

# ditto, not `zip`: it preserves the symlinks and xattrs the code signature covers.
zip: build
	ditto -c -k --keepParent $(APP) ~/Desktop/AltTab-$(VERSION).zip

clean:
	rm -rf DerivedData

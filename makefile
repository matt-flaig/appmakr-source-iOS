default:
  # Set default make action here

# If you need to clean a specific target/configuration: $(COMMAND) -target $(TARGET) -configuration DebugOrRelease -sdk $(SDK) clean
clean:
	xcodebuild -alltargets -configuration Debug -sdk iphonesimulator clean
	xcodebuild -alltargets -configuration Distribution -sdk iphoneos clean

test:	
	WRITE_JUNIT_XML=YES GHUNIT_UI_CLI=1 xcodebuild -target appbuildrTests -configuration Debug -sdk iphonesimulator build

app:
	xcodebuild -target appbuildr -configuration Distribution -sdk iphoneos PROVISIONING_PROFILE="1A213DE9-620E-4955-BC66-2B0CB785AA1B" CODE_SIGN_IDENTITY="iPhone Distribution: pointabout" APPLE_BUILD=NO clean build


.PHONY: get codegen build clean test

get:
	flutter pub get

codegen: get
	dart run build_runner build --delete-conflicting-outputs

build: codegen
	flutter build apk --release

clean:
	flutter clean
	flutter pub get

test:
	flutter test

run:
	flutter run

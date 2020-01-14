.PHONY: clean
.PHONY: build
.PHONY: build-and-run

# Remove the build files
clean:
	rm -rf build.pdx

# Build the game (make sure to add pdc to your path)
build: clean
	pdc source build.pdx

# Run the game
build-and-run: build
	open build.pdx
.PHONY: build clean install validate help

# Variables
THEME_DIR = utility-materials
DIST_DIR = dist
BLENDER = /Applications/Blender.app/Contents/MacOS/Blender

# Default target
help:
	@echo "Utility Materials Blender Theme - Build System"
	@echo ""
	@echo "Available commands:"
	@echo "  make build    - Build the theme extension using Blender CLI"
	@echo "  make validate - Validate the extension manifest"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make install  - Build and install the theme locally"
	@echo "  make help     - Show this help message"

# Build the extension package using Blender CLI
build:
	@echo "Building Utility Materials theme extension using Blender CLI..."
	@mkdir -p $(DIST_DIR)
	@if command -v $(BLENDER) >/dev/null 2>&1; then \
		cd $(THEME_DIR) && $(BLENDER) --command extension build --valid-tags ../valid-tags.json --output-dir ../$(DIST_DIR); \
		echo "✓ Extension built successfully"; \
		echo "  Output: $(DIST_DIR)/*.zip"; \
		ls -lh $(DIST_DIR)/*.zip 2>/dev/null || true; \
	else \
		echo "❌ Error: Blender not found in PATH"; \
		echo "  Please install Blender or set BLENDER variable:"; \
		echo "  make build BLENDER=/path/to/blender"; \
		exit 1; \
	fi

# Validate the extension manifest
validate:
	@echo "Validating extension manifest..."
	@if command -v $(BLENDER) >/dev/null 2>&1; then \
		cd $(THEME_DIR) && $(BLENDER) --command extension validate; \
		echo "✓ Validation complete"; \
	else \
		echo "❌ Error: Blender not found in PATH"; \
		exit 1; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(DIST_DIR)
	@rm -f $(THEME_DIR)/*.zip
	@echo "✓ Clean complete"

# Install the theme locally
install: build
	@echo "Installing theme to Blender..."
	@if command -v $(BLENDER) >/dev/null 2>&1; then \
		ZIP_FILE=$$(ls -t $(DIST_DIR)/*.zip 2>/dev/null | head -1); \
		if [ -n "$$ZIP_FILE" ]; then \
			$(BLENDER) --command extension install-file $$ZIP_FILE; \
			echo "✓ Theme installed successfully from $$ZIP_FILE"; \
		else \
			echo "❌ No built extension found. Run 'make build' first."; \
		fi \
	else \
		echo "❌ Error: Blender not found in PATH"; \
		exit 1; \
	fi

# Build with custom Blender path (for macOS app bundle)
build-mac:
	@echo "Building with macOS Blender.app..."
	$(MAKE) build BLENDER="/Applications/Blender.app/Contents/MacOS/Blender"

# Watch for changes and rebuild (requires fswatch or inotify-tools)
watch:
	@echo "Watching for changes..."
	@if command -v fswatch >/dev/null 2>&1; then \
		fswatch -o $(THEME_DIR)/*.xml $(THEME_DIR)/*.toml | xargs -n1 -I{} $(MAKE) build; \
	elif command -v inotifywait >/dev/null 2>&1; then \
		while true; do \
			inotifywait -e modify $(THEME_DIR)/*.xml $(THEME_DIR)/*.toml; \
			$(MAKE) build; \
		done \
	else \
		echo "❌ Install fswatch (macOS) or inotify-tools (Linux) for watch mode"; \
		exit 1; \
	fi
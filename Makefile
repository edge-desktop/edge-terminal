VALAC = valac

PKG = --pkg gtk+-3.0 \
      --pkg vte-2.91

SRC = src/edge_terminal.vala \
      src/window.vala \
      src/headerbar.vala \
      src/terminal.vala \
      src/flowbox.vala \
      src/globals.vala \
      src/utils.vala

BIN = edge-terminal

all:
	$(VALAC) $(PKG) $(SRC) -o $(BIN)


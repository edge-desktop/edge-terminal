namespace ETerm {

    public class Window: Gtk.ApplicationWindow {

        public ETerm.App app;
        public ETerm.HeaderBar headerbar;
        public ETerm.FlowBox flowbox;
        public ETerm.Terminal selected_terminal;

        public Gtk.Stack stack;
        public Gtk.Box terminal_box;

        public ETerm.WindowState state = ETerm.WindowState.NO_STARTED;

        private uint TIMEOUT_ID = 0;

        public Window(ETerm.App app) {
            this.app = app;

            this.set_title("Terminal");

            this.headerbar = new ETerm.HeaderBar();
            this.headerbar.show_grid.connect(this.show_grid_cb);
            this.set_titlebar(this.headerbar);

            this.stack = new Gtk.Stack();
            this.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            this.stack.set_transition_duration(250);
            this.add(this.stack);

            this.flowbox = new ETerm.FlowBox();
            this.flowbox.page_changed.connect(this.page_changed_cb);
            this.stack.add_named(this.flowbox, "flowbox");

            this.terminal_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.stack.add_named(this.terminal_box, "term_box");

            this.realize.connect(this.realize_cb);

            this.new_term();
            this.show_all();
        }

        private void realize_cb(Gtk.Widget widget) {
            this.flowbox.set_current_term_from_index(0);
            this.page_changed_cb(this.flowbox.selected_terminal);
        }

        private void show_grid_cb(ETerm.HeaderBar headerbar, bool show) {
            this.set_term_state(show? ETerm.WindowState.GRID: ETerm.WindowState.TERMINAL);
        }

        private void grab_term_focus() {
            ETerm.Terminal term = this.flowbox.selected_terminal;

            if (!term.has_focus) {
                term.grab_focus();
            }
        }

        public void set_term_state(ETerm.WindowState state, bool force = false) {
            if (this.state == state && !force) {
                return;
            }

            this.state = state;

            switch (state) {
                case ETerm.WindowState.TERMINAL:
                    this.stack.set_visible_child(this.terminal_box);
                    this.headerbar.grid_button.set_active(false);

                    this.TIMEOUT_ID = GLib.Timeout.add(300, () => {
                        this.grab_term_focus();
                        return false;
                    });

                    if (this.flowbox.selected_terminal != null) {
                        this.flowbox.selected_terminal.grab_focus();
                    }

                    break;

                case ETerm.WindowState.GRID:
                    this.stack.set_visible_child(this.flowbox);
                    this.headerbar.grid_button.set_active(true);
                    break;
            }
        }

        public void new_term() {
            ETerm.Terminal term = new ETerm.Terminal();
            term.closed.connect(this.close_tab_from_term);
            this.flowbox.add_term(term);
            this.set_term_state(ETerm.WindowState.TERMINAL);
        }

        public void close_tab_from_term(ETerm.Terminal term) {
        }

        public void page_changed_cb(ETerm.Terminal term) {
            if (this.selected_terminal == term) {
                return;
            }

            if (this.selected_terminal != null) {
                this.terminal_box.remove(this.selected_terminal);
            }

            this.selected_terminal = term;
            this.terminal_box.pack_start(this.selected_terminal, true, true, 0);
            this.set_term_state(ETerm.WindowState.TERMINAL, true);
        }
    }
}

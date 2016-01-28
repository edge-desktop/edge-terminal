namespace ETerm {

    public class Terminal: Gtk.Box {

        public signal void closed();

        public Vte.Terminal terminal;
        public Gtk.Image image;
        public Gtk.Scrollbar scrollbar;

        public Gdk.RGBA background_color = Gdk.RGBA();
        public Gdk.RGBA foreground_color = Gdk.RGBA();

        public Terminal() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);

            this.image = new Gtk.Image();

            this.background_color.parse("#262c37");
            this.foreground_color.parse("#009688");

            this.terminal = new Vte.Terminal();
            this.terminal.set_color_background(this.background_color);
            this.terminal.set_color_foreground(this.foreground_color);
            this.terminal.realize.connect(this.vte_realize_cb);
            this.terminal.child_exited.connect(this.vte_exited_cb);
            this.pack_start(this.terminal, true, true, 0);

            Gtk.Adjustment adj = this.terminal.get_vadjustment();
            adj.changed.connect(this.adj_changed);

            this.scrollbar = new Gtk.Scrollbar(Gtk.Orientation.VERTICAL, adj);
            //this.pack_end(scrollbar, false, false, 0);

            this.spawn();

            this.show_all();
        }

        private void spawn() {
            string[] argv = { "/bin/bash" };

            try {
                this.terminal.spawn_sync(
                    Vte.PtyFlags.DEFAULT,
                    GLib.Environment.get_home_dir(),
                    argv, {},
                    GLib.SpawnFlags.DO_NOT_REAP_CHILD,
                    null, null
                );
            } catch (GLib.Error error) {
                GLib.warning(@"Error launching a terminal emulator: $(error.message)");
            }
        }

        private void vte_realize_cb(Gtk.Widget vte) {
            this.terminal.grab_focus();
            this.update_image();
        }

        private void vte_exited_cb(Vte.Terminal vte, int status) {
            this.closed();
        }

        private void adj_changed(Gtk.Adjustment adj) {
            double upper = adj.get_upper();
            double page_size = adj.get_page_size();

            if (page_size < upper && this.scrollbar.get_parent() == null) {
                this.pack_end(this.scrollbar, false, false, 0);
            } else if (page_size > upper && this.scrollbar.get_parent() != null) {
                this.remove(this.scrollbar);
            }

            this.show_all();
        }

        public string get_title() {
            return "Title";
        }

        public void update_image() {
            // TODO: make image from this widget
        }

        public Gtk.Image get_image() {
            return this.image;
        }
    }
}

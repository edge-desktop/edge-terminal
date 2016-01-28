namespace ETerm {

    public class App: Gtk.Application {

        public App() {
            GLib.Object(application_id: "org.edge.terminal", flags: GLib.ApplicationFlags.FLAGS_NONE);
        }

	    protected override void activate() {
	        this.window_removed.connect(this.window_removed_cb);
	        //this.add_actions();
            this.new_window();
        }

        private void window_removed_cb(Gtk.Application self, Gtk.Window window) {
            if (this.get_windows().length() == 0) {
                this.quit();
            }
        }

        public void new_window() {
            ETerm.Window win = new ETerm.Window(this);
            this.add_window(win);
        }
    }
}

int main(string[] args) {
    ETerm.App app = new ETerm.App();
    return app.run();
}

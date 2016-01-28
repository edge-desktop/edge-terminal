namespace ETerm {

    public class FlowBoxChild: Gtk.Box {

        public ETerm.Terminal term;

        public Gtk.Label label;
        public Gtk.Button button;
        public Gtk.Image image;

        public class FlowBoxChild(ETerm.Terminal term) {
            this.term = term;

            this.set_orientation(Gtk.Orientation.VERTICAL);
            this.set_border_width(8);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            this.pack_start(box, false, false, 0);

            string title = this.term.get_title();
            this.label = new Gtk.Label(title);
            this.label.set_xalign(0);
            this.label.set_max_width_chars(20);
            this.label.set_ellipsize(Pango.EllipsizeMode.END);
            box.pack_start(this.label, false, false, 0);

            this.button = new Gtk.Button();
            this.button.set_relief(Gtk.ReliefStyle.NONE);
            this.button.set_image(new Gtk.Image.from_icon_name("window-close-symbolic", Gtk.IconSize.BUTTON));
            this.button.clicked.connect(() => { print("Close tab\n"); });
            box.pack_end(this.button, false, false, 0);

            this.term.update_image();
            this.pack_end(this.term.get_image(), true, true, 0);

            this.show_all();
        }
    }

    public class FlowBox: Gtk.ScrolledWindow {

        public signal void page_changed(ETerm.Terminal term);

        public ETerm.Terminal selected_terminal;

        public Gtk.FlowBox box;

        public GLib.List<ETerm.FlowBoxChild> childs;
        public GLib.List<ETerm.Terminal> terminals;

        public FlowBox() {
            this.set_border_width(10);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.add(box);

            this.box = new Gtk.FlowBox();
            this.box.set_homogeneous(true);
            this.box.set_activate_on_single_click(true);
            this.box.set_selection_mode(Gtk.SelectionMode.SINGLE);
            this.box.child_activated.connect(this._page_changed);
            box.pack_start(this.box, false, false, 0);

            this.childs = new GLib.List<ETerm.FlowBoxChild>();
            this.terminals = new GLib.List<ETerm.Terminal>();
        }

        private void _page_changed(Gtk.FlowBox box, Gtk.FlowBoxChild child) {
            if (child == null) {
                return;
            }

            Gtk.Widget widget = child.get_child();
            ETerm.FlowBoxChild echild = (ETerm.FlowBoxChild)widget;
            this.selected_terminal = echild.term;
            this.page_changed(this.selected_terminal);
        }

        public void add_term(ETerm.Terminal term) {
            foreach (ETerm.Terminal terminal in this.terminals) {
                if (terminal == term) {
                    return;
                }
            }

            ETerm.FlowBoxChild child = new ETerm.FlowBoxChild(term);
            this.childs.append(child);
            this.terminals.append(term);
            this.box.add(child);
        }

        public void remove_term(ETerm.Terminal term) {
            this.terminals.remove(term);

            foreach (ETerm.FlowBoxChild child in this.childs) {
                if (child.term == term) {
                    this.childs.remove(child);
                    this.remove(child);
                    break;
                }
            }
        }

        public void set_current_term(ETerm.Terminal term) {
            ETerm.FlowBoxChild? echild = null;

            foreach (ETerm.FlowBoxChild child in this.childs) {
                if (child.term == term) {
                    echild = child;
                    break;
                }
            }

            if (echild == null) {
                GLib.warning("Fail to select a terminal");
                return;
            }

            if (echild.get_parent() == null) {
                return;
            }

            Gtk.FlowBoxChild child = (Gtk.FlowBoxChild)echild.get_parent();
            this.box.select_child(child);
        }

        public void set_current_term_from_index(int index) {
            if (index > this.childs.length()) {
                GLib.warning("Fail to select a terminal");
            }

            ETerm.FlowBoxChild echild = this.childs.nth_data(index);

            if (echild.get_parent() == null) {
                print("null\n");
                return;
            }

            this.selected_terminal = echild.term;
            Gtk.FlowBoxChild child = (Gtk.FlowBoxChild)echild.get_parent();
            this.box.select_child(child);
        }
    }
}

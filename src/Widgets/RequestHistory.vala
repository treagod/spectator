namespace HTTPInspector {

    public class TitleBar : Gtk.Box {
        public TitleBar (string text) {
            orientation = Gtk.Orientation.HORIZONTAL;

            var title = new Gtk.Label (text);
            title.halign = Gtk.Align.CENTER;
            title.margin = 4;

            pack_start (title, true, true, 0);
        }
    }

    public class RequestHistory : Gtk.Box {
        Gtk.FlowBox item_box;
        Gtk.ScrolledWindow scroll;

        public RequestHistory () {
            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

            var titlebar = new TitleBar (_("Request History"));

            item_box = new Gtk.FlowBox ();
            item_box.activate_on_single_click = false;
            item_box.valign = Gtk.Align.START;
            item_box.min_children_per_line = 1;
            item_box.max_children_per_line = 1;
            item_box.margin = 6;
            item_box.expand = false;

            orientation = Gtk.Orientation.VERTICAL;
            width_request = 300;

            scroll.add (item_box);
            
            // item_box.add (new RequestHistoryItem ("My Request", "http://example.com", 0));

            this.pack_start (titlebar, false, true, 0);
            this.pack_start (scroll, true, true, 0);
        }
    }
    
    public void add () {
    }
}

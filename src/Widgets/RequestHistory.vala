namespace HTTPInspector {

    public class TitleBar : Gtk.Box {
        public TitleBar (string text) {
            orientation = Gtk.Orientation.HORIZONTAL;

            var title = new Gtk.Label (text);
            title.get_style_context ().add_class ("h3");
            title.halign = Gtk.Align.START;
            title.margin = 4;

            pack_start (title, true, true, 0);
        }
    }

    public class RequestHistory : Gtk.Box {
        Gtk.FlowBox item_box;
        Gtk.ScrolledWindow scroll;
        
        public signal void selection_changed(RequestItem item);

        public RequestHistory () {
            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

            var titlebar = new TitleBar (_("Request History"));

            item_box = new Gtk.FlowBox ();
            item_box.activate_on_single_click = true;
            item_box.valign = Gtk.Align.START;
            item_box.min_children_per_line = 1;
            item_box.max_children_per_line = 1;
            item_box.margin = 6;
            item_box.expand = false;
            
            item_box.child_activated.connect ((child) => {
                var history_item = child as RequestHistoryItem;
                selection_changed (history_item.item);
            });

            orientation = Gtk.Orientation.VERTICAL;
            width_request = 265;

            scroll.add (item_box);

            this.pack_start (titlebar, false, true, 0);
            this.pack_start (scroll, true, true, 0);
        }
        
        public void update_active (RequestItem item) {
            item_box.get_selected_children ().foreach ((child) => {
                var history_item = child as RequestHistoryItem;
                history_item.update (item);
            });
        }
        
        public void add_request (RequestItem item) {
            var box_item = new RequestHistoryItem (item);
            
            item_box.add (box_item);
            item_box.show_all ();
            item_box.select_child(box_item);
            selection_changed (item);
        }
    }
}

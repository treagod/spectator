namespace HTTPInspector {
    class Content : Gtk.Stack {
        private Granite.Widgets.Welcome welcome;
        private RequestResponsePane req_res_pane;
        
        public signal void item_changed (RequestItem item);
        public signal void welcome_activated(int index);

        public Content () {
            welcome = new Granite.Widgets.Welcome (_("HTTP Inspector"), _("Inspect your HTTP transmissions to the web"));
            welcome.hexpand = true;
            welcome.append ("bookmark-new", _("Create Request"), _("Create a new request to the web."));
            
            welcome.activated.connect((index) => {
                welcome_activated (index);
            });
            
            req_res_pane = new RequestResponsePane ();

            req_res_pane.item_changed.connect ((item) => {
                item_changed (item);
            });

            add_named (welcome, "welcome");
            add_named (req_res_pane, "req_res_pane");

            set_visible_child (welcome);

            show_all ();
        }

        public void show_request_view (RequestItem item) {
            req_res_pane.set_item (item);
            set_visible_child (req_res_pane);
        }
    }

}

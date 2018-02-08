namespace HTTPInspector {
    class Content : Gtk.Stack {
        private Granite.Widgets.Welcome welcome;
        private Request request_view;
        public signal void item_changed (RequestItem item);
        
        public signal void welcome_activated(int index);
        
        public Content () {
            welcome = new Granite.Widgets.Welcome (_("HTTP Inspector"), _("Inspect your HTTP transmissions to the web"));
            welcome.hexpand = true;
            welcome.append ("bookmark-new", _("Create Request"), _("Create a new request to the web."));
            
            welcome.activated.connect((index) => {
                welcome_activated (index);
            });
            
            request_view  = new Request ();
            
            request_view.item_changed.connect((item) => {
                item_changed (item);
            });
            
            add_named (welcome, "welcome");
            add_named (request_view, "request_view");
            
            set_visible_child (welcome);
            
            show_all ();
        }
        
        public void show_request_view (RequestItem item) {
            request_view.set_item (item);
            set_visible_child (request_view);
        }
    }
    
}

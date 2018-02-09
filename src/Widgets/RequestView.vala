namespace HTTPInspector {
    class RequestView : Gtk.Box {
        private RequestItem item;
        private UrlEntry url_entry;
        public signal void item_changed(RequestItem  item);
        
        public RequestView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;

            url_entry = new UrlEntry ();
            url_entry.margin_bottom = 10;
            
            url_entry.url_changed.connect ((url) => {
                item.domain = url;
                item_changed (item);
            });
            
            url_entry.method_changed.connect ((method) => {
                item.method = method;
                item_changed (item);
            });
            
            url_entry.request_activated.connect (() => {
                perform_request ();
            });

            var stack = new Gtk.Stack ();
            stack.margin = 6;
            stack.margin_bottom = 18;
            stack.margin_top = 18;
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.halign = Gtk.Align.CENTER;

            stack.add_titled (new HeaderView (),"Header", "Header");
            stack.add_titled (new Gtk.Label ("12435243"),"URL Params", "URL Params");
            stack.add_titled (new Gtk.Label ("12435243"),"Body", "Body");
            //stack.add_titled (new Gtk.Label ("12435243"),"Auth", "Auth");
            //stack.add_titled (new Gtk.Label ("12435243"),"Options", "Options");
            
            add (url_entry);
            add (stack_switcher);
            add (stack);
        }
        
        public void set_item (RequestItem ite) {
            item = ite;
            url_entry.set_text (item.domain);
            url_entry.set_method (item.method);
        }
        
        private void perform_request () {
            var req = new Requester (item.domain);
            req.follow_location (true);
            req.verbose ();
            req.perform ();
        }
    }
}

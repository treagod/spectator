namespace HTTPInspector {
    class RequestView : Gtk.Box {
        private RequestItem item;
        private UrlEntry url_entry;
        private HeaderView header_view;
        
        public signal void item_changed(RequestItem item);
        public signal void response_received(string res);
        
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;
        }
        
        public RequestView () {
            url_entry = new UrlEntry ();
            header_view = new HeaderView ();
            url_entry.margin_bottom = 10;
            
            url_entry.url_changed.connect ((url) => {
                item.domain = url;
                item_changed (item);
            });
            
            url_entry.method_changed.connect ((method) => {
                item.method = method;
                item_changed (item);
            });
            
            url_entry.request_activated.connect (perform_request);

            var stack = new Gtk.Stack ();
            stack.margin = 6;
            stack.margin_bottom = 18;
            stack.margin_top = 18;
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.halign = Gtk.Align.CENTER;

            stack.add_titled (header_view, "header", _("Header"));
            stack.add_titled (new Gtk.Label ("12435243"), "url_params", _("URL Parameters"));
            stack.add_titled (new Gtk.Label ("12435243"), "body", _("Body"));
            //stack.add_titled (new Gtk.Label ("12435243"),"Auth", "Auth");
            //stack.add_titled (new Gtk.Label ("12435243"),"Options", "Options");
            
            add (url_entry);
            add (stack_switcher);
            add (stack);
        }
        
        public RequestItem get_item () {
            return item;
        }
        
        public void set_item (RequestItem ite) {
            item = ite;
            url_entry.item_status_changed (item.status);
            url_entry.set_text (item.domain);
            url_entry.set_method (item.method);
            show_all ();
        }
        
        private async void perform_request () {
            MainLoop loop = new MainLoop ();
            var session = new Soup.Session ();
            var msg = new Soup.Message ("GET", item.domain);
            
            session.queue_message (msg, (sess, mess) => {
                item.status = RequestStatus.SENT;
                response_received((string) mess.response_body.data);
                url_entry.item_status_changed (item.status);
                loop.quit ();
	        });
	        
	        item.status = RequestStatus.SENDING;
	        url_entry.item_status_changed (item.status);
	        
	        url_entry.cancel_process.connect (() => {
                session.cancel_message (msg, Soup.Status.CANCELLED);
                item.status = RequestStatus.SENT;
                url_entry.item_status_changed (item.status);
            });
        }
    }
}

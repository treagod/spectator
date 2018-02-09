namespace HTTPInspector {
    class RequestResponsePane : Gtk.Paned {
        private RequestView request_view;
        private ResponseView response_view;
        
        public signal void item_changed (RequestItem item);

        public RequestResponsePane () {
            request_view  = new RequestView ();
            response_view = new ResponseView ();

            request_view.item_changed.connect((item) => {
                item_changed (item);
            });
            
            request_view.response_received.connect ((res) => {
                response_view.set_response (res);
            });
            
            add1 (request_view); 
            add2 (response_view);
        }
        
        public void set_item (RequestItem item) {
            if (request_view.get_item () != item) {
                request_view.set_item (item);
                //response_view.reset ();
            }
            
        }
        
        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }
    }
}

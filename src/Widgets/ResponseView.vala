namespace HTTPInspector {
    class ResponseView : Gtk.Box {
        private Gtk.ScrolledWindow scrolled;
        private ResponseText response;
        
        construct {
            orientation = Gtk.Orientation.VERTICAL;
        }
        
        public ResponseView () {
            scrolled = new Gtk.ScrolledWindow (null, null);
            response = new ResponseText ();
            
            scrolled.add (response);
            
            pack_start (scrolled);
        }
        
        public void set_response (string res) {
            response.insert (res);
        }
        
        public void reset () {
            response = new ResponseText ();
        }
    }
}

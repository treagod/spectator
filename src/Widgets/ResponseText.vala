namespace HTTPInspector {
    class ResponseText : Gtk.SourceView {
        public new Gtk.SourceBuffer buffer;
        public Gtk.SourceLanguageManager manager;
        
        private string font { set; get; default = "Droid Sans Mono 11"; }
        
        private Gtk.SourceLanguage? language {
            set {
                buffer.language = value;
            }
        }
        
        public ResponseText () {
            Object (
                highlight_current_line: false,
                show_right_margin: false,
                wrap_mode: Gtk.WrapMode.WORD_CHAR
            );
        }        
        
        public void set_lang (string lang) {
            language = manager.get_language (lang);
        }
        
        public void insert (string res) {
            Gtk.TextIter iter;
            buffer.get_start_iter(out iter) ;
            buffer.insert (ref iter, res, res.length);
        }
        
        construct {
            manager = Gtk.SourceLanguageManager.get_default ();
            editable = false;

            buffer = new Gtk.SourceBuffer (null);
            buffer.highlight_syntax = true;
            
            set_buffer (buffer);
            set_show_line_numbers (false);
            
            language = manager.get_language ("html");
        }
    }
}

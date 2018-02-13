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
        /*
            Gtk.TextIter iter_start;
            
            if (buffer.text)
            buffer.get_start_iter(out iter_start);
            Gtk.TextIter iter_end;
            buffer.get_end_iter(out iter_end);
            buffer.@delete (ref iter_start, ref iter_end);
            buffer.insert (ref iter_start, res, res.length);
            */
            try {
                buffer.text = convert_with_fallback (res, res.length, "UTF-8", "ISO-8859-1");
            } catch (ConvertError e) {
                stderr.printf ("Error converting markup for" + res + ", "+ e.message);
            }
        }
        
        construct {
            var style_scheme_manager = new Gtk.SourceStyleSchemeManager ();
            editable = false;

            buffer = new Gtk.SourceBuffer (null);
            buffer.highlight_syntax = true;
            
            set_buffer (buffer);
            set_show_line_numbers (false);
            
            language = manager.get_language ("html");
        }
    }
}

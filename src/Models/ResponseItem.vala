namespace HTTPInspector {
    public class ResponseItem  {
        string raw;
        
        public ResponseItem (string res) {
            raw = res;
            
            process_raw_response ();
        }
        
        private void process_raw_response () {
        
        }
    }
}

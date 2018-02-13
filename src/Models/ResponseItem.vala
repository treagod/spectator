namespace HTTPInspector {
    public class ResponseItem  {
        public string raw { get; set; }
        public uint status_code { get; set; }
        public double duration { get; set; }
        public int64 size { get; set; }
        
        
        public ResponseItem () {            
            process_raw_response ();
        }
        
        private void process_raw_response () {
        
        }
    }
}

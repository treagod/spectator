namespace HTTPInspector {
    public class RequestHeader {
        private Curl.SList* chunk;
        public RequestHeader () {
            chunk = null;
        }
        
        public void add_header (string key, string val) {
            chunk = Curl.SList.append (chunk, key + ": " + val);
        }
        
        public void remove_header (string key) {
            chunk = Curl.SList.append (chunk, key + ":");
        }
        
        public Curl.SList* get_all () {
            return chunk;
        }
    }
}

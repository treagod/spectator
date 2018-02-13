namespace HTTPInspector {
    public enum Method {
        GET, POST, PUT, PATCH, DELETE, HEAD;
        
        public static Method convert(int i) {
            switch (i) {
                case 0:
                    return GET;
                case 1:
                    return POST;
                case 2:
                    return PUT;
                case 3:
                    return PATCH;
                case 4:
                    return DELETE;
                case 5:
                    return HEAD;
                default:
                    assert_not_reached ();
            }
        }
        
        public int to_i () {
            switch (this) {
                case GET:
                    return 0;
                case POST:
                    return 1;
                case PUT:
                    return 2;
                case PATCH:
                    return 3;
                case DELETE:
                    return 4;
                case HEAD:
                    return 5;
                default:
                    assert_not_reached ();
            }
        }
    }
    
    public class Header {
        public string key { get; set; }
        public string val { get; set; }
        
        public Header (string k, string v) {
            key = k;
            val = v;
        }
    }
    
    public enum RequestStatus {
        NOT_SENT, SENT, SENDING
    }
    
    public class RequestItem  {
        
        public string name { get; set; }
        public string domain { get; set; }
        public string subdomain { get; set; }
        public string path { get; set; }
        public Method method { get; set; }
        public RequestStatus status { get; set; }
        public ResponseItem response { get; set; }
        public Gee.ArrayList<Header> headers { get; private set; }
        
        public RequestItem(string nam, Method meth) {
            headers = new Gee.ArrayList<Header> ();
            name = nam;
            domain = "";
            subdomain = "";
            path = "";
            method = meth;
            status = RequestStatus.NOT_SENT;
        }
        
        public RequestItem.with_url(string nam, string url, Method meth) {
            headers = new Gee.ArrayList<Header> ();
            name = nam;
            domain = url;
            subdomain = url;
            path = url;
            method = meth;
            status = RequestStatus.NOT_SENT;
        }
        
        public RequestItem.from_int(string nam, int meth) {
            headers = new Gee.ArrayList<Header> ();
            name = nam;
            status = RequestStatus.NOT_SENT;
            method = Method.convert(meth);
        }
        
        public RequestItem.from_int_with_url(string nam, string url, Method meth) {
            headers = new Gee.ArrayList<Header> ();
            name = nam;
            domain = url;
            subdomain = url;
            path = url;
            method = meth;
        }
        
        public void add_header (string key, string val) {
            headers.add (new Header (key, val));
        }
        
        public void update_header (int index, string key, string val) {
            var header = headers.get (index);
            header.key = key;
            header.val = val;
            headers.set (index, header);
        }
    }
}

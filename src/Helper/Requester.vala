namespace HTTPInspector {
    public class Requester {
        private class CallbackStream : GLib.OutputStream {
            private MemoryInputStream input_stream;
    
            public CallbackStream(MemoryInputStream input_stream) {
                this.input_stream = input_stream;
            }
    
            public override ssize_t write(uint8[] buffer, Cancellable? cancellable = null) throws IOError {
                input_stream.add_data(buffer, GLib.free);
                return (ssize_t) buffer.length;
            }
    
            public override bool close(Cancellable? cancellable = null) throws IOError {
                return input_stream.close();
            }
        }
        
        public signal void request_performed (Curl.Code code);
        
    	private Curl.EasyHandle handle;
    	private RequestHeader headers;
    	private CallbackStream output_stream;
    	private MemoryInputStream input_stream;
    	
    	public Requester (string url) {
            handle = new Curl.EasyHandle  ();
            headers = new RequestHeader ();
            input_stream = new MemoryInputStream ();
            output_stream = new CallbackStream (input_stream);
            handle.setopt (Curl.Option.WRITEFUNCTION, write_function);
            handle.setopt (Curl.Option.FILE, (void*)output_stream);
            handle.setopt (Curl.Option.URL, url);
            handle.setopt (Curl.Option.USERAGENT, "http-inspector/0.1");
        }
        
        public void verbose (bool choice = true) {
            handle.setopt (Curl.Option.VERBOSE, choice);
        }
        
        public void add_header (string key, string val) {
            headers.add_header (key, val);
        }
        
        public void remove_header (string key) {
            headers.remove_header (key);
        }
        
        public void set_user_agent (string agent = "http-inspector/0.1") {
            handle.setopt (Curl.Option.USERAGENT, agent);
        }

    	public void follow_location (bool choice) {
    	    handle.setopt (Curl.Option.FOLLOWLOCATION, choice);
    	}

    	public void use_ssl (bool choice) {
    	    if (choice) {
    	        handle.setopt (Curl.Option.USE_SSL, Curl.UseSSL.ALL);
    	    } else {
    	        handle.setopt (Curl.Option.USE_SSL, Curl.UseSSL.NONE);
    	    }
    	}
    	
    	public void set_method (Method method) {
    	    switch (method) {
    	        case Method.GET:
                    handle.setopt (Curl.Option.CUSTOMREQUEST, "GET");
                    break;
    	        case Method.POST:
    	            handle.setopt (Curl.Option.CUSTOMREQUEST, "POST");
                    break;
    	        case Method.PUT:
    	            handle.setopt (Curl.Option.CUSTOMREQUEST, "PUT");
                    break;
    	        case Method.PATCH:
    	            handle.setopt (Curl.Option.CUSTOMREQUEST, "PATCH");
                    break;
    	        case Method.DELETE:
    	            handle.setopt (Curl.Option.CUSTOMREQUEST, "DELETE");
                    break;
                case Method.HEAD:
                    handle.setopt (Curl.Option.CUSTOMREQUEST, "HEAD");
                    break;    	        
    	        default:
    	            assert_not_reached ();
    	    }
    	}

    	public async void perform () {
    	    Thread.create<void>(() => {
    	        handle.setopt (Curl.Option.HTTPHEADER, headers.get_all ());
                handle.setopt (Curl.Option.POSTFIELDS, "");
                request_performed (handle.perform ());
    	    }, false);
            
            
            yield;
        }

    	public string get_response () {
    	    string response_part;
    	    var response_builder = new StringBuilder ();
    	    DataInputStream t = new DataInputStream (input_stream);
    	    
    	    try {
    	        while((response_part = t.read_line ()) != null) {
                    response_builder.append(response_part+ "\n");
    	        }
    	    } catch (Error e) {
    	        stderr.printf ("Error reading from memory stream: %s\n", e.message);
    	    }
    	    return response_builder.str;
    	}

        private static size_t write_function (void* res, size_t size, size_t nmemb, void *data) {
            size_t bytes = size * nmemb;
            OutputStream stream = (OutputStream) data;

            uint8[] buffer = new uint8[bytes];
            Posix.memcpy ((void*)buffer, res, bytes);

            size_t bytes_written;
            try {
                bytes_written = stream.write (buffer, null);
            } catch(IOError e) {
                stderr.printf ("IOError in write_function: %s\n", e.message);
                return 0;
            }
    
            return bytes_written;
        }
    }
}

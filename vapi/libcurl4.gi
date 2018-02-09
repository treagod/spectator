<?xml version="1.0"?>
<api version="1.0">
  <namespace name="Curl">
    <callback name="curl_calloc_callback">
      <return-type type="void*"/>
      <parameters>
	<parameter name="nmemb" type="size_t"/>
	<parameter name="size" type="size_t"/>
      </parameters>
    </callback>
    <callback name="curl_chunk_bgn_callback">
      <return-type type="long"/>
      <parameters>
	<parameter name="transfer_info" type="void*"/>
	<parameter name="ptr" type="void*"/>
	<parameter name="remains" type="int"/>
      </parameters>
    </callback>
    <callback name="curl_chunk_end_callback">
      <return-type type="long"/>
      <parameters>
	<parameter name="ptr" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_closesocket_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="clientp" type="void*"/>
	<parameter name="item" type="curl_socket_t"/>
      </parameters>
    </callback>
    <callback name="curl_conv_callback">
      <return-type type="CURLcode"/>
      <parameters>
	<parameter name="buffer" type="char*"/>
	<parameter name="length" type="size_t"/>
      </parameters>
    </callback>
    <callback name="curl_debug_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="handle" type="CURL*"/>
	<parameter name="type" type="curl_infotype"/>
	<parameter name="data" type="char*"/>
	<parameter name="size" type="size_t"/>
	<parameter name="userptr" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_fnmatch_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="ptr" type="void*"/>
	<parameter name="pattern" type="char*"/>
	<parameter name="string" type="char*"/>
      </parameters>
    </callback>
    <callback name="curl_formget_callback">
      <return-type type="size_t"/>
      <parameters>
	<parameter name="arg" type="void*"/>
	<parameter name="buf" type="char*"/>
	<parameter name="len" type="size_t"/>
      </parameters>
    </callback>
    <callback name="curl_free_callback">
      <return-type type="void"/>
      <parameters>
	<parameter name="ptr" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_ioctl_callback">
      <return-type type="curlioerr"/>
      <parameters>
	<parameter name="handle" type="CURL*"/>
	<parameter name="cmd" type="int"/>
	<parameter name="clientp" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_lock_function">
      <return-type type="void"/>
      <parameters>
	<parameter name="handle" type="CURL*"/>
	<parameter name="data" type="curl_lock_data"/>
	<parameter name="locktype" type="curl_lock_access"/>
	<parameter name="userptr" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_malloc_callback">
      <return-type type="void*"/>
      <parameters>
	<parameter name="size" type="size_t"/>
      </parameters>
    </callback>
    <callback name="curl_multi_timer_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="multi" type="CURLM*"/>
	<parameter name="timeout_ms" type="long"/>
	<parameter name="userp" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_opensocket_callback">
      <return-type type="curl_socket_t"/>
      <parameters>
	<parameter name="clientp" type="void*"/>
	<parameter name="purpose" type="curlsocktype"/>
	<parameter name="address" type="struct curl_sockaddr*"/>
      </parameters>
    </callback>
    <callback name="curl_progress_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="clientp" type="void*"/>
	<parameter name="dltotal" type="double"/>
	<parameter name="dlnow" type="double"/>
	<parameter name="ultotal" type="double"/>
	<parameter name="ulnow" type="double"/>
      </parameters>
    </callback>
    <callback name="curl_read_callback">
      <return-type type="size_t"/>
      <parameters>
	<parameter name="buffer" type="char*"/>
	<parameter name="size" type="size_t"/>
	<parameter name="nitems" type="size_t"/>
	<parameter name="instream" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_realloc_callback">
      <return-type type="void*"/>
      <parameters>
	<parameter name="ptr" type="void*"/>
	<parameter name="size" type="size_t"/>
      </parameters>
    </callback>
    <callback name="curl_seek_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="instream" type="void*"/>
	<parameter name="offset" type="curl_off_t"/>
	<parameter name="origin" type="int"/>
      </parameters>
    </callback>
    <callback name="curl_socket_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="easy" type="CURL*"/>
	<parameter name="s" type="curl_socket_t"/>
	<parameter name="what" type="int"/>
	<parameter name="userp" type="void*"/>
	<parameter name="socketp" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_sockopt_callback">
      <return-type type="int"/>
      <parameters>
	<parameter name="clientp" type="void*"/>
	<parameter name="curlfd" type="curl_socket_t"/>
	<parameter name="purpose" type="curlsocktype"/>
      </parameters>
    </callback>
    <callback name="curl_sshkeycallback">
      <return-type type="int"/>
      <parameters>
	<parameter name="easy" type="CURL*"/>
	<parameter name="knownkey" type="struct curl_khkey*"/>
	<parameter name="foundkey" type="struct curl_khkey*"/>
	<parameter name="p4" type="curl_khmatch"/>
	<parameter name="clientp" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_ssl_ctx_callback">
      <return-type type="CURLcode"/>
      <parameters>
	<parameter name="curl" type="CURL*"/>
	<parameter name="ssl_ctx" type="void*"/>
	<parameter name="userptr" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_strdup_callback">
      <return-type type="char*"/>
      <parameters>
	<parameter name="str" type="char*"/>
      </parameters>
    </callback>
    <callback name="curl_unlock_function">
      <return-type type="void"/>
      <parameters>
	<parameter name="handle" type="CURL*"/>
	<parameter name="data" type="curl_lock_data"/>
	<parameter name="userptr" type="void*"/>
      </parameters>
    </callback>
    <callback name="curl_write_callback">
      <return-type type="size_t"/>
      <parameters>
	<parameter name="buffer" type="char*"/>
	<parameter name="size" type="size_t"/>
	<parameter name="nitems" type="size_t"/>
	<parameter name="outstream" type="void*"/>
      </parameters>
    </callback>
    <struct name="CURL">
      <method name="easy_cleanup" symbol="curl_easy_cleanup">
	<return-type type="void"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	</parameters>
      </method>
      <method name="easy_duphandle" symbol="curl_easy_duphandle">
	<return-type type="CURL*"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	</parameters>
      </method>
      <method name="easy_escape" symbol="curl_easy_escape">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="handle" type="CURL*"/>
	  <parameter name="string" type="char*"/>
	  <parameter name="length" type="int"/>
	</parameters>
      </method>
      <method name="easy_getinfo" symbol="curl_easy_getinfo">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	  <parameter name="info" type="CURLINFO"/>
	</parameters>
      </method>
      <method name="easy_init" symbol="curl_easy_init">
	<return-type type="CURL*"/>
      </method>
      <method name="easy_pause" symbol="curl_easy_pause">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="handle" type="CURL*"/>
	  <parameter name="bitmask" type="int"/>
	</parameters>
      </method>
      <method name="easy_perform" symbol="curl_easy_perform">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	</parameters>
      </method>
      <method name="easy_recv" symbol="curl_easy_recv">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	  <parameter name="buffer" type="void*"/>
	  <parameter name="buflen" type="size_t"/>
	  <parameter name="n" type="size_t*"/>
	</parameters>
      </method>
      <method name="easy_reset" symbol="curl_easy_reset">
	<return-type type="void"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	</parameters>
      </method>
      <method name="easy_send" symbol="curl_easy_send">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	  <parameter name="buffer" type="void*"/>
	  <parameter name="buflen" type="size_t"/>
	  <parameter name="n" type="size_t*"/>
	</parameters>
      </method>
      <method name="easy_setopt" symbol="curl_easy_setopt">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="curl" type="CURL*"/>
	  <parameter name="option" type="CURLoption"/>
	</parameters>
      </method>
      <method name="easy_strerror" symbol="curl_easy_strerror">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="p1" type="CURLcode"/>
	</parameters>
      </method>
      <method name="easy_unescape" symbol="curl_easy_unescape">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="handle" type="CURL*"/>
	  <parameter name="string" type="char*"/>
	  <parameter name="length" type="int"/>
	  <parameter name="outlength" type="int*"/>
	</parameters>
      </method>
      <method name="escape" symbol="curl_escape">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="string" type="char*"/>
	  <parameter name="length" type="int"/>
	</parameters>
      </method>
      <method name="free" symbol="curl_free">
	<return-type type="void"/>
	<parameters>
	  <parameter name="p" type="void*"/>
	</parameters>
      </method>
      <method name="getdate" symbol="curl_getdate">
	<return-type type="time_t"/>
	<parameters>
	  <parameter name="p" type="char*"/>
	  <parameter name="unused" type="time_t*"/>
	</parameters>
      </method>
      <method name="getenv" symbol="curl_getenv">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="variable" type="char*"/>
	</parameters>
      </method>
      <method name="strequal" symbol="curl_strequal">
	<return-type type="int"/>
	<parameters>
	  <parameter name="s1" type="char*"/>
	  <parameter name="s2" type="char*"/>
	</parameters>
      </method>
      <method name="strnequal" symbol="curl_strnequal">
	<return-type type="int"/>
	<parameters>
	  <parameter name="s1" type="char*"/>
	  <parameter name="s2" type="char*"/>
	  <parameter name="n" type="size_t"/>
	</parameters>
      </method>
      <method name="unescape" symbol="curl_unescape">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="string" type="char*"/>
	  <parameter name="length" type="int"/>
	</parameters>
      </method>
      <method name="version" symbol="curl_version">
	<return-type type="char*"/>
      </method>
      <method name="version_info" symbol="curl_version_info">
	<return-type type="curl_version_info_data*"/>
	<parameters>
	  <parameter name="p1" type="CURLversion"/>
	</parameters>
      </method>
      <method name="global_cleanup" symbol="curl_global_cleanup">
	<return-type type="void"/>
      </method>
      <method name="global_init" symbol="curl_global_init">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="flags" type="long"/>
	</parameters>
      </method>
      <method name="global_init_mem" symbol="curl_global_init_mem">
	<return-type type="CURLcode"/>
	<parameters>
	  <parameter name="flags" type="long"/>
	  <parameter name="m" type="curl_malloc_callback"/>
	  <parameter name="f" type="curl_free_callback"/>
	  <parameter name="r" type="curl_realloc_callback"/>
	  <parameter name="s" type="curl_strdup_callback"/>
	  <parameter name="c" type="curl_calloc_callback"/>
	</parameters>
      </method>
    </struct>
    <struct name="CURLM">
      <method name="multi_add_handle" symbol="curl_multi_add_handle">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="curl_handle" type="CURL*"/>
	</parameters>
      </method>
      <method name="multi_assign" symbol="curl_multi_assign">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="sockfd" type="curl_socket_t"/>
	  <parameter name="sockp" type="void*"/>
	</parameters>
      </method>
      <method name="multi_cleanup" symbol="curl_multi_cleanup">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	</parameters>
      </method>
      <method name="multi_fdset" symbol="curl_multi_fdset">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="read_fd_set" type="fd_set*"/>
	  <parameter name="write_fd_set" type="fd_set*"/>
	  <parameter name="exc_fd_set" type="fd_set*"/>
	  <parameter name="max_fd" type="int*"/>
	</parameters>
      </method>
      <method name="multi_info_read" symbol="curl_multi_info_read">
	<return-type type="CURLMsg*"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="msgs_in_queue" type="int*"/>
	</parameters>
      </method>
      <method name="multi_init" symbol="curl_multi_init">
	<return-type type="CURLM*"/>
      </method>
      <method name="multi_perform" symbol="curl_multi_perform">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="running_handles" type="int*"/>
	</parameters>
      </method>
      <method name="multi_remove_handle" symbol="curl_multi_remove_handle">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="curl_handle" type="CURL*"/>
	</parameters>
      </method>
      <method name="multi_setopt" symbol="curl_multi_setopt">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="option" type="CURLMoption"/>
	</parameters>
      </method>
      <method name="multi_socket" symbol="curl_multi_socket">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="s" type="curl_socket_t"/>
	  <parameter name="running_handles" type="int*"/>
	</parameters>
      </method>
      <method name="multi_socket_action" symbol="curl_multi_socket_action">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="s" type="curl_socket_t"/>
	  <parameter name="ev_bitmask" type="int"/>
	  <parameter name="running_handles" type="int*"/>
	</parameters>
      </method>
      <method name="multi_socket_all" symbol="curl_multi_socket_all">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="running_handles" type="int*"/>
	</parameters>
      </method>
      <method name="multi_strerror" symbol="curl_multi_strerror">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="p1" type="CURLMcode"/>
	</parameters>
      </method>
      <method name="multi_timeout" symbol="curl_multi_timeout">
	<return-type type="CURLMcode"/>
	<parameters>
	  <parameter name="multi_handle" type="CURLM*"/>
	  <parameter name="milliseconds" type="long*"/>
	</parameters>
      </method>
    </struct>
    <struct name="CURLMsg">
      <field name="msg" type="CURLMSG"/>
      <field name="easy_handle" type="CURL*"/>
      <field name="data" type="gpointer"/>
    </struct>
    <struct name="CURLSH">
      <method name="share_cleanup" symbol="curl_share_cleanup">
	<return-type type="CURLSHcode"/>
	<parameters>
	  <parameter name="p1" type="CURLSH*"/>
	</parameters>
      </method>
      <method name="share_init" symbol="curl_share_init">
	<return-type type="CURLSH*"/>
      </method>
      <method name="share_setopt" symbol="curl_share_setopt">
	<return-type type="CURLSHcode"/>
	<parameters>
	  <parameter name="p1" type="CURLSH*"/>
	  <parameter name="option" type="CURLSHoption"/>
	</parameters>
      </method>
      <method name="share_strerror" symbol="curl_share_strerror">
	<return-type type="char*"/>
	<parameters>
	  <parameter name="p1" type="CURLSHcode"/>
	</parameters>
      </method>
    </struct>
    <struct name="struct curl_slist">
      <method name="slist_append" symbol="curl_slist_append">
	<return-type type="struct curl_slist*"/>
	<parameters>
	  <parameter name="p1" type="struct curl_slist*"/>
	  <parameter name="p2" type="char*"/>
	</parameters>
      </method>
      <method name="slist_free_all" symbol="curl_slist_free_all">
	<return-type type="void"/>
	<parameters>
	  <parameter name="p1" type="struct curl_slist*"/>
	</parameters>
      </method>
    </struct>
    <struct name="struct curl_httppost">
      <method name="formadd" symbol="curl_formadd">
	<return-type type="CURLFORMcode"/>
	<parameters>
	  <parameter name="httppost" type="struct curl_httppost**"/>
	  <parameter name="last_post" type="struct curl_httppost**"/>
	</parameters>
      </method>
      <method name="formfree" symbol="curl_formfree">
	<return-type type="void"/>
	<parameters>
	  <parameter name="form" type="struct curl_httppost*"/>
	</parameters>
      </method>
      <method name="formget" symbol="curl_formget">
	<return-type type="int"/>
	<parameters>
	  <parameter name="form" type="struct curl_httppost*"/>
	  <parameter name="arg" type="void*"/>
	  <parameter name="append" type="curl_formget_callback"/>
	</parameters>
      </method>
    </struct>
    <struct name="curl_off_t">
    </struct>
    <struct name="curl_socket_t">
    </struct>
    <struct name="curl_socklen_t">
    </struct>
    <struct name="curl_version_info_data">
      <field name="age" type="CURLversion"/>
      <field name="version" type="char*"/>
      <field name="version_num" type="unsigned"/>
      <field name="host" type="char*"/>
      <field name="features" type="int"/>
      <field name="ssl_version" type="char*"/>
      <field name="ssl_version_num" type="long"/>
      <field name="libz_version" type="char*"/>
      <field name="protocols" type="char**"/>
      <field name="ares" type="char*"/>
      <field name="ares_num" type="int"/>
      <field name="libidn" type="char*"/>
      <field name="iconv_ver_num" type="int"/>
      <field name="libssh_version" type="char*"/>
    </struct>
    
    <enum name="curl_khmatch">
      <member name="CURLKHMATCH_OK" value="0"/>
      <member name="CURLKHMATCH_MISMATCH" value="1"/>
      <member name="CURLKHMATCH_MISSING" value="2"/>
      <member name="CURLKHMATCH_LAST" value="3"/>
    </enum>

    <enum name="curl_khstat">
      <member name="CURLKHSTAT_FINE_ADD_TO_FILE" value="0"/>
      <member name="CURLKHSTAT_FINE" value="1"/>
      <member name="CURLKHSTAT_REJECT" value="2"/>
      <member name="CURLKHSTAT_DEFER" value="3"/>
      <member name="CURLKHSTAT_LAST" value="4"/>
    </enum>

    <enum name="keytype">
      <member name="CURLKHTYPE_UNKNOWN" value="0"/>
      <member name="CURLKHTYPE_RSA1" value="1"/>
      <member name="CURLKHTYPE_RSA" value="2"/>
      <member name="CURLKHTYPE_DSS" value="3"/>
    </enum>

    <enum name="CURLFORMcode">
      <member name="CURL_FORMADD_OK" value="0"/>
      <member name="CURL_FORMADD_MEMORY" value="1"/>
      <member name="CURL_FORMADD_OPTION_TWICE" value="2"/>
      <member name="CURL_FORMADD_NULL" value="3"/>
      <member name="CURL_FORMADD_UNKNOWN_OPTION" value="4"/>
      <member name="CURL_FORMADD_INCOMPLETE" value="5"/>
      <member name="CURL_FORMADD_ILLEGAL_ARRAY" value="6"/>
      <member name="CURL_FORMADD_DISABLED" value="7"/>
      <member name="CURL_FORMADD_LAST" value="8"/>
    </enum>
    <enum name="CURLINFO">
      <member name="CURLINFO_NONE" value="0"/>
      <member name="CURLINFO_EFFECTIVE_URL" value="1048577"/>
      <member name="CURLINFO_RESPONSE_CODE" value="2097154"/>
      <member name="CURLINFO_TOTAL_TIME" value="3145731"/>
      <member name="CURLINFO_NAMELOOKUP_TIME" value="3145732"/>
      <member name="CURLINFO_CONNECT_TIME" value="3145733"/>
      <member name="CURLINFO_PRETRANSFER_TIME" value="3145734"/>
      <member name="CURLINFO_SIZE_UPLOAD" value="3145735"/>
      <member name="CURLINFO_SIZE_DOWNLOAD" value="3145736"/>
      <member name="CURLINFO_SPEED_DOWNLOAD" value="3145737"/>
      <member name="CURLINFO_SPEED_UPLOAD" value="3145738"/>
      <member name="CURLINFO_HEADER_SIZE" value="2097163"/>
      <member name="CURLINFO_REQUEST_SIZE" value="2097164"/>
      <member name="CURLINFO_SSL_VERIFYRESULT" value="2097165"/>
      <member name="CURLINFO_FILETIME" value="2097166"/>
      <member name="CURLINFO_CONTENT_LENGTH_DOWNLOAD" value="3145743"/>
      <member name="CURLINFO_CONTENT_LENGTH_UPLOAD" value="3145744"/>
      <member name="CURLINFO_STARTTRANSFER_TIME" value="3145745"/>
      <member name="CURLINFO_CONTENT_TYPE" value="1048594"/>
      <member name="CURLINFO_REDIRECT_TIME" value="3145747"/>
      <member name="CURLINFO_REDIRECT_COUNT" value="2097172"/>
      <member name="CURLINFO_PRIVATE" value="1048597"/>
      <member name="CURLINFO_HTTP_CONNECTCODE" value="2097174"/>
      <member name="CURLINFO_HTTPAUTH_AVAIL" value="2097175"/>
      <member name="CURLINFO_PROXYAUTH_AVAIL" value="2097176"/>
      <member name="CURLINFO_OS_ERRNO" value="2097177"/>
      <member name="CURLINFO_NUM_CONNECTS" value="2097178"/>
      <member name="CURLINFO_SSL_ENGINES" value="4194331"/>
      <member name="CURLINFO_COOKIELIST" value="4194332"/>
      <member name="CURLINFO_LASTSOCKET" value="2097181"/>
      <member name="CURLINFO_FTP_ENTRY_PATH" value="1048606"/>
      <member name="CURLINFO_REDIRECT_URL" value="1048607"/>
      <member name="CURLINFO_PRIMARY_IP" value="1048608"/>
      <member name="CURLINFO_APPCONNECT_TIME" value="3145761"/>
      <member name="CURLINFO_CERTINFO" value="4194338"/>
      <member name="CURLINFO_CONDITION_UNMET" value="2097187"/>
      <member name="CURLINFO_RTSP_SESSION_ID" value="1048612"/>
      <member name="CURLINFO_RTSP_CLIENT_CSEQ" value="2097189"/>
      <member name="CURLINFO_RTSP_SERVER_CSEQ" value="2097190"/>
      <member name="CURLINFO_RTSP_CSEQ_RECV" value="2097191"/>
      <member name="CURLINFO_PRIMARY_PORT" value="2097192"/>
      <member name="CURLINFO_LOCAL_IP" value="1048617"/>
      <member name="CURLINFO_LOCAL_PORT" value="2097194"/>
      <member name="CURLINFO_LASTONE" value="42"/>
    </enum>
    <enum name="CURLMSG">
      <member name="CURLMSG_NONE" value="0"/>
      <member name="CURLMSG_DONE" value="1"/>
      <member name="CURLMSG_LAST" value="2"/>
    </enum>
    <enum name="CURLMcode">
      <member name="CURLM_CALL_MULTI_PERFORM" value="-1"/>
      <member name="CURLM_OK" value="0"/>
      <member name="CURLM_BAD_HANDLE" value="1"/>
      <member name="CURLM_BAD_EASY_HANDLE" value="2"/>
      <member name="CURLM_OUT_OF_MEMORY" value="3"/>
      <member name="CURLM_INTERNAL_ERROR" value="4"/>
      <member name="CURLM_BAD_SOCKET" value="5"/>
      <member name="CURLM_UNKNOWN_OPTION" value="6"/>
      <member name="CURLM_LAST" value="7"/>
    </enum>
    <enum name="CURLMoption">
      <member name="CURLMOPT_SOCKETFUNCTION" value="20001"/>
      <member name="CURLMOPT_SOCKETDATA" value="10002"/>
      <member name="CURLMOPT_PIPELINING" value="3"/>
      <member name="CURLMOPT_TIMERFUNCTION" value="20004"/>
      <member name="CURLMOPT_TIMERDATA" value="10005"/>
      <member name="CURLMOPT_MAXCONNECTS" value="6"/>
      <member name="CURLMOPT_LASTENTRY" value="7"/>
    </enum>
    <enum name="CURLSHcode">
      <member name="CURLSHE_OK" value="0"/>
      <member name="CURLSHE_BAD_OPTION" value="1"/>
      <member name="CURLSHE_IN_USE" value="2"/>
      <member name="CURLSHE_INVALID" value="3"/>
      <member name="CURLSHE_NOMEM" value="4"/>
      <member name="CURLSHE_LAST" value="5"/>
    </enum>
    <enum name="CURLSHoption">
      <member name="CURLSHOPT_NONE" value="0"/>
      <member name="CURLSHOPT_SHARE" value="1"/>
      <member name="CURLSHOPT_UNSHARE" value="2"/>
      <member name="CURLSHOPT_LOCKFUNC" value="3"/>
      <member name="CURLSHOPT_UNLOCKFUNC" value="4"/>
      <member name="CURLSHOPT_USERDATA" value="5"/>
      <member name="CURLSHOPT_LAST" value="6"/>
    </enum>
    <enum name="CURLcode">
      <member name="CURLE_OK" value="0"/>
      <member name="CURLE_UNSUPPORTED_PROTOCOL" value="1"/>
      <member name="CURLE_FAILED_INIT" value="2"/>
      <member name="CURLE_URL_MALFORMAT" value="3"/>
      <member name="CURLE_NOT_BUILT_IN" value="4"/>
      <member name="CURLE_COULDNT_RESOLVE_PROXY" value="5"/>
      <member name="CURLE_COULDNT_RESOLVE_HOST" value="6"/>
      <member name="CURLE_COULDNT_CONNECT" value="7"/>
      <member name="CURLE_FTP_WEIRD_SERVER_REPLY" value="8"/>
      <member name="CURLE_REMOTE_ACCESS_DENIED" value="9"/>
      <member name="CURLE_OBSOLETE10" value="10"/>
      <member name="CURLE_FTP_WEIRD_PASS_REPLY" value="11"/>
      <member name="CURLE_OBSOLETE12" value="12"/>
      <member name="CURLE_FTP_WEIRD_PASV_REPLY" value="13"/>
      <member name="CURLE_FTP_WEIRD_227_FORMAT" value="14"/>
      <member name="CURLE_FTP_CANT_GET_HOST" value="15"/>
      <member name="CURLE_OBSOLETE16" value="16"/>
      <member name="CURLE_FTP_COULDNT_SET_TYPE" value="17"/>
      <member name="CURLE_PARTIAL_FILE" value="18"/>
      <member name="CURLE_FTP_COULDNT_RETR_FILE" value="19"/>
      <member name="CURLE_OBSOLETE20" value="20"/>
      <member name="CURLE_QUOTE_ERROR" value="21"/>
      <member name="CURLE_HTTP_RETURNED_ERROR" value="22"/>
      <member name="CURLE_WRITE_ERROR" value="23"/>
      <member name="CURLE_OBSOLETE24" value="24"/>
      <member name="CURLE_UPLOAD_FAILED" value="25"/>
      <member name="CURLE_READ_ERROR" value="26"/>
      <member name="CURLE_OUT_OF_MEMORY" value="27"/>
      <member name="CURLE_OPERATION_TIMEDOUT" value="28"/>
      <member name="CURLE_OBSOLETE29" value="29"/>
      <member name="CURLE_FTP_PORT_FAILED" value="30"/>
      <member name="CURLE_FTP_COULDNT_USE_REST" value="31"/>
      <member name="CURLE_OBSOLETE32" value="32"/>
      <member name="CURLE_RANGE_ERROR" value="33"/>
      <member name="CURLE_HTTP_POST_ERROR" value="34"/>
      <member name="CURLE_SSL_CONNECT_ERROR" value="35"/>
      <member name="CURLE_BAD_DOWNLOAD_RESUME" value="36"/>
      <member name="CURLE_FILE_COULDNT_READ_FILE" value="37"/>
      <member name="CURLE_LDAP_CANNOT_BIND" value="38"/>
      <member name="CURLE_LDAP_SEARCH_FAILED" value="39"/>
      <member name="CURLE_OBSOLETE40" value="40"/>
      <member name="CURLE_FUNCTION_NOT_FOUND" value="41"/>
      <member name="CURLE_ABORTED_BY_CALLBACK" value="42"/>
      <member name="CURLE_BAD_FUNCTION_ARGUMENT" value="43"/>
      <member name="CURLE_OBSOLETE44" value="44"/>
      <member name="CURLE_INTERFACE_FAILED" value="45"/>
      <member name="CURLE_OBSOLETE46" value="46"/>
      <member name="CURLE_TOO_MANY_REDIRECTS" value="47"/>
      <member name="CURLE_UNKNOWN_OPTION" value="48"/>
      <member name="CURLE_TELNET_OPTION_SYNTAX" value="49"/>
      <member name="CURLE_OBSOLETE50" value="50"/>
      <member name="CURLE_PEER_FAILED_VERIFICATION" value="51"/>
      <member name="CURLE_GOT_NOTHING" value="52"/>
      <member name="CURLE_SSL_ENGINE_NOTFOUND" value="53"/>
      <member name="CURLE_SSL_ENGINE_SETFAILED" value="54"/>
      <member name="CURLE_SEND_ERROR" value="55"/>
      <member name="CURLE_RECV_ERROR" value="56"/>
      <member name="CURLE_OBSOLETE57" value="57"/>
      <member name="CURLE_SSL_CERTPROBLEM" value="58"/>
      <member name="CURLE_SSL_CIPHER" value="59"/>
      <member name="CURLE_SSL_CACERT" value="60"/>
      <member name="CURLE_BAD_CONTENT_ENCODING" value="61"/>
      <member name="CURLE_LDAP_INVALID_URL" value="62"/>
      <member name="CURLE_FILESIZE_EXCEEDED" value="63"/>
      <member name="CURLE_USE_SSL_FAILED" value="64"/>
      <member name="CURLE_SEND_FAIL_REWIND" value="65"/>
      <member name="CURLE_SSL_ENGINE_INITFAILED" value="66"/>
      <member name="CURLE_LOGIN_DENIED" value="67"/>
      <member name="CURLE_TFTP_NOTFOUND" value="68"/>
      <member name="CURLE_TFTP_PERM" value="69"/>
      <member name="CURLE_REMOTE_DISK_FULL" value="70"/>
      <member name="CURLE_TFTP_ILLEGAL" value="71"/>
      <member name="CURLE_TFTP_UNKNOWNID" value="72"/>
      <member name="CURLE_REMOTE_FILE_EXISTS" value="73"/>
      <member name="CURLE_TFTP_NOSUCHUSER" value="74"/>
      <member name="CURLE_CONV_FAILED" value="75"/>
      <member name="CURLE_CONV_REQD" value="76"/>
      <member name="CURLE_SSL_CACERT_BADFILE" value="77"/>
      <member name="CURLE_REMOTE_FILE_NOT_FOUND" value="78"/>
      <member name="CURLE_SSH" value="79"/>
      <member name="CURLE_SSL_SHUTDOWN_FAILED" value="80"/>
      <member name="CURLE_AGAIN" value="81"/>
      <member name="CURLE_SSL_CRL_BADFILE" value="82"/>
      <member name="CURLE_SSL_ISSUER_ERROR" value="83"/>
      <member name="CURLE_FTP_PRET_FAILED" value="84"/>
      <member name="CURLE_RTSP_CSEQ_ERROR" value="85"/>
      <member name="CURLE_RTSP_SESSION_ERROR" value="86"/>
      <member name="CURLE_FTP_BAD_FILE_LIST" value="87"/>
      <member name="CURLE_CHUNK_FAILED" value="88"/>
      <member name="CURL_LAST" value="89"/>
    </enum>
    <enum name="CURLformoption">
      <member name="CURLFORM_NOTHING" value="0"/>
      <member name="CURLFORM_COPYNAME" value="1"/>
      <member name="CURLFORM_PTRNAME" value="2"/>
      <member name="CURLFORM_NAMELENGTH" value="3"/>
      <member name="CURLFORM_COPYCONTENTS" value="4"/>
      <member name="CURLFORM_PTRCONTENTS" value="5"/>
      <member name="CURLFORM_CONTENTSLENGTH" value="6"/>
      <member name="CURLFORM_FILECONTENT" value="7"/>
      <member name="CURLFORM_ARRAY" value="8"/>
      <member name="CURLFORM_OBSOLETE" value="9"/>
      <member name="CURLFORM_FILE" value="10"/>
      <member name="CURLFORM_BUFFER" value="11"/>
      <member name="CURLFORM_BUFFERPTR" value="12"/>
      <member name="CURLFORM_BUFFERLENGTH" value="13"/>
      <member name="CURLFORM_CONTENTTYPE" value="14"/>
      <member name="CURLFORM_CONTENTHEADER" value="15"/>
      <member name="CURLFORM_FILENAME" value="16"/>
      <member name="CURLFORM_END" value="17"/>
      <member name="CURLFORM_OBSOLETE2" value="18"/>
      <member name="CURLFORM_STREAM" value="19"/>
      <member name="CURLFORM_LASTENTRY" value="20"/>
    </enum>
    <enum name="CURLoption">
      <member name="CURLOPT_FILE" value="10001"/>
      <member name="CURLOPT_WRITEDATA" value="10001"/>
      <member name="CURLOPT_URL" value="10002"/>
      <member name="CURLOPT_PORT" value="3"/>
      <member name="CURLOPT_PROXY" value="10004"/>
      <member name="CURLOPT_USERPWD" value="10005"/>
      <member name="CURLOPT_PROXYUSERPWD" value="10006"/>
      <member name="CURLOPT_RANGE" value="10007"/>
      <member name="CURLOPT_INFILE" value="10009"/>
      <member name="CURLOPT_READDATA" value="10009"/>
      <member name="CURLOPT_ERRORBUFFER" value="10010"/>
      <member name="CURLOPT_WRITEFUNCTION" value="20011"/>
      <member name="CURLOPT_READFUNCTION" value="20012"/>
      <member name="CURLOPT_TIMEOUT" value="13"/>
      <member name="CURLOPT_INFILESIZE" value="14"/>
      <member name="CURLOPT_POSTFIELDS" value="10015"/>
      <member name="CURLOPT_REFERER" value="10016"/>
      <member name="CURLOPT_FTPPORT" value="10017"/>
      <member name="CURLOPT_USERAGENT" value="10018"/>
      <member name="CURLOPT_LOW_SPEED_LIMIT" value="19"/>
      <member name="CURLOPT_LOW_SPEED_TIME" value="20"/>
      <member name="CURLOPT_RESUME_FROM" value="21"/>
      <member name="CURLOPT_COOKIE" value="10022"/>
      <member name="CURLOPT_HTTPHEADER" value="10023"/>
      <member name="CURLOPT_RTSPHEADER" value="10023"/>
      <member name="CURLOPT_HTTPPOST" value="10024"/>
      <member name="CURLOPT_SSLCERT" value="10025"/>
      <member name="CURLOPT_KEYPASSWD" value="10026"/>
      <member name="CURLOPT_CRLF" value="27"/>
      <member name="CURLOPT_QUOTE" value="10028"/>
      <member name="CURLOPT_WRITEHEADER" value="10029"/>
      <member name="CURLOPT_HEADERDATA" value="10029"/>
      <member name="CURLOPT_COOKIEFILE" value="10031"/>
      <member name="CURLOPT_SSLVERSION" value="32"/>
      <member name="CURLOPT_TIMECONDITION" value="33"/>
      <member name="CURLOPT_TIMEVALUE" value="34"/>
      <member name="CURLOPT_CUSTOMREQUEST" value="10036"/>
      <member name="CURLOPT_STDERR" value="10037"/>
      <member name="CURLOPT_POSTQUOTE" value="10039"/>
      <member name="CURLOPT_WRITEINFO" value="10040"/>
      <member name="CURLOPT_VERBOSE" value="41"/>
      <member name="CURLOPT_HEADER" value="42"/>
      <member name="CURLOPT_NOPROGRESS" value="43"/>
      <member name="CURLOPT_NOBODY" value="44"/>
      <member name="CURLOPT_FAILONERROR" value="45"/>
      <member name="CURLOPT_UPLOAD" value="46"/>
      <member name="CURLOPT_POST" value="47"/>
      <member name="CURLOPT_DIRLISTONLY" value="48"/>
      <member name="CURLOPT_APPEND" value="50"/>
      <member name="CURLOPT_NETRC" value="51"/>
      <member name="CURLOPT_FOLLOWLOCATION" value="52"/>
      <member name="CURLOPT_TRANSFERTEXT" value="53"/>
      <member name="CURLOPT_PUT" value="54"/>
      <member name="CURLOPT_PROGRESSFUNCTION" value="20056"/>
      <member name="CURLOPT_PROGRESSDATA" value="10057"/>
      <member name="CURLOPT_AUTOREFERER" value="58"/>
      <member name="CURLOPT_PROXYPORT" value="59"/>
      <member name="CURLOPT_POSTFIELDSIZE" value="60"/>
      <member name="CURLOPT_HTTPPROXYTUNNEL" value="61"/>
      <member name="CURLOPT_INTERFACE" value="10062"/>
      <member name="CURLOPT_KRBLEVEL" value="10063"/>
      <member name="CURLOPT_SSL_VERIFYPEER" value="64"/>
      <member name="CURLOPT_CAINFO" value="10065"/>
      <member name="CURLOPT_MAXREDIRS" value="68"/>
      <member name="CURLOPT_FILETIME" value="69"/>
      <member name="CURLOPT_TELNETOPTIONS" value="10070"/>
      <member name="CURLOPT_MAXCONNECTS" value="71"/>
      <member name="CURLOPT_CLOSEPOLICY" value="72"/>
      <member name="CURLOPT_FRESH_CONNECT" value="74"/>
      <member name="CURLOPT_FORBID_REUSE" value="75"/>
      <member name="CURLOPT_RANDOM_FILE" value="10076"/>
      <member name="CURLOPT_EGDSOCKET" value="10077"/>
      <member name="CURLOPT_CONNECTTIMEOUT" value="78"/>
      <member name="CURLOPT_HEADERFUNCTION" value="20079"/>
      <member name="CURLOPT_HTTPGET" value="80"/>
      <member name="CURLOPT_SSL_VERIFYHOST" value="81"/>
      <member name="CURLOPT_COOKIEJAR" value="10082"/>
      <member name="CURLOPT_SSL_CIPHER_LIST" value="10083"/>
      <member name="CURLOPT_HTTP_VERSION" value="84"/>
      <member name="CURLOPT_FTP_USE_EPSV" value="85"/>
      <member name="CURLOPT_SSLCERTTYPE" value="10086"/>
      <member name="CURLOPT_SSLKEY" value="10087"/>
      <member name="CURLOPT_SSLKEYTYPE" value="10088"/>
      <member name="CURLOPT_SSLENGINE" value="10089"/>
      <member name="CURLOPT_SSLENGINE_DEFAULT" value="90"/>
      <member name="CURLOPT_DNS_USE_GLOBAL_CACHE" value="91"/>
      <member name="CURLOPT_DNS_CACHE_TIMEOUT" value="92"/>
      <member name="CURLOPT_PREQUOTE" value="10093"/>
      <member name="CURLOPT_DEBUGFUNCTION" value="20094"/>
      <member name="CURLOPT_DEBUGDATA" value="10095"/>
      <member name="CURLOPT_COOKIESESSION" value="96"/>
      <member name="CURLOPT_CAPATH" value="10097"/>
      <member name="CURLOPT_BUFFERSIZE" value="98"/>
      <member name="CURLOPT_NOSIGNAL" value="99"/>
      <member name="CURLOPT_SHARE" value="10100"/>
      <member name="CURLOPT_PROXYTYPE" value="101"/>
      <member name="CURLOPT_ACCEPT_ENCODING" value="10102"/>
      <member name="CURLOPT_PRIVATE" value="10103"/>
      <member name="CURLOPT_HTTP200ALIASES" value="10104"/>
      <member name="CURLOPT_UNRESTRICTED_AUTH" value="105"/>
      <member name="CURLOPT_FTP_USE_EPRT" value="106"/>
      <member name="CURLOPT_HTTPAUTH" value="107"/>
      <member name="CURLOPT_SSL_CTX_FUNCTION" value="20108"/>
      <member name="CURLOPT_SSL_CTX_DATA" value="10109"/>
      <member name="CURLOPT_FTP_CREATE_MISSING_DIRS" value="110"/>
      <member name="CURLOPT_PROXYAUTH" value="111"/>
      <member name="CURLOPT_FTP_RESPONSE_TIMEOUT" value="112"/>
      <member name="CURLOPT_IPRESOLVE" value="113"/>
      <member name="CURLOPT_MAXFILESIZE" value="114"/>
      <member name="CURLOPT_INFILESIZE_LARGE" value="30115"/>
      <member name="CURLOPT_RESUME_FROM_LARGE" value="30116"/>
      <member name="CURLOPT_MAXFILESIZE_LARGE" value="30117"/>
      <member name="CURLOPT_NETRC_FILE" value="10118"/>
      <member name="CURLOPT_USE_SSL" value="119"/>
      <member name="CURLOPT_POSTFIELDSIZE_LARGE" value="30120"/>
      <member name="CURLOPT_TCP_NODELAY" value="121"/>
      <member name="CURLOPT_FTPSSLAUTH" value="129"/>
      <member name="CURLOPT_IOCTLFUNCTION" value="20130"/>
      <member name="CURLOPT_IOCTLDATA" value="10131"/>
      <member name="CURLOPT_FTP_ACCOUNT" value="10134"/>
      <member name="CURLOPT_COOKIELIST" value="10135"/>
      <member name="CURLOPT_IGNORE_CONTENT_LENGTH" value="136"/>
      <member name="CURLOPT_FTP_SKIP_PASV_IP" value="137"/>
      <member name="CURLOPT_FTP_FILEMETHOD" value="138"/>
      <member name="CURLOPT_LOCALPORT" value="139"/>
      <member name="CURLOPT_LOCALPORTRANGE" value="140"/>
      <member name="CURLOPT_CONNECT_ONLY" value="141"/>
      <member name="CURLOPT_CONV_FROM_NETWORK_FUNCTION" value="20142"/>
      <member name="CURLOPT_CONV_TO_NETWORK_FUNCTION" value="20143"/>
      <member name="CURLOPT_CONV_FROM_UTF8_FUNCTION" value="20144"/>
      <member name="CURLOPT_MAX_SEND_SPEED_LARGE" value="30145"/>
      <member name="CURLOPT_MAX_RECV_SPEED_LARGE" value="30146"/>
      <member name="CURLOPT_FTP_ALTERNATIVE_TO_USER" value="10147"/>
      <member name="CURLOPT_SOCKOPTFUNCTION" value="20148"/>
      <member name="CURLOPT_SOCKOPTDATA" value="10149"/>
      <member name="CURLOPT_SSL_SESSIONID_CACHE" value="150"/>
      <member name="CURLOPT_SSH_AUTH_TYPES" value="151"/>
      <member name="CURLOPT_SSH_PUBLIC_KEYFILE" value="10152"/>
      <member name="CURLOPT_SSH_PRIVATE_KEYFILE" value="10153"/>
      <member name="CURLOPT_FTP_SSL_CCC" value="154"/>
      <member name="CURLOPT_TIMEOUT_MS" value="155"/>
      <member name="CURLOPT_CONNECTTIMEOUT_MS" value="156"/>
      <member name="CURLOPT_HTTP_TRANSFER_DECODING" value="157"/>
      <member name="CURLOPT_HTTP_CONTENT_DECODING" value="158"/>
      <member name="CURLOPT_NEW_FILE_PERMS" value="159"/>
      <member name="CURLOPT_NEW_DIRECTORY_PERMS" value="160"/>
      <member name="CURLOPT_POSTREDIR" value="161"/>
      <member name="CURLOPT_SSH_HOST_PUBLIC_KEY_MD5" value="10162"/>
      <member name="CURLOPT_OPENSOCKETFUNCTION" value="20163"/>
      <member name="CURLOPT_OPENSOCKETDATA" value="10164"/>
      <member name="CURLOPT_COPYPOSTFIELDS" value="10165"/>
      <member name="CURLOPT_PROXY_TRANSFER_MODE" value="166"/>
      <member name="CURLOPT_SEEKFUNCTION" value="20167"/>
      <member name="CURLOPT_SEEKDATA" value="10168"/>
      <member name="CURLOPT_CRLFILE" value="10169"/>
      <member name="CURLOPT_ISSUERCERT" value="10170"/>
      <member name="CURLOPT_ADDRESS_SCOPE" value="171"/>
      <member name="CURLOPT_CERTINFO" value="172"/>
      <member name="CURLOPT_USERNAME" value="10173"/>
      <member name="CURLOPT_PASSWORD" value="10174"/>
      <member name="CURLOPT_PROXYUSERNAME" value="10175"/>
      <member name="CURLOPT_PROXYPASSWORD" value="10176"/>
      <member name="CURLOPT_NOPROXY" value="10177"/>
      <member name="CURLOPT_TFTP_BLKSIZE" value="178"/>
      <member name="CURLOPT_SOCKS5_GSSAPI_SERVICE" value="10179"/>
      <member name="CURLOPT_SOCKS5_GSSAPI_NEC" value="180"/>
      <member name="CURLOPT_PROTOCOLS" value="181"/>
      <member name="CURLOPT_REDIR_PROTOCOLS" value="182"/>
      <member name="CURLOPT_SSH_KNOWNHOSTS" value="10183"/>
      <member name="CURLOPT_SSH_KEYFUNCTION" value="20184"/>
      <member name="CURLOPT_SSH_KEYDATA" value="10185"/>
      <member name="CURLOPT_MAIL_FROM" value="10186"/>
      <member name="CURLOPT_MAIL_RCPT" value="10187"/>
      <member name="CURLOPT_FTP_USE_PRET" value="188"/>
      <member name="CURLOPT_RTSP_REQUEST" value="189"/>
      <member name="CURLOPT_RTSP_SESSION_ID" value="10190"/>
      <member name="CURLOPT_RTSP_STREAM_URI" value="10191"/>
      <member name="CURLOPT_RTSP_TRANSPORT" value="10192"/>
      <member name="CURLOPT_RTSP_CLIENT_CSEQ" value="193"/>
      <member name="CURLOPT_RTSP_SERVER_CSEQ" value="194"/>
      <member name="CURLOPT_INTERLEAVEDATA" value="10195"/>
      <member name="CURLOPT_INTERLEAVEFUNCTION" value="20196"/>
      <member name="CURLOPT_WILDCARDMATCH" value="197"/>
      <member name="CURLOPT_CHUNK_BGN_FUNCTION" value="20198"/>
      <member name="CURLOPT_CHUNK_END_FUNCTION" value="20199"/>
      <member name="CURLOPT_FNMATCH_FUNCTION" value="20200"/>
      <member name="CURLOPT_CHUNK_DATA" value="10201"/>
      <member name="CURLOPT_FNMATCH_DATA" value="10202"/>
      <member name="CURLOPT_RESOLVE" value="10203"/>
      <member name="CURLOPT_TLSAUTH_USERNAME" value="10204"/>
      <member name="CURLOPT_TLSAUTH_PASSWORD" value="10205"/>
      <member name="CURLOPT_TLSAUTH_TYPE" value="10206"/>
      <member name="CURLOPT_TRANSFER_ENCODING" value="207"/>
      <member name="CURLOPT_CLOSESOCKETFUNCTION" value="20208"/>
      <member name="CURLOPT_CLOSESOCKETDATA" value="10209"/>
      <member name="CURLOPT_LASTENTRY" value="10210"/>
    </enum>
    <enum name="CURLversion">
      <member name="CURLVERSION_FIRST" value="0"/>
      <member name="CURLVERSION_SECOND" value="1"/>
      <member name="CURLVERSION_THIRD" value="2"/>
      <member name="CURLVERSION_FOURTH" value="3"/>
      <member name="CURLVERSION_NOW" value="3"/>
      <member name="CURLVERSION_LAST" value="4"/>
    </enum>
    <enum name="curl_TimeCond">
      <member name="CURL_TIMECOND_NONE" value="0"/>
      <member name="CURL_TIMECOND_IFMODSINCE" value="1"/>
      <member name="CURL_TIMECOND_IFUNMODSINCE" value="2"/>
      <member name="CURL_TIMECOND_LASTMOD" value="3"/>
      <member name="CURL_TIMECOND_LAST" value="4"/>
    </enum>
    <enum name="curl_closepolicy">
      <member name="CURLCLOSEPOLICY_NONE" value="0"/>
      <member name="CURLCLOSEPOLICY_OLDEST" value="1"/>
      <member name="CURLCLOSEPOLICY_LEAST_RECENTLY_USED" value="2"/>
      <member name="CURLCLOSEPOLICY_LEAST_TRAFFIC" value="3"/>
      <member name="CURLCLOSEPOLICY_SLOWEST" value="4"/>
      <member name="CURLCLOSEPOLICY_CALLBACK" value="5"/>
      <member name="CURLCLOSEPOLICY_LAST" value="6"/>
    </enum>
    <enum name="curl_ftpauth">
      <member name="CURLFTPAUTH_DEFAULT" value="0"/>
      <member name="CURLFTPAUTH_SSL" value="1"/>
      <member name="CURLFTPAUTH_TLS" value="2"/>
      <member name="CURLFTPAUTH_LAST" value="3"/>
    </enum>
    <enum name="curl_ftpccc">
      <member name="CURLFTPSSL_CCC_NONE" value="0"/>
      <member name="CURLFTPSSL_CCC_PASSIVE" value="1"/>
      <member name="CURLFTPSSL_CCC_ACTIVE" value="2"/>
      <member name="CURLFTPSSL_CCC_LAST" value="3"/>
    </enum>
    <enum name="curl_ftpcreatedir">
      <member name="CURLFTP_CREATE_DIR_NONE" value="0"/>
      <member name="CURLFTP_CREATE_DIR" value="1"/>
      <member name="CURLFTP_CREATE_DIR_RETRY" value="2"/>
      <member name="CURLFTP_CREATE_DIR_LAST" value="3"/>
    </enum>
    <enum name="curl_ftpmethod">
      <member name="CURLFTPMETHOD_DEFAULT" value="0"/>
      <member name="CURLFTPMETHOD_MULTICWD" value="1"/>
      <member name="CURLFTPMETHOD_NOCWD" value="2"/>
      <member name="CURLFTPMETHOD_SINGLECWD" value="3"/>
      <member name="CURLFTPMETHOD_LAST" value="4"/>
    </enum>
    <enum name="curl_infotype">
      <member name="CURLINFO_TEXT" value="0"/>
      <member name="CURLINFO_HEADER_IN" value="1"/>
      <member name="CURLINFO_HEADER_OUT" value="2"/>
      <member name="CURLINFO_DATA_IN" value="3"/>
      <member name="CURLINFO_DATA_OUT" value="4"/>
      <member name="CURLINFO_SSL_DATA_IN" value="5"/>
      <member name="CURLINFO_SSL_DATA_OUT" value="6"/>
      <member name="CURLINFO_END" value="7"/>
    </enum>
    <enum name="curl_lock_access">
      <member name="CURL_LOCK_ACCESS_NONE" value="0"/>
      <member name="CURL_LOCK_ACCESS_SHARED" value="1"/>
      <member name="CURL_LOCK_ACCESS_SINGLE" value="2"/>
      <member name="CURL_LOCK_ACCESS_LAST" value="3"/>
    </enum>
    <enum name="curl_lock_data">
      <member name="CURL_LOCK_DATA_NONE" value="0"/>
      <member name="CURL_LOCK_DATA_SHARE" value="1"/>
      <member name="CURL_LOCK_DATA_COOKIE" value="2"/>
      <member name="CURL_LOCK_DATA_DNS" value="3"/>
      <member name="CURL_LOCK_DATA_SSL_SESSION" value="4"/>
      <member name="CURL_LOCK_DATA_CONNECT" value="5"/>
      <member name="CURL_LOCK_DATA_LAST" value="6"/>
    </enum>
    <enum name="curl_proxytype">
      <member name="CURLPROXY_HTTP" value="0"/>
      <member name="CURLPROXY_HTTP_1_0" value="1"/>
      <member name="CURLPROXY_SOCKS4" value="4"/>
      <member name="CURLPROXY_SOCKS5" value="5"/>
      <member name="CURLPROXY_SOCKS4A" value="6"/>
      <member name="CURLPROXY_SOCKS5_HOSTNAME" value="7"/>
    </enum>
    <enum name="curl_usessl">
      <member name="CURLUSESSL_NONE" value="0"/>
      <member name="CURLUSESSL_TRY" value="1"/>
      <member name="CURLUSESSL_CONTROL" value="2"/>
      <member name="CURLUSESSL_ALL" value="3"/>
      <member name="CURLUSESSL_LAST" value="4"/>
    </enum>
    <enum name="curl_ftpssl">
      <member name="CURLFTPSSL_NONE" value="0"/>
      <member name="CURLFTPSSL_TRY" value="1"/>
      <member name="CURLFTPSSL_CONTROL" value="2"/>
      <member name="CURLFTPSSL_ALL" value="3"/>
      <member name="CURLFTPSSL_LAST" value="4"/>
    </enum>
    <enum name="curlfiletype">
      <member name="CURLFILETYPE_FILE" value="0"/>
      <member name="CURLFILETYPE_DIRECTORY" value="1"/>
      <member name="CURLFILETYPE_SYMLINK" value="2"/>
      <member name="CURLFILETYPE_DEVICE_BLOCK" value="3"/>
      <member name="CURLFILETYPE_DEVICE_CHAR" value="4"/>
      <member name="CURLFILETYPE_NAMEDPIPE" value="5"/>
      <member name="CURLFILETYPE_SOCKET" value="6"/>
      <member name="CURLFILETYPE_DOOR" value="7"/>
      <member name="CURLFILETYPE_UNKNOWN" value="8"/>
    </enum>
    <enum name="curliocmd">
      <member name="CURLIOCMD_NOP" value="0"/>
      <member name="CURLIOCMD_RESTARTREAD" value="1"/>
      <member name="CURLIOCMD_LAST" value="2"/>
    </enum>
    <enum name="curlioerr">
      <member name="CURLIOE_OK" value="0"/>
      <member name="CURLIOE_UNKNOWNCMD" value="1"/>
      <member name="CURLIOE_FAILRESTART" value="2"/>
      <member name="CURLIOE_LAST" value="3"/>
    </enum>
    <enum name="curlsocktype">
      <member name="CURLSOCKTYPE_IPCXN" value="0"/>
      <member name="CURLSOCKTYPE_LAST" value="1"/>
    </enum>
    <enum name="httpversion">
      <member name="CURL_HTTP_VERION_1_0" value="0"/>
      <member name="CURL_HTTP_VERION_1_1" value="1"/>
      <member name="CURL_HTTP_VERION_LAST" value="2"/>
    </enum>
    <enum name="rtspreq">
      <member name="CURL_RTSPREQ_NONE" value="0"/>
      <member name="CURL_RTSPREQ_OPTIONS" value="1"/>
      <member name="CURL_RTSPREQ_DESCRIBE" value="2"/>
      <member name="CURL_RTSPREQ_ANNOUNCE" value="3"/>
      <member name="CURL_RTSPREQ_SETUP" value="4"/>
      <member name="CURL_RTSPREQ_PLAY" value="5"/>
      <member name="CURL_RTSPREQ_PAUSE" value="6"/>
      <member name="CURL_RTSPREQ_TEARDOWN" value="7"/>
      <member name="CURL_RTSPREQ_GET_PARAMETER" value="8"/>
      <member name="CURL_RTSPREQ_SET_PARAMETER" value="9"/>
      <member name="CURL_RTSPREQ_RECORD" value="10"/>
      <member name="CURL_RTSPREQ_RECEIVE" value="11"/>
      <member name="CURL_RTSPREQ_LAST" value="12"/>
    </enum>

    <enum name="CURL_NETRC_OPTION">
      <member name="CURL_NETRC_IGNORED" value="0"/>
      <member name="CURL_NETRC_OPTIONAL" value="1"/>
      <member name="CURL_NETRC_REQUIRED" value="2"/>
      <member name="CURL_NETRC_LAST" value="3"/>
    </enum>

    <enum name="sslversion">
      <member name="CURL_SSLVERSION_DEFAULT" value="0"/>
      <member name="CURL_SSLVERSION_TLSv1" value="1"/>
      <member name="CURL_SSLVERSION_SSLv2" value="2"/>
      <member name="CURL_SSLVERSION_SSLv3" value="3"/>
      <member name="CURL_SSLVERSION_LAST" value="4"/>
    </enum>

    <enum name="CURL_TLSAUTH">
      <member name="CURL_TLSAUTH_NONE" value="0"/>
      <member name="CURL_TLSAUTH_SRP" value="1"/>
      <member name="CURL_TLSAUTH_LAST" value="2"/>
    </enum>
    <constant name="CURLAUTH_ANYSAFE" type="int" value="-1"/>
    <constant name="CURLAUTH_BASIC" type="int" value="1"/>
    <constant name="CURLAUTH_DIGEST" type="int" value="2"/>
    <constant name="CURLAUTH_DIGEST_IE" type="int" value="16"/>
    <constant name="CURLAUTH_GSSNEGOTIATE" type="int" value="4"/>
    <constant name="CURLAUTH_NONE" type="int" value="0"/>
    <constant name="CURLAUTH_NTLM" type="int" value="8"/>
    <constant name="CURLAUTH_ONLY" type="int" value="-2147483648"/>
    <constant name="CURLE_ALREADY_COMPLETE" type="int" value="99999"/>
    <constant name="CURLINFO_DOUBLE" type="int" value="3145728"/>
    <constant name="CURLINFO_LONG" type="int" value="2097152"/>
    <constant name="CURLINFO_MASK" type="int" value="1048575"/>
    <constant name="CURLINFO_SLIST" type="int" value="4194304"/>
    <constant name="CURLINFO_STRING" type="int" value="1048576"/>
    <constant name="CURLINFO_TYPEMASK" type="int" value="15728640"/>
    <constant name="CURLOPTTYPE_FUNCTIONPOINT" type="int" value="20000"/>
    <constant name="CURLOPTTYPE_LONG" type="int" value="0"/>
    <constant name="CURLOPTTYPE_OBJECTPOINT" type="int" value="10000"/>
    <constant name="CURLOPTTYPE_OFF_T" type="int" value="30000"/>
    <constant name="CURLPAUSE_ALL" type="int" value="0"/>
    <constant name="CURLPAUSE_CONT" type="int" value="0"/>
    <constant name="CURLPAUSE_RECV" type="int" value="1"/>
    <constant name="CURLPAUSE_RECV_CONT" type="int" value="0"/>
    <constant name="CURLPAUSE_SEND" type="int" value="4"/>
    <constant name="CURLPAUSE_SEND_CONT" type="int" value="0"/>
    <constant name="CURLPROTO_ALL" type="int" value="-1"/>
    <constant name="CURLPROTO_DICT" type="int" value="512"/>
    <constant name="CURLPROTO_FILE" type="int" value="1024"/>
    <constant name="CURLPROTO_FTP" type="int" value="4"/>
    <constant name="CURLPROTO_FTPS" type="int" value="8"/>
    <constant name="CURLPROTO_GOPHER" type="int" value="33554432"/>
    <constant name="CURLPROTO_HTTP" type="int" value="1"/>
    <constant name="CURLPROTO_HTTPS" type="int" value="2"/>
    <constant name="CURLPROTO_IMAP" type="int" value="4096"/>
    <constant name="CURLPROTO_IMAPS" type="int" value="8192"/>
    <constant name="CURLPROTO_LDAP" type="int" value="128"/>
    <constant name="CURLPROTO_LDAPS" type="int" value="256"/>
    <constant name="CURLPROTO_POP3" type="int" value="16384"/>
    <constant name="CURLPROTO_POP3S" type="int" value="32768"/>
    <constant name="CURLPROTO_RTMP" type="int" value="524288"/>
    <constant name="CURLPROTO_RTMPE" type="int" value="2097152"/>
    <constant name="CURLPROTO_RTMPS" type="int" value="8388608"/>
    <constant name="CURLPROTO_RTMPT" type="int" value="1048576"/>
    <constant name="CURLPROTO_RTMPTE" type="int" value="4194304"/>
    <constant name="CURLPROTO_RTMPTS" type="int" value="16777216"/>
    <constant name="CURLPROTO_RTSP" type="int" value="262144"/>
    <constant name="CURLPROTO_SCP" type="int" value="16"/>
    <constant name="CURLPROTO_SFTP" type="int" value="32"/>
    <constant name="CURLPROTO_SMTP" type="int" value="65536"/>
    <constant name="CURLPROTO_SMTPS" type="int" value="131072"/>
    <constant name="CURLPROTO_TELNET" type="int" value="64"/>
    <constant name="CURLPROTO_TFTP" type="int" value="2048"/>
    <constant name="CURLSSH_AUTH_ANY" type="int" value="-1"/>
    <constant name="CURLSSH_AUTH_HOST" type="int" value="4"/>
    <constant name="CURLSSH_AUTH_KEYBOARD" type="int" value="8"/>
    <constant name="CURLSSH_AUTH_NONE" type="int" value="0"/>
    <constant name="CURLSSH_AUTH_PASSWORD" type="int" value="2"/>
    <constant name="CURLSSH_AUTH_PUBLICKEY" type="int" value="1"/>
    <constant name="CURL_CHUNK_BGN_FUNC_SKIP" type="int" value="2"/>
    <constant name="CURL_CHUNK_END_FUNC_FAIL" type="int" value="1"/>
    <constant name="CURL_CHUNK_END_FUNC_OK" type="int" value="0"/>
    <constant name="CURL_CSELECT_ERR" type="int" value="4"/>
    <constant name="CURL_CSELECT_IN" type="int" value="1"/>
    <constant name="CURL_CSELECT_OUT" type="int" value="2"/>
    <constant name="CURL_ERROR_SIZE" type="int" value="256"/>
    <constant name="CURL_FNMATCHFUNC_FAIL" type="int" value="2"/>
    <constant name="CURL_FNMATCHFUNC_MATCH" type="int" value="0"/>
    <constant name="CURL_FNMATCHFUNC_NOMATCH" type="int" value="1"/>
    <constant name="CURL_FORMAT_CURL_OFF_T" type="char*" value="ld"/>
    <constant name="CURL_FORMAT_CURL_OFF_TU" type="char*" value="lu"/>
    <constant name="CURL_FORMAT_OFF_T" type="char*" value="%ld"/>
    <constant name="CURL_GLOBAL_ALL" type="int" value="0"/>
    <constant name="CURL_GLOBAL_NOTHING" type="int" value="0"/>
    <constant name="CURL_GLOBAL_SSL" type="int" value="1"/>
    <constant name="CURL_GLOBAL_WIN32" type="int" value="2"/>
    <constant name="CURL_IPRESOLVE_V4" type="int" value="1"/>
    <constant name="CURL_IPRESOLVE_V6" type="int" value="2"/>
    <constant name="CURL_IPRESOLVE_WHATEVER" type="int" value="0"/>
    <constant name="CURL_POLL_IN" type="int" value="1"/>
    <constant name="CURL_POLL_INOUT" type="int" value="3"/>
    <constant name="CURL_POLL_NONE" type="int" value="0"/>
    <constant name="CURL_POLL_OUT" type="int" value="2"/>
    <constant name="CURL_POLL_REMOVE" type="int" value="4"/>
    <constant name="CURL_PULL_SYS_SOCKET_H" type="int" value="1"/>
    <constant name="CURL_PULL_SYS_TYPES_H" type="int" value="1"/>
    <constant name="CURL_REDIR_GET_ALL" type="int" value="0"/>
    <constant name="CURL_REDIR_POST_301" type="int" value="1"/>
    <constant name="CURL_REDIR_POST_302" type="int" value="2"/>
    <constant name="CURL_REDIR_POST_ALL" type="int" value="0"/>
    <constant name="CURL_SEEKFUNC_CANTSEEK" type="int" value="2"/>
    <constant name="CURL_SEEKFUNC_FAIL" type="int" value="1"/>
    <constant name="CURL_SEEKFUNC_OK" type="int" value="0"/>
    <constant name="CURL_SIZEOF_CURL_OFF_T" type="int" value="8"/>
    <constant name="CURL_SIZEOF_CURL_SOCKLEN_T" type="int" value="4"/>
    <constant name="CURL_SIZEOF_LONG" type="int" value="8"/>
    <constant name="CURL_SOCKET_BAD" type="int" value="-1"/>
    <constant name="CURL_VERSION_ASYNCHDNS" type="int" value="128"/>
    <constant name="CURL_VERSION_CONV" type="int" value="4096"/>
    <constant name="CURL_VERSION_CURLDEBUG" type="int" value="8192"/>
    <constant name="CURL_VERSION_DEBUG" type="int" value="64"/>
    <constant name="CURL_VERSION_GSSNEGOTIATE" type="int" value="32"/>
    <constant name="CURL_VERSION_IDN" type="int" value="1024"/>
    <constant name="CURL_VERSION_IPV6" type="int" value="1"/>
    <constant name="CURL_VERSION_KERBEROS4" type="int" value="2"/>
    <constant name="CURL_VERSION_LARGEFILE" type="int" value="512"/>
    <constant name="CURL_VERSION_LIBZ" type="int" value="8"/>
    <constant name="CURL_VERSION_NTLM" type="int" value="16"/>
    <constant name="CURL_VERSION_SPNEGO" type="int" value="256"/>
    <constant name="CURL_VERSION_SSL" type="int" value="4"/>
    <constant name="CURL_VERSION_SSPI" type="int" value="2048"/>
    <constant name="CURL_VERSION_TLSAUTH_SRP" type="int" value="16384"/>
    <constant name="HTTPPOST_CALLBACK" type="int" value="64"/>
    <constant name="HTTPPOST_FILENAME" type="int" value="1"/>
    <constant name="HTTPPOST_PTRBUFFER" type="int" value="32"/>
    <constant name="HTTPPOST_BUFFER" type="int" value="16"/>
    <constant name="HTTPPOST_PTRNAME" type="int" value="4"/>
    <constant name="HTTPPOST_PTRCONTENTS" type="int" value="8"/>
    <constant name="HTTPPOST_READFILE" type="int" value="2"/>
    <constant name="LIBCURL_COPYRIGHT" type="char*" value="1996 - 2011 Daniel Stenberg, &lt;daniel@haxx.se&gt;."/>
    <constant name="LIBCURL_TIMESTAMP" type="char*" value="Thu Jun 23 08:25:34 UTC 2011"/>
    <constant name="LIBCURL_VERSION" type="char*" value="7.21.7"/>
    <constant name="LIBCURL_VERSION_MAJOR" type="int" value="7"/>
    <constant name="LIBCURL_VERSION_MINOR" type="int" value="21"/>
    <constant name="LIBCURL_VERSION_NUM" type="int" value="464135"/>
    <constant name="LIBCURL_VERSION_PATCH" type="int" value="7"/>
  </namespace>
</api>


class openresty {
# execute 'yum update'
        exec { 'development-tools':
                command => "/usr/bin/yum -y groupinstall 'Development Tools'",
        }
	exec { 'prereq':
                require => Exec['development-tools'],
                command => '/usr/bin/yum -y install readline-devel pcre-devel openssl-devel gcc',
                    
        }

        file { "/usr/local/src/openresty-1.11.2.5.tar.gz":
                require => Exec['prereq'],
                ensure => present,
                mode => 0600,
                source => "puppet:///modules/openresty/files/openresty-1.11.2.5.tar.gz",
                before => Exec['unpack-tar'],
        }
        exec { 'unpack-tar':
                cwd => '/usr/local/src',
                command => '/bin/tar -zxf openresty-1.11.2.5.tar.gz',
        }
        exec { 'install-openresty':
             require => Exec['unpack-tar'],
	     user => 'root',
             cwd => '/usr/local/src/openresty-1.11.2.5',
	     path    => ['/usr/local/src/openresty-1.11.2.5','/usr/bin','/bin','/sbin'],
	     command => './configure --with-http_ssl_module --with-pcre --with-pcre-jit --with-luajit  --without-http_echo_module --without-http_xss_module --without-http_coolkit_module --without-http_set_misc_module --without-http_form_input_module --without-http_srcache_module --without-http_lua_module --without-http_lua_upstream_module --without-http_headers_more_module --without-http_array_var_module --without-http_memc_module --without-http_redis2_module --without-http_redis_module --without-http_rds_json_module --without-http_rds_csv_module --without-ngx_devel_kit_module --without-lua_cjson --without-lua_redis_parser --without-lua_rds_parser --without-lua_resty_dns --without-lua_resty_memcached --without-lua_resty_redis --without-lua_resty_mysql --without-lua_resty_upload --without-lua_resty_upstream_healthcheck --without-lua_resty_string --without-lua_resty_websocket --without-lua_resty_lock --without-lua_resty_lrucache --without-lua_resty_core --without-lua51 --without-select_module --without-poll_module --without-http_charset_module --without-http_gzip_module --without-http_ssi_module --without-http_userid_module --without-http_access_module --without-http_auth_basic_module --without-http_autoindex_module --without-http_geo_module --without-http_map_module --without-http_split_clients_module --without-http_referer_module --without-http_rewrite_module --without-http_proxy_module --without-http_fastcgi_module --without-http_uwsgi_module --without-http_scgi_module --without-http_memcached_module --without-http_limit_conn_module --without-http_limit_req_module --without-http_empty_gif_module --without-http_browser_module --without-http_upstream_ip_hash_module --without-http_upstream_least_conn_module --without-http_upstream_keepalive_module --without-http-cache --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module',
        } ->
	
	exec { 'make':
	     user => 'root',
             cwd => '/usr/local/src/openresty-1.11.2.5',
	     path => ['/usr/local/src/openresty-1.11.2.5','/usr/bin','/bin','/sbin'],
	     command => 'make',
	} ->
	exec { 'make-install':  
             user => 'root',
	     cwd => '/usr/local/src/openresty-1.11.2.5',
             path => ['/usr/local/src/openresty-1.11.2.5','/usr/bin','/bin','/sbin'],
             command => 'make install',
        }		
	file { '/etc/profile.d/append-nginx-path.sh':
    	    mode    => 644,
            content => 'PATH=/usr/local/openresty/nginx/sbin:$PATH',
	    before => Exec['run-nginx'],
        }
	exec { 'run-nginx':
	     require => Exec['make-install'],
	     cwd => '/usr/local/openresty/nginx', #default path of openresty
	     path => ['/usr/bin','/bin','/sbin','/usr/local/openresty/nginx/sbin'],
	     command => 'nginx -p `pwd`/ -c conf/nginx.conf',
	}

}


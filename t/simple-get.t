use lib 'lib';
use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';

no_long_string();

run_tests();

__DATA__

=== TEST 1: basic with content length
--- http_config eval: $::HttpConfig
--- config
    resolver $TEST_NGINX_RESOLVER;
    location /foo {
        content_by_lua '
	    ngx.header.content_length = 7
            ngx.say("foobar")
        ';
    }

    location /t {
        content_by_lua '
	    local http = require "resty.http.simple"
	    local res, err = http.request("127.0.0.1", 1984, { path = "/foo" })
	    ngx.say(err)
	    ngx.say(res.body)  
            ngx.say(res.status)          
        ';
    }
--- request
GET /t
--- response_body
nil
foobar

200
--- no_error_log
[error]


=== TEST 1: basic without content length
--- http_config eval: $::HttpConfig
--- config
    resolver $TEST_NGINX_RESOLVER;
    location /foo {
        content_by_lua '
            ngx.say("foobar")
        ';
    }

    location /t {
        content_by_lua '
	    local http = require "resty.http.simple"
	    local res, err = http.request("127.0.0.1", 1984, { path = "/foo" })
	    ngx.say(err)
	    ngx.say(res.body)  
            ngx.say(res.status)          
        ';
    }
--- request
GET /t
--- response_body
nil
foobar

200
--- no_error_log
[error]
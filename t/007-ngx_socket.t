# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket 'no_plan';

run_tests();

__DATA__
=== TEST 2: ngx_socket2
ngx_socket2
--- config
resolver 8.8.8.8;
location = /ngx_socket2 {
    default_type 'application/json;charset=UTF-8';
    content_by_php '
        $fd = ngx_socket_create();
        yield ngx_socket_connect($fd, "api.github.com", 80);
        $send_buf = "GET /301 HTTP/1.1\r\nHost: api.github.com\r\nConnection: close\r\n\r\n";
        yield ngx_socket_send($fd, $send_buf, strlen($send_buf));
        $ret = "";
        yield ngx_socket_recv($fd, $ret);
        yield ngx_socket_close($fd);
        $ret = explode("\r\n",$ret);
        var_dump($ret);
    ';
}
--- request
GET /ngx_socket
--- response_body
array(6) {
  [0]=>
  string(30) "HTTP/1.1 301 Moved Permanently"
  [1]=>
  string(17) "Content-length: 0"
  [2]=>
  string(36) "Location: https://api.github.com/301"
  [3]=>
  string(17) "Connection: close"
  [4]=>
  string(0) ""
  [5]=>
  string(0) ""
}

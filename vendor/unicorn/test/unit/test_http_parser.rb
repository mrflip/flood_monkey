# -*- encoding: binary -*-

# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html
# for more information.

require 'test/test_helper'

include Unicorn

class HttpParserTest < Test::Unit::TestCase

  def test_parse_simple
    parser = HttpParser.new
    req = {}
    http = "GET / HTTP/1.1\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal '', http

    assert_equal 'HTTP/1.1', req['SERVER_PROTOCOL']
    assert_equal '/', req['REQUEST_PATH']
    assert_equal 'HTTP/1.1', req['HTTP_VERSION']
    assert_equal '/', req['REQUEST_URI']
    assert_equal 'GET', req['REQUEST_METHOD']
    assert_nil req['FRAGMENT']
    assert_equal '', req['QUERY_STRING']

    assert parser.keepalive?
    parser.reset
    req.clear

    http = "G"
    assert_nil parser.headers(req, http)
    assert_equal "G", http
    assert req.empty?

    # try parsing again to ensure we were reset correctly
    http = "GET /hello-world HTTP/1.1\r\n\r\n"
    assert parser.headers(req, http)

    assert_equal 'HTTP/1.1', req['SERVER_PROTOCOL']
    assert_equal '/hello-world', req['REQUEST_PATH']
    assert_equal 'HTTP/1.1', req['HTTP_VERSION']
    assert_equal '/hello-world', req['REQUEST_URI']
    assert_equal 'GET', req['REQUEST_METHOD']
    assert_nil req['FRAGMENT']
    assert_equal '', req['QUERY_STRING']
    assert_equal '', http
    assert parser.keepalive?
  end

  def test_connection_close_no_ka
    parser = HttpParser.new
    req = {}
    tmp = "GET / HTTP/1.1\r\nConnection: close\r\n\r\n"
    assert_equal req.object_id, parser.headers(req, tmp).object_id
    assert_equal "GET", req['REQUEST_METHOD']
    assert ! parser.keepalive?
  end

  def test_connection_keep_alive_ka
    parser = HttpParser.new
    req = {}
    tmp = "HEAD / HTTP/1.1\r\nConnection: keep-alive\r\n\r\n"
    assert_equal req.object_id, parser.headers(req, tmp).object_id
    assert parser.keepalive?
  end

  def test_connection_keep_alive_ka_bad_method
    parser = HttpParser.new
    req = {}
    tmp = "POST / HTTP/1.1\r\nConnection: keep-alive\r\n\r\n"
    assert_equal req.object_id, parser.headers(req, tmp).object_id
    assert ! parser.keepalive?
  end

  def test_connection_keep_alive_ka_bad_version
    parser = HttpParser.new
    req = {}
    tmp = "GET / HTTP/1.0\r\nConnection: keep-alive\r\n\r\n"
    assert_equal req.object_id, parser.headers(req, tmp).object_id
    assert parser.keepalive?
  end

  def test_parse_server_host_default_port
    parser = HttpParser.new
    req = {}
    tmp = "GET / HTTP/1.1\r\nHost: foo\r\n\r\n"
    assert_equal req, parser.headers(req, tmp)
    assert_equal 'foo', req['SERVER_NAME']
    assert_equal '80', req['SERVER_PORT']
    assert_equal '', tmp
    assert parser.keepalive?
  end

  def test_parse_server_host_alt_port
    parser = HttpParser.new
    req = {}
    tmp = "GET / HTTP/1.1\r\nHost: foo:999\r\n\r\n"
    assert_equal req, parser.headers(req, tmp)
    assert_equal 'foo', req['SERVER_NAME']
    assert_equal '999', req['SERVER_PORT']
    assert_equal '', tmp
    assert parser.keepalive?
  end

  def test_parse_server_host_empty_port
    parser = HttpParser.new
    req = {}
    tmp = "GET / HTTP/1.1\r\nHost: foo:\r\n\r\n"
    assert_equal req, parser.headers(req, tmp)
    assert_equal 'foo', req['SERVER_NAME']
    assert_equal '80', req['SERVER_PORT']
    assert_equal '', tmp
    assert parser.keepalive?
  end

  def test_parse_server_host_xfp_https
    parser = HttpParser.new
    req = {}
    tmp = "GET / HTTP/1.1\r\nHost: foo:\r\n" \
          "X-Forwarded-Proto: https\r\n\r\n"
    assert_equal req, parser.headers(req, tmp)
    assert_equal 'foo', req['SERVER_NAME']
    assert_equal '443', req['SERVER_PORT']
    assert_equal '', tmp
    assert parser.keepalive?
  end

  def test_parse_strange_headers
    parser = HttpParser.new
    req = {}
    should_be_good = "GET / HTTP/1.1\r\naaaaaaaaaaaaa:++++++++++\r\n\r\n"
    assert_equal req, parser.headers(req, should_be_good)
    assert_equal '', should_be_good
    assert parser.keepalive?
  end

  # legacy test case from Mongrel that we never supported before...
  # I still consider Pound irrelevant, unfortunately stupid clients that
  # send extremely big headers do exist and they've managed to find Unicorn...
  def test_nasty_pound_header
    parser = HttpParser.new
    nasty_pound_header = "GET / HTTP/1.1\r\nX-SSL-Bullshit:   -----BEGIN CERTIFICATE-----\r\n\tMIIFbTCCBFWgAwIBAgICH4cwDQYJKoZIhvcNAQEFBQAwcDELMAkGA1UEBhMCVUsx\r\n\tETAPBgNVBAoTCGVTY2llbmNlMRIwEAYDVQQLEwlBdXRob3JpdHkxCzAJBgNVBAMT\r\n\tAkNBMS0wKwYJKoZIhvcNAQkBFh5jYS1vcGVyYXRvckBncmlkLXN1cHBvcnQuYWMu\r\n\tdWswHhcNMDYwNzI3MTQxMzI4WhcNMDcwNzI3MTQxMzI4WjBbMQswCQYDVQQGEwJV\r\n\tSzERMA8GA1UEChMIZVNjaWVuY2UxEzARBgNVBAsTCk1hbmNoZXN0ZXIxCzAJBgNV\r\n\tBAcTmrsogriqMWLAk1DMRcwFQYDVQQDEw5taWNoYWVsIHBhcmQYJKoZIhvcNAQEB\r\n\tBQADggEPADCCAQoCggEBANPEQBgl1IaKdSS1TbhF3hEXSl72G9J+WC/1R64fAcEF\r\n\tW51rEyFYiIeZGx/BVzwXbeBoNUK41OK65sxGuflMo5gLflbwJtHBRIEKAfVVp3YR\r\n\tgW7cMA/s/XKgL1GEC7rQw8lIZT8RApukCGqOVHSi/F1SiFlPDxuDfmdiNzL31+sL\r\n\t0iwHDdNkGjy5pyBSB8Y79dsSJtCW/iaLB0/n8Sj7HgvvZJ7x0fr+RQjYOUUfrePP\r\n\tu2MSpFyf+9BbC/aXgaZuiCvSR+8Snv3xApQY+fULK/xY8h8Ua51iXoQ5jrgu2SqR\r\n\twgA7BUi3G8LFzMBl8FRCDYGUDy7M6QaHXx1ZWIPWNKsCAwEAAaOCAiQwggIgMAwG\r\n\tA1UdEwEB/wQCMAAwEQYJYIZIAYb4QgEBBAQDAgWgMA4GA1UdDwEB/wQEAwID6DAs\r\n\tBglghkgBhvhCAQ0EHxYdVUsgZS1TY2llbmNlIFVzZXIgQ2VydGlmaWNhdGUwHQYD\r\n\tVR0OBBYEFDTt/sf9PeMaZDHkUIldrDYMNTBZMIGaBgNVHSMEgZIwgY+AFAI4qxGj\r\n\tloCLDdMVKwiljjDastqooXSkcjBwMQswCQYDVQQGEwJVSzERMA8GA1UEChMIZVNj\r\n\taWVuY2UxEjAQBgNVBAsTCUF1dGhvcml0eTELMAkGA1UEAxMCQ0ExLTArBgkqhkiG\r\n\t9w0BCQEWHmNhLW9wZXJhdG9yQGdyaWQtc3VwcG9ydC5hYy51a4IBADApBgNVHRIE\r\n\tIjAggR5jYS1vcGVyYXRvckBncmlkLXN1cHBvcnQuYWMudWswGQYDVR0gBBIwEDAO\r\n\tBgwrBgEEAdkvAQEBAQYwPQYJYIZIAYb4QgEEBDAWLmh0dHA6Ly9jYS5ncmlkLXN1\r\n\tcHBvcnQuYWMudmT4sopwqlBWsvcHViL2NybC9jYWNybC5jcmwwPQYJYIZIAYb4QgEDBDAWLmh0\r\n\tdHA6Ly9jYS5ncmlkLXN1cHBvcnQuYWMudWsvcHViL2NybC9jYWNybC5jcmwwPwYD\r\n\tVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NhLmdyaWQt5hYy51ay9wdWIv\r\n\tY3JsL2NhY3JsLmNybDANBgkqhkiG9w0BAQUFAAOCAQEAS/U4iiooBENGW/Hwmmd3\r\n\tXCy6Zrt08YjKCzGNjorT98g8uGsqYjSxv/hmi0qlnlHs+k/3Iobc3LjS5AMYr5L8\r\n\tUO7OSkgFFlLHQyC9JzPfmLCAugvzEbyv4Olnsr8hbxF1MbKZoQxUZtMVu29wjfXk\r\n\thTeApBv7eaKCWpSp7MCbvgzm74izKhu3vlDk9w6qVrxePfGgpKPqfHiOoGhFnbTK\r\n\twTC6o2xq5y0qZ03JonF7OJspEd3I5zKY3E+ov7/ZhW6DqT8UFvsAdjvQbXyhV8Eu\r\n\tYhixw1aKEPzNjNowuIseVogKOLXxWI5vAi5HgXdS0/ES5gDGsABo4fqovUKlgop3\r\n\tRA==\r\n\t-----END CERTIFICATE-----\r\n\r\n"
    req = {}
    buf = nasty_pound_header.dup

    assert nasty_pound_header =~ /(-----BEGIN .*--END CERTIFICATE-----)/m
    expect = $1.dup
    expect.gsub!(/\r\n\t/, ' ')
    assert_equal req, parser.headers(req, buf)
    assert_equal '', buf
    assert_equal expect, req['HTTP_X_SSL_BULLSHIT']
  end

  def test_continuation_eats_leading_spaces
    parser = HttpParser.new
    header = "GET / HTTP/1.1\r\n" \
             "X-ASDF:      \r\n" \
             "\t\r\n" \
             "    \r\n" \
             "  ASDF\r\n\r\n"
    req = {}
    assert_equal req, parser.headers(req, header)
    assert_equal '', header
    assert_equal 'ASDF', req['HTTP_X_ASDF']
  end

  def test_continuation_eats_scattered_leading_spaces
    parser = HttpParser.new
    header = "GET / HTTP/1.1\r\n" \
             "X-ASDF:   hi\r\n" \
             "    y\r\n" \
             "\t\r\n" \
             "       x\r\n" \
             "  ASDF\r\n\r\n"
    req = {}
    assert_equal req, parser.headers(req, header)
    assert_equal '', header
    assert_equal 'hi y x ASDF', req['HTTP_X_ASDF']
  end

  def test_continuation_with_absolute_uri_and_ignored_host_header
    parser = HttpParser.new
    header = "GET http://example.com/ HTTP/1.1\r\n" \
             "Host: \r\n" \
             "    YHBT.net\r\n" \
             "\r\n"
    req = {}
    assert_equal req, parser.headers(req, header)
    assert_equal 'example.com', req['HTTP_HOST']
  end

  # this may seem to be testing more of an implementation detail, but
  # it also helps ensure we're safe in the presence of multiple parsers
  # in case we ever go multithreaded/evented...
  def test_resumable_continuations
    nr = 1000
    req = {}
    header = "GET / HTTP/1.1\r\n" \
             "X-ASDF:      \r\n" \
             "  hello\r\n"
    tmp = []
    nr.times { |i|
      parser = HttpParser.new
      assert parser.headers(req, "#{header} #{i}\r\n").nil?
      asdf = req['HTTP_X_ASDF']
      assert_equal "hello #{i}", asdf
      tmp << [ parser, asdf ]
      req.clear
    }
    tmp.each_with_index { |(parser, asdf), i|
      assert_equal req, parser.headers(req, "#{header} #{i}\r\n .\r\n\r\n")
      assert_equal "hello #{i} .", asdf
    }
  end

  def test_invalid_continuation
    parser = HttpParser.new
    header = "GET / HTTP/1.1\r\n" \
             "    y\r\n" \
             "Host: hello\r\n" \
             "\r\n"
    req = {}
    assert_raises(HttpParserError) { parser.headers(req, header) }
  end

  def test_parse_ie6_urls
    %w(/some/random/path"
       /some/random/path>
       /some/random/path<
       /we/love/you/ie6?q=<"">
       /url?<="&>="
       /mal"formed"?
    ).each do |path|
      parser = HttpParser.new
      req = {}
      sorta_safe = %(GET #{path} HTTP/1.1\r\n\r\n)
      assert_equal req, parser.headers(req, sorta_safe)
      assert_equal path, req['REQUEST_URI']
      assert_equal '', sorta_safe
      assert parser.keepalive?
    end
  end
  
  def test_parse_error
    parser = HttpParser.new
    req = {}
    bad_http = "GET / SsUTF/1.1"

    assert_raises(HttpParserError) { parser.headers(req, bad_http) }

    # make sure we can recover
    parser.reset
    req.clear
    assert_equal req, parser.headers(req, "GET / HTTP/1.0\r\n\r\n")
    assert ! parser.keepalive?
  end

  def test_piecemeal
    parser = HttpParser.new
    req = {}
    http = "GET"
    assert_nil parser.headers(req, http)
    assert_nil parser.headers(req, http)
    assert_nil parser.headers(req, http << " / HTTP/1.0")
    assert_equal '/', req['REQUEST_PATH']
    assert_equal '/', req['REQUEST_URI']
    assert_equal 'GET', req['REQUEST_METHOD']
    assert_nil parser.headers(req, http << "\r\n")
    assert_equal 'HTTP/1.0', req['HTTP_VERSION']
    assert_nil parser.headers(req, http << "\r")
    assert_equal req, parser.headers(req, http << "\n")
    assert_equal 'HTTP/1.0', req['SERVER_PROTOCOL']
    assert_nil req['FRAGMENT']
    assert_equal '', req['QUERY_STRING']
    assert_equal "", http
    assert ! parser.keepalive?
  end

  # not common, but underscores do appear in practice
  def test_absolute_uri_underscores
    parser = HttpParser.new
    req = {}
    http = "GET http://under_score.example.com/foo?q=bar HTTP/1.0\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal 'http', req['rack.url_scheme']
    assert_equal '/foo?q=bar', req['REQUEST_URI']
    assert_equal '/foo', req['REQUEST_PATH']
    assert_equal 'q=bar', req['QUERY_STRING']

    assert_equal 'under_score.example.com', req['HTTP_HOST']
    assert_equal 'under_score.example.com', req['SERVER_NAME']
    assert_equal '80', req['SERVER_PORT']
    assert_equal "", http
    assert ! parser.keepalive?
  end

  # some dumb clients add users because they're stupid
  def test_absolute_uri_w_user
    parser = HttpParser.new
    req = {}
    http = "GET http://user%20space@example.com/foo?q=bar HTTP/1.0\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal 'http', req['rack.url_scheme']
    assert_equal '/foo?q=bar', req['REQUEST_URI']
    assert_equal '/foo', req['REQUEST_PATH']
    assert_equal 'q=bar', req['QUERY_STRING']

    assert_equal 'example.com', req['HTTP_HOST']
    assert_equal 'example.com', req['SERVER_NAME']
    assert_equal '80', req['SERVER_PORT']
    assert_equal "", http
    assert ! parser.keepalive?
  end

  # since Mongrel supported anything URI.parse supported, we're stuck
  # supporting everything URI.parse supports
  def test_absolute_uri_uri_parse
    "#{URI::REGEXP::PATTERN::UNRESERVED};:&=+$,".split(//).each do |char|
      parser = HttpParser.new
      req = {}
      http = "GET http://#{char}@example.com/ HTTP/1.0\r\n\r\n"
      assert_equal req, parser.headers(req, http)
      assert_equal 'http', req['rack.url_scheme']
      assert_equal '/', req['REQUEST_URI']
      assert_equal '/', req['REQUEST_PATH']
      assert_equal '', req['QUERY_STRING']

      assert_equal 'example.com', req['HTTP_HOST']
      assert_equal 'example.com', req['SERVER_NAME']
      assert_equal '80', req['SERVER_PORT']
      assert_equal "", http
      assert ! parser.keepalive?
    end
  end

  def test_absolute_uri
    parser = HttpParser.new
    req = {}
    http = "GET http://example.com/foo?q=bar HTTP/1.0\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal 'http', req['rack.url_scheme']
    assert_equal '/foo?q=bar', req['REQUEST_URI']
    assert_equal '/foo', req['REQUEST_PATH']
    assert_equal 'q=bar', req['QUERY_STRING']

    assert_equal 'example.com', req['HTTP_HOST']
    assert_equal 'example.com', req['SERVER_NAME']
    assert_equal '80', req['SERVER_PORT']
    assert_equal "", http
    assert ! parser.keepalive?
  end

  # X-Forwarded-Proto is not in rfc2616, absolute URIs are, however...
  def test_absolute_uri_https
    parser = HttpParser.new
    req = {}
    http = "GET https://example.com/foo?q=bar HTTP/1.1\r\n" \
           "X-Forwarded-Proto: http\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal 'https', req['rack.url_scheme']
    assert_equal '/foo?q=bar', req['REQUEST_URI']
    assert_equal '/foo', req['REQUEST_PATH']
    assert_equal 'q=bar', req['QUERY_STRING']

    assert_equal 'example.com', req['HTTP_HOST']
    assert_equal 'example.com', req['SERVER_NAME']
    assert_equal '443', req['SERVER_PORT']
    assert_equal "", http
    assert parser.keepalive?
  end

  # Host: header should be ignored for absolute URIs
  def test_absolute_uri_with_port
    parser = HttpParser.new
    req = {}
    http = "GET http://example.com:8080/foo?q=bar HTTP/1.2\r\n" \
           "Host: bad.example.com\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal 'http', req['rack.url_scheme']
    assert_equal '/foo?q=bar', req['REQUEST_URI']
    assert_equal '/foo', req['REQUEST_PATH']
    assert_equal 'q=bar', req['QUERY_STRING']

    assert_equal 'example.com:8080', req['HTTP_HOST']
    assert_equal 'example.com', req['SERVER_NAME']
    assert_equal '8080', req['SERVER_PORT']
    assert_equal "", http
    assert ! parser.keepalive? # TODO: read HTTP/1.2 when it's final
  end

  def test_absolute_uri_with_empty_port
    parser = HttpParser.new
    req = {}
    http = "GET https://example.com:/foo?q=bar HTTP/1.1\r\n" \
           "Host: bad.example.com\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal 'https', req['rack.url_scheme']
    assert_equal '/foo?q=bar', req['REQUEST_URI']
    assert_equal '/foo', req['REQUEST_PATH']
    assert_equal 'q=bar', req['QUERY_STRING']

    assert_equal 'example.com:', req['HTTP_HOST']
    assert_equal 'example.com', req['SERVER_NAME']
    assert_equal '443', req['SERVER_PORT']
    assert_equal "", http
    assert parser.keepalive? # TODO: read HTTP/1.2 when it's final
  end

  def test_put_body_oneshot
    parser = HttpParser.new
    req = {}
    http = "PUT / HTTP/1.0\r\nContent-Length: 5\r\n\r\nabcde"
    assert_equal req, parser.headers(req, http)
    assert_equal '/', req['REQUEST_PATH']
    assert_equal '/', req['REQUEST_URI']
    assert_equal 'PUT', req['REQUEST_METHOD']
    assert_equal 'HTTP/1.0', req['HTTP_VERSION']
    assert_equal 'HTTP/1.0', req['SERVER_PROTOCOL']
    assert_equal "abcde", http
    assert ! parser.keepalive? # TODO: read HTTP/1.2 when it's final
  end

  def test_put_body_later
    parser = HttpParser.new
    req = {}
    http = "PUT /l HTTP/1.0\r\nContent-Length: 5\r\n\r\n"
    assert_equal req, parser.headers(req, http)
    assert_equal '/l', req['REQUEST_PATH']
    assert_equal '/l', req['REQUEST_URI']
    assert_equal 'PUT', req['REQUEST_METHOD']
    assert_equal 'HTTP/1.0', req['HTTP_VERSION']
    assert_equal 'HTTP/1.0', req['SERVER_PROTOCOL']
    assert_equal "", http
    assert ! parser.keepalive? # TODO: read HTTP/1.2 when it's final
  end

  def test_unknown_methods
    %w(GETT HEADR XGET XHEAD).each { |m|
      parser = HttpParser.new
      req = {}
      s = "#{m} /forums/1/topics/2375?page=1#posts-17408 HTTP/1.1\r\n\r\n"
      ok = false
      assert_nothing_raised do
        ok = parser.headers(req, s)
      end
      assert ok
      assert_equal '/forums/1/topics/2375?page=1', req['REQUEST_URI']
      assert_equal 'posts-17408', req['FRAGMENT']
      assert_equal 'page=1', req['QUERY_STRING']
      assert_equal "", s
      assert_equal m, req['REQUEST_METHOD']
      assert ! parser.keepalive? # TODO: read HTTP/1.2 when it's final
    }
  end

  def test_fragment_in_uri
    parser = HttpParser.new
    req = {}
    get = "GET /forums/1/topics/2375?page=1#posts-17408 HTTP/1.1\r\n\r\n"
    ok = false
    assert_nothing_raised do
      ok = parser.headers(req, get)
    end
    assert ok
    assert_equal '/forums/1/topics/2375?page=1', req['REQUEST_URI']
    assert_equal 'posts-17408', req['FRAGMENT']
    assert_equal 'page=1', req['QUERY_STRING']
    assert_equal '', get
    assert parser.keepalive?
  end

  # lame random garbage maker
  def rand_data(min, max, readable=true)
    count = min + ((rand(max)+1) *10).to_i
    res = count.to_s + "/"
    
    if readable
      res << Digest::SHA1.hexdigest(rand(count * 100).to_s) * (count / 40)
    else
      res << Digest::SHA1.digest(rand(count * 100).to_s) * (count / 20)
    end

    return res
  end
  

  def test_horrible_queries
    parser = HttpParser.new

    # then that large header names are caught
    10.times do |c|
      get = "GET /#{rand_data(10,120)} HTTP/1.1\r\nX-#{rand_data(1024, 1024+(c*1024))}: Test\r\n\r\n"
      assert_raises Unicorn::HttpParserError do
        parser.headers({}, get)
        parser.reset
      end
    end

    # then that large mangled field values are caught
    10.times do |c|
      get = "GET /#{rand_data(10,120)} HTTP/1.1\r\nX-Test: #{rand_data(1024, 1024+(c*1024), false)}\r\n\r\n"
      assert_raises Unicorn::HttpParserError do
        parser.headers({}, get)
        parser.reset
      end
    end

    # then large headers are rejected too
    get = "GET /#{rand_data(10,120)} HTTP/1.1\r\n"
    get << "X-Test: test\r\n" * (80 * 1024)
    assert_raises Unicorn::HttpParserError do
      parser.headers({}, get)
      parser.reset
    end

    # finally just that random garbage gets blocked all the time
    10.times do |c|
      get = "GET #{rand_data(1024, 1024+(c*1024), false)} #{rand_data(1024, 1024+(c*1024), false)}\r\n\r\n"
      assert_raises Unicorn::HttpParserError do
        parser.headers({}, get)
        parser.reset
      end
    end

  end
end


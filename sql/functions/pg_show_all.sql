create or replace function cgi.pg_show_all() returns void as $$
declare
begin
  -- Tell the cgi app that the response needs to be extracted from the
  -- cgi_response_text table.
  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values('response', 'output', 0, 'text');

  -- Tell the cgi app what the HTTP status line is.
  perform cgi.set_http_status(200, 'OK');

  -- Create Content-type header
  perform cgi.set_content_type('text/plain');

  -- Output some text content.
  perform cgi.println('t_cgi_param table content:');
  perform cgi.println('--------------------------');
  perform cgi.new_line();
end;
$$ language plpgsql;

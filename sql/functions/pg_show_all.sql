create or replace function cgi.pg_show_all() returns void as $$
declare
  rec record;
begin
  -- Tell the cgi app that the response needs to be extracted from the
  -- cgi_response_text table.
  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values('response', 'output', 0, 'text');

  -- Tell the cgi app what the HTTP status line is.
  perform cgi.set_http_status(200, 'OK');

  -- Create Content-type header
  perform cgi.set_content_type('text/plain');

  -- Output t_cgi_param table content
  perform cgi.println('t_cgi_param table content:');
  perform cgi.println('--------------------------');
  perform cgi.new_line();

  for rec in select f_type, f_name, f_index, f_value
    from t_cgi_param order by f_type, f_name, f_index
  loop
    perform cgi.println(rec.f_type || ', ' || rec.f_name || '[' || rec.f_index || ']: ' || rec.f_value);
  end loop;
end;
$$ language plpgsql;

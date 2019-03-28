create or replace function cgi.pg_show_all(v_no_headers bool default false) returns void as $$
declare
  rec record;
begin
  if not v_no_headers then
    -- Tell the cgi app that the response needs to be extracted from the
    -- cgi_response_text table.
    perform cgi.set_cgi_param('response', 'output', 'text');

    -- Tell the cgi app what the HTTP status line is.
    perform cgi.set_http_status(200, 'OK');

    -- Create Content-type header
    perform cgi.set_content_type('text/plain');
  end if;

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

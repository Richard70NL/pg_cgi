create or replace function cgi.handle_request() returns void as $$
declare
  pinfo t_cgi_param.f_value%TYPE := cgi.get_env_var('PATH_INFO');
begin
  -- Update path_info on the ealier created request log record
  if pinfo is not null then
    update cgi.t_request_log set f_path_info = pinfo
      where f_rid = cgi.get_request_id();
  end if;

  -- Tell the cgi app that the response needs to be extracted from the
  -- cgi_response_text table.
  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values('response', 'output', 0, 'text');

  -- Tell the cgi app what the HTTP status line is.
  perform cgi.set_http_status(200, 'OK');

  -- Create Content-type header
  perform cgi.set_content_type('text/plain');

  -- Output some text content.
  perform cgi.print('Postgres says:');
  perform cgi.print(' Hello, World!');
  perform cgi.new_line();
  perform cgi.println('----------------------------');
  perform cgi.println('Btw, PATH_INFO was: ' || pinfo);
end;
$$ language plpgsql;

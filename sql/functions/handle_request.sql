create or replace function cgi.handle_request() returns void as $$
declare
  public_schema t_cgi_param.f_value%type := cgi.get_env_var('pgCGI_public_schema');
  path_info t_cgi_param.f_value%type := cgi.get_env_var('PATH_INFO');
  public_function text := cgi.path_info_to_public_function(path_info);
  full_function_name text;
begin
  -- Update path_info on the ealier created request log record
  if path_info is not null then
    update cgi.t_request_log set f_path_info = path_info
      where f_rid = cgi.get_request_id();
  end if;

  -- Tell the cgi app that the response needs to be extracted from the
  -- cgi_response_text table.
  perform cgi.set_cgi_param('response', 'output', 'text');

  -- validate public schema
  if public_schema is null then
    raise exception 'pgCGI_public_schema has not been set!';
  end if;

  -- create and validate function name
  if not cgi.validate_identifier(public_schema) then
    raise exception '"%" is not a valid public_schema!', public_schema;
  end if;
  if not cgi.validate_identifier(public_function) then
    raise exception '"%" is not a valid public_function!', public_function;
  end if;
  full_function_name := public_schema || '.' || public_function || '()';
  select full_function_name::regprocedure into full_function_name;

  -- execute
  execute 'select ' || full_function_name;
end;
$$ language plpgsql;

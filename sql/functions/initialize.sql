create or replace function cgi.initialize() returns void as $$
declare
  new_rid cgi.t_request_log.f_rid%type default null;
begin
  -- create a request log record
  insert into cgi.t_request_log(f_init) values(now()) returning f_rid into new_rid;

  -- create all temporary (session) tables
  perform cgi.create_temp_tables();

  -- insert the new request ID for later use
  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values ('request', 'id', 0, new_rid);
end;
$$ language plpgsql;

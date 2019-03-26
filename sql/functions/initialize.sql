create or replace function cgi.initialize() returns void as $$
declare
  new_rid cgi.request_log.rid%type default null;
begin
  -- create a request log record
  insert into cgi.request_log(init) values(now()) returning rid into new_rid;

  -- create all temporary (session) tables
  perform cgi.create_temp_tables();

  -- insert the new request ID for later use
  insert into cgi_param(type, name, index, value)
    values ('request', 'id', 0, new_rid);
end;
$$ language plpgsql;

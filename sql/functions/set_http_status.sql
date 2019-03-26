create or replace function cgi.set_http_status(status_code integer, status_message text) returns void as $$
declare
begin
  insert into cgi_param(type, name, index, value)
    values('response', 'status', 0, status_code || ' ' || status_message);
end;
$$ language plpgsql;

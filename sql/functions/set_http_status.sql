create or replace function cgi.set_http_status(status_code integer, status_message text) returns void as $$
declare
begin
  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values('response', 'status', 0, status_code || ' ' || status_message);
end;
$$ language plpgsql;

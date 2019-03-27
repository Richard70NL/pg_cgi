create or replace function cgi.set_http_status(status_code integer, status_message text) returns void as $$
declare
begin
  perform cgi.set_cgi_param('response', 'status', status_code || ' ' || status_message);
end;
$$ language plpgsql;

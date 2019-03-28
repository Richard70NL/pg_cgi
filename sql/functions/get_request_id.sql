create or replace function cgi.get_request_id()
  returns cgi.t_request_log.f_rid%type as $$
declare
begin
  return cgi.get_cgi_param_value('request', 'id');
end;
$$ language plpgsql;

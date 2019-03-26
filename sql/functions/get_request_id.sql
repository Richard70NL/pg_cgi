create or replace function cgi.get_request_id()
  returns cgi.t_request_log.f_rid%type as $$
declare
  val t_cgi_param.f_value%TYPE := null;
begin
  -- Retrieve the request ID that was inserted during the cgi.initialize
  -- function call.
  select f_value into val from t_cgi_param
    where f_type = 'request' and f_name = 'id' and f_index = 0;

  -- Return it or NULL if not existing.
  return val;
end;
$$ language plpgsql;

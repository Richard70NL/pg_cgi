create or replace function cgi.get_request_id() returns cgi.request_log.rid%type  as $$
declare
  val cgi_param.value%TYPE := null;
begin
  -- Retrieve the request ID that was inserted during the cgi.initialize
  -- function call.
  select value into val from cgi_param
    where type = 'request' and name = 'id' and index = 0;

  -- Return it or NULL if not existing.
  return val;
end;
$$ language plpgsql;

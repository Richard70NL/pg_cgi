create or replace function cgi.finalize() returns void as $$
declare
begin
  -- No need to drop the temporary tables, they will be dropped at the
  -- end of the session.

  -- Update earlier created request log record.
  update cgi.t_request_log set f_final = now() where f_rid = cgi.get_request_id();
end;
$$ language plpgsql;

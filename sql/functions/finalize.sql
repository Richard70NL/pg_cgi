create or replace function cgi.finalize() returns void as $$
declare
begin
  -- No need to drop the temporary tables, they will be dropped at the
  -- end of the session.

  -- Update earlier created request log record.
  update cgi.request_log set final = now() where rid = cgi.get_request_id();
end;
$$ language plpgsql;

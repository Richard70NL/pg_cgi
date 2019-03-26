create or replace function cgi.new_line() returns void as $$
declare
begin
  insert into cgi_response_text(content, new_line)
    values(null, true);
end;
$$ language plpgsql;

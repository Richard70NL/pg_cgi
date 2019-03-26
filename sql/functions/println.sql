create or replace function cgi.println(content text) returns void as $$
declare
begin
  insert into cgi_response_text(content, new_line)
    values(content, true);
end;
$$ language plpgsql;

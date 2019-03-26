create or replace function cgi.print(content text) returns void as $$
declare
begin
  insert into cgi_response_text(content, new_line)
    values(content, false);
end;
$$ language plpgsql;

create or replace function cgi.print(content text) returns void as $$
declare
begin
  insert into t_cgi_response_text(f_content, f_new_line)
    values(content, false);
end;
$$ language plpgsql;

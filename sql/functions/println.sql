create or replace function cgi.println(content text) returns void as $$
declare
begin
  insert into t_cgi_response_text(f_content, f_new_line)
    values(content, true);
end;
$$ language plpgsql;

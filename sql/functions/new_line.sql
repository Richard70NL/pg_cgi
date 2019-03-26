create or replace function cgi.new_line() returns void as $$
declare
begin
  insert into t_cgi_response_text(f_content, f_new_line)
    values(null, true);
end;
$$ language plpgsql;

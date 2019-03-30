-------------------------------------------------------------------------------

create or replace function cgi.println(content text) returns void as $$
declare
begin
  insert into t_cgi_response_text(f_content, f_new_line)
    values(content, true);
end;
$$ language plpgsql;

-------------------------------------------------------------------------------

create or replace function cgi.println(content text, variadic var anyarray) returns void as $$
declare
begin
  perform cgi.println(format(content, variadic var));
end;
$$ language plpgsql;

-------------------------------------------------------------------------------

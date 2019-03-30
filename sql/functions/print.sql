-------------------------------------------------------------------------------

create or replace function cgi.print(content text) returns void as $$
declare
begin
  insert into t_cgi_response_text(f_content, f_new_line)
    values(content, false);
end;
$$ language plpgsql;

-------------------------------------------------------------------------------

create or replace function cgi.print(content text, variadic var anyarray) returns void as $$
declare
begin
  perform cgi.print(format(content, variadic var));
end;
$$ language plpgsql;

-------------------------------------------------------------------------------

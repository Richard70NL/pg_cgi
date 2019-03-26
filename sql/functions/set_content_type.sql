create or replace function cgi.set_content_type(content_type text) returns void as $$
declare
begin
  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values('response.header', 'Content-type', 0, content_type);
end;
$$ language plpgsql;

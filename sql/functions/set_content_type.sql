create or replace function cgi.set_content_type(content_type text) returns void as $$
declare
begin
  insert into cgi_param(type, name, index, value)
    values('response.header', 'Content-type', 0, content_type);
end;
$$ language plpgsql;

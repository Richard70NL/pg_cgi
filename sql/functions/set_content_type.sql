create or replace function cgi.set_content_type(content_type t_cgi_param.f_value%type) returns void as $$
declare
begin
  perform cgi.set_cgi_param('response.header', 'Content-type', content_type);
end;
$$ language plpgsql;

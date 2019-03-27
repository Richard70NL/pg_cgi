create or replace function cgi.set_cgi_param(
  type t_cgi_param.f_type%type,
  name t_cgi_param.f_name%type,
  value t_cgi_param.f_value%type) returns void as $$
declare
begin
  update t_cgi_param set f_value = value
    where f_type = type and f_name = name and f_index = 0;

  if not found then
    insert into t_cgi_param(f_type, f_name, f_index, f_value)
      values(type, name, 0, value);
  end if;
end;
$$ language plpgsql;

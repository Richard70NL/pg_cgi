create or replace function cgi.insert_cgi_param(
  type t_cgi_param.f_type%type,
  name t_cgi_param.f_name%type,
  value t_cgi_param.f_value%type) returns void as $$
declare
  index t_cgi_param.f_index%type := 0;
begin
  select f_index into index from t_cgi_param
    where f_type = type and f_name = name;

  if found then
    index := index + 1;
  else
    index := 0;
  end if;

  insert into t_cgi_param(f_type, f_name, f_index, f_value)
    values(type, name, index, value);
end;
$$ language plpgsql;

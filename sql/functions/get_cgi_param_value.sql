create or replace function cgi.get_cgi_param_value(
    v_type t_cgi_param.f_type%type,
    v_name t_cgi_param.f_name%type
  ) returns t_cgi_param.f_value%type as $$
declare
  v_value t_cgi_param.f_value%type := null;
begin
  select f_value into v_value from t_cgi_param
    where f_type = v_type and f_name = v_name and f_index = 0;

  return v_value;
end;
$$ language plpgsql;

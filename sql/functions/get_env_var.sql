create or replace function cgi.get_env_var(v_name t_cgi_param.f_name%type)
  returns t_cgi_param.f_value%type as $$
declare
begin
  return cgi.get_cgi_param_value('env', v_name);
end;
$$ language plpgsql;

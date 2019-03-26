create or replace function cgi.get_env_var(var_name t_cgi_param.f_name%TYPE)
  returns t_cgi_param.f_value%TYPE as $$
declare
  val t_cgi_param.f_value%TYPE := null;
begin
  -- Retrieve the environment variable value.
  select f_value into val from t_cgi_param
    where f_type = 'env' and f_name = var_name and f_index = 0;

  -- Return it. If not found then NULL will be returned.
  return val;
end;
$$ language plpgsql;

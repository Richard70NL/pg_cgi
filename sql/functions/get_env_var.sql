create or replace function cgi.get_env_var(var_name cgi_param.name%TYPE)
  returns cgi_param.value%TYPE as $$
declare
  val cgi_param.value%TYPE := null;
begin
  -- Retrieve the environment variable value.
  select value into val from cgi_param
    where type = 'env' and name = var_name and index = 0;

  -- Return it. If not found then NULL will be returned.
  return val;
end;
$$ language plpgsql;

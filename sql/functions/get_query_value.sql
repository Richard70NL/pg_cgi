create or replace function cgi.get_query_value(v_name t_cgi_param.f_name%type)
  returns t_cgi_param.f_value%type as $$
declare
begin
  return cgi.get_cgi_param_value('query', v_name);
end;
$$ language plpgsql;

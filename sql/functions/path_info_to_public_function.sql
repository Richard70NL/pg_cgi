create or replace function cgi.path_info_to_public_function(path_info text) returns text as $$
declare
  public_function text := 'home';
begin
  if path_info is null then
    public_function := 'home';
  elseif path_info = '/' then
    public_function := 'home';
  else
    public_function := split_part(trim(both '/ ' from path_info), '/', 1);
    if length(public_function) = 0 then
      public_function := 'home';
    end if;
  end if;

  return public_function;
end;
$$ language plpgsql;

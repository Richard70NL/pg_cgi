create or replace function cgi.validate_identifier(identifier text)
  returns boolean as $$
declare
  is_valid boolean;
begin
  select identifier ~ '^[a-zA-Z_][a-zA-Z0-9_]*$' into is_valid;

  return is_valid;
end;
$$ language plpgsql;

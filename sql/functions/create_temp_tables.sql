create or replace function cgi.create_temp_tables() returns void as $$
declare
begin
  -- This table is use to store most of the request data like:
  -- Env variables, query values, form values but also
  -- Response status and headers.
  create temporary table if not exists cgi_param
  (
    type text not null,
    name text not null,
    index integer not null,
    value text,
    constraint pk_cgi_param primary key (type, name, index)
  );

  -- This table is used for the actual text content.
  create temporary table if not exists cgi_response_text
  (
    index serial not null,
    content text,
    new_line boolean not null,
    constraint pk_cgi_response_text primary key (index)
  );
end;
$$ language plpgsql;

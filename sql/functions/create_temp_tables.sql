create or replace function cgi.create_temp_tables() returns void as $$
declare
begin
  -- This table is use to store most of the request data like:
  -- Env variables, query values, form values but also
  -- Response status and headers.
  create temporary table if not exists t_cgi_param
  (
    f_type text not null,
    f_name text not null,
    f_index integer not null,
    f_value text,
    constraint pk_cgi_param primary key (f_type, f_name, f_index)
  );

  -- This table is used for the actual text content.
  create temporary table if not exists t_cgi_response_text
  (
    f_index serial not null,
    f_content text,
    f_new_line boolean not null,
    constraint pk_cgi_response_text primary key (f_index)
  );
end;
$$ language plpgsql;

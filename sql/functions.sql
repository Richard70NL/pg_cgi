set client_min_messages to warning;

\i functions/create_temp_tables.sql

-- and run it to allow all other function to compile
select cgi.create_temp_tables();

\i functions/get_env_var.sql
\i functions/get_request_id.sql
\i functions/initialize.sql
\i functions/handle_request.sql
\i functions/finalize.sql
\i functions/set_http_status.sql
\i functions/set_content_type.sql
\i functions/print.sql;
\i functions/println.sql;
\i functions/new_line.sql;
\i functions/pg_show_all.sql;

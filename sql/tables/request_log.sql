create table cgi.t_request_log (
  f_rid bigserial not null,
  f_init timestamp,
  f_final timestamp,
  f_path_info text,
  constraint pk_request_log primary key (f_rid)
)

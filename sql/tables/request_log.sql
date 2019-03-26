create table cgi.request_log (
  rid bigserial not null,
  init timestamp,
  final timestamp,
  path_info text,
  constraint pk_request_log primary key (rid)
)

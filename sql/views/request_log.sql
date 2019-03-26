create or replace view cgi.v_request_log as
  select f_rid, f_init as start, f_final - f_init as f_duration, f_path_info
  from cgi.t_request_log
  order by f_rid desc;

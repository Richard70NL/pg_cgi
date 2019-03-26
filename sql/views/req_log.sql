create or replace view cgi.req_log as
  select rid, init as start, final - init as duration, path_info
  from cgi.request_log
  order by rid desc;

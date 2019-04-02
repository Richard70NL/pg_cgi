/************************************************************************************************/

#[cfg(feature = "debug_utils")]
mod debug_utils;

/************************************************************************************************/

use postgres::{Connection, TlsMode};
use std::{env, io, io::prelude::*, process::exit};
use url::form_urlencoded::parse;

/************************************************************************************************/

fn main() {
    #[cfg(feature = "debug_utils")]
    debug_utils::handle_debug_utils();

    match env::var("PATH_INFO") {
        Ok(path_info) => process_request(path_info),
        Err(_) => {
            let mut script_name =
                get_env_var("SCRIPT_NAME", "Script name could not be determined!");
            script_name.push_str("/");
            redirect_to(script_name);
        }
    }
}

/************************************************************************************************/

fn get_env_var(key: &str, error_message: &str) -> String {
    match env::var(key) {
        Ok(val) => val,
        Err(_) => {
            show_error(error_message, "get_env_var", "", true);
            String::new() // this will not be reached since show_error exits
        }
    }
}

/************************************************************************************************/

fn process_request(path_info: String) {
    if path_info == "/show_hello_world" {
        show_hello_world();
    } else {
        let connection_url = get_env_var(
            "pgCGI_connection_url",
            "Environment variable 'pgCGI_connection_url' is not set!",
        );

        match Connection::connect(connection_url, TlsMode::None) {
            Ok(conn) => process_request_db(conn),
            Err(e) => show_error(
                &e.to_string(),
                "process_request",
                "connect to postgresql",
                true,
            ),
        }
    }
}

/************************************************************************************************/

fn process_request_db(conn: Connection) {
    if let Err(e) = conn.execute("select cgi.initialize();", &[]) {
        show_error(&e.to_string(), "process_request_db", "cgi.initialize", true)
    }

    insert_env_variables(&conn);
    parse_query_string(&conn);
    parse_form_data(&conn);

    #[allow(unused_mut)]
    let mut do_handle_request = true;

    #[cfg(feature = "debug_utils")]
    {
        match env::var("PATH_INFO") {
            Ok(val) => {
                if val == "/pg_show_all" {
                    if let Err(e) = conn.execute("select cgi.pg_show_all();", &[]) {
                        show_error(
                            &e.to_string(),
                            "process_request_db",
                            "cgi.pg_show_all",
                            true,
                        )
                    };
                    do_handle_request = true;
                }
            }
            Err(_) => () // do nothing,
        }
    }

    if do_handle_request {
        if let Err(e) = conn.execute("select cgi.handle_request();", &[]) {
            show_error(
                &e.to_string(),
                "process_request_db",
                "cgi.handle_request",
                true,
            )
        }
    }

    output_response_content(&conn);

    if let Err(e) = conn.execute("select cgi.finalize();", &[]) {
        show_error(&e.to_string(), "process_request_db", "cgi.finalize", true)
    }
}

/************************************************************************************************/

fn insert_env_variables(conn: &Connection) {
    for (key, value) in env::vars() {
        if let Err(e) = conn.execute(
            "select cgi.insert_cgi_param('env', $1, $2);",
            &[&key, &value],
        ) {
            show_error(
                &e.to_string(),
                "insert_env_variables",
                "cgi.insert_cgi_param",
                true,
            )
        }
    }
}

/************************************************************************************************/

fn parse_query_string(conn: &Connection) {
    if let Ok(query) = env::var("QUERY_STRING") {
        for pair in parse(query.as_bytes()) {
            let key = pair.0.to_string();
            let value = pair.1.to_string();

            if let Err(e) = conn.execute(
                "select cgi.insert_cgi_param('query', $1, $2);",
                &[&key, &value],
            ) {
                show_error(
                    &e.to_string(),
                    "parse_query_string",
                    "cgi.insert_cgi_param",
                    true,
                )
            }
        }
    }
}

/************************************************************************************************/

fn parse_form_data(conn: &Connection) {
    if let Ok(content_type) = env::var("CONTENT_TYPE") {
        if content_type == "application/x-www-form-urlencoded" {
            let mut stdin = io::stdin();
            let mut buffer = String::new();
            let _res = stdin.read_to_string(&mut buffer);

            for pair in parse(buffer.as_bytes()) {
                let key = pair.0.to_string();
                let value = pair.1.to_string();

                if let Err(e) = conn.execute(
                    "select cgi.insert_cgi_param('form', $1, $2);",
                    &[&key, &value],
                ) {
                    show_error(
                        &e.to_string(),
                        "parse_form_data",
                        "cgi.insert_cgi_param",
                        true,
                    )
                }
            }
        }
    }
}

/************************************************************************************************/

fn get_cgi_param(conn: &Connection, ptype: &str, name: &str) -> Option<String> {
    match conn.query(
        "select f_value from t_cgi_param where f_type = $1 and f_name = $2 and f_index = 0",
        &[&ptype, &name],
    ) {
        Err(e) => {
            show_error(
                &e.to_string(),
                "get_cgi_param",
                "select from t_cgi_param",
                true,
            );
            None
        }
        Ok(rows) => {
            if rows.is_empty() {
                None
            } else {
                let value: String = rows.get(0).get("f_value");
                Some(value)
            }
        }
    }
}

/************************************************************************************************/

fn output_response_content(conn: &Connection) {
    match get_cgi_param(&conn, "response", "output") {
        Some(response_output) => {
            if response_output == "text" {
                match get_cgi_param(&conn, "response", "status") {
                    Some(status) => println!("Status: {}", status),
                    None => println!("Status: 200 OK"),
                }

                output_response_headers(&conn);
                println!();

                output_response_text(&conn);
            } else {
                show_error(
                    "Only text response output is supported!",
                    "output_response_content",
                    "select from t_cgi_param",
                    true,
                );
            }
        }
        None => show_error(
            "Could not determine response output type!",
            "output_response_content",
            "select from t_cgi_param",
            true,
        ),
    }
}

/************************************************************************************************/

fn output_response_headers(conn: &Connection) {
    match conn.query(
        "select f_name, f_value from t_cgi_param where f_type = 'response.header'",
        &[],
    ) {
        Err(e) => show_error(
            &e.to_string(),
            "output_response_headers",
            "select from t_cgi_param",
            true,
        ),
        Ok(rows) => {
            for row in rows.iter() {
                let header: String = row.get("f_name");
                let value: String = row.get("f_value");
                println!("{}: {}", header, value);
            }
        }
    }
}

/************************************************************************************************/

fn output_response_text(conn: &Connection) {
    match conn.query(
        "select f_content, f_new_line from t_cgi_response_text order by f_index",
        &[],
    ) {
        Err(e) => show_error(
            &e.to_string(),
            "output_response_text",
            "select from cgi_response_text",
            true,
        ),
        Ok(rows) => {
            for row in rows.iter() {
                let content: String = match row.get_opt("f_content") {
                    Some(res) => match res {
                        Err(_) => String::new(), // content is null (most likely)
                        Ok(var) => var,
                    },
                    None => String::new(),
                };
                let new_line: bool = row.get("f_new_line");
                print!("{}", content);
                if new_line {
                    println!();
                }
            }
        }
    }
}
/************************************************************************************************/

fn show_error(message: &str, cgi_side: &str, psql_side: &str, terminate: bool) {
    eprintln!("ERROR: {}", message);

    println!("Status: 500 Internal Server Error");
    println!("Content-type: text/html");
    println!();

    println!("<!DOCTYPE html>");
    print!("<html>");

    print!("<head>");
    print!("<meta charset=\"UTF-8\">");
    print!("<title>pgCGI Error</title>");
    print!("</head>");

    print!("<body>");

    print!("<h1>pgCGI Error</h1>");

    print!("<dl>");
    print!("<dt>message:</dt>");
    print!("<dd>{}</dd>", message);
    print!("<dt>cgi:</dt>");
    print!("<dd>{}</dd>", cgi_side);
    print!("<dt>psql:</dt>");
    print!("<dd>{}</dd>", psql_side);
    print!("<dt>pgCGI version:</dt>");
    print!(
        "<dd>{} v{}</dd>",
        env!("CARGO_PKG_NAME"),
        env!("CARGO_PKG_VERSION")
    );
    print!("</dl>");

    print!("</body>");
    print!("</html>");

    if terminate {
        exit(0);
    }
}

/************************************************************************************************/

fn redirect_to(location: String) {
    println!("Status: 301 Moved Permanently");
    println!("Location: {}", location);
    println!("Content-type: text/plain");
    println!();
    println!("Please redirect to: {}", location);
}

/************************************************************************************************/

fn show_hello_world() {
    println!("Status: 200 OK");
    println!("Content-type: text/plain");
    println!();
    println!("pgCGI says: Hello, world!");
}

/************************************************************************************************/

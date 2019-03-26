/************************************************************************************************/

#[cfg(feature = "debug_utils")]
mod debug_utils;

/************************************************************************************************/

use postgres::{Connection, TlsMode};
use std::{env, process::exit};

/************************************************************************************************/

fn main() {
    #[cfg(feature = "debug_utils")]
    debug_utils::handle_debug_utils();

    let path_info = get_env_var("PATH_INFO", "Could not determine PATH_INFO!");
    process_request(path_info);
}

/************************************************************************************************/

fn get_env_var(key: &str, error_message: &str) -> String {
    match env::var(key) {
        Ok(val) => val,
        Err(_) => {
            show_error(error_message, true);
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
                &format!(
                    "There was an error while connecting to the database:\n\t\t{}",
                    e
                ),
                true,
            ),
        }
    }
}

/************************************************************************************************/

fn process_request_db(conn: Connection) {
    match conn.execute("select cgi.initialize();", &[]) {
        Err(e) => show_error(
            &format!("ERROR -> process_request_db -> cgi.initialize: {}", e),
            true,
        ),
        Ok(_) => (),
    }

    insert_env_variables(&conn);

    match conn.execute("select cgi.handle_request();", &[]) {
        Err(e) => show_error(
            &format!("ERROR -> process_request_db -> cgi.handle_request: {}", e),
            true,
        ),
        Ok(_) => (),
    }

    output_response_content(&conn);

    match conn.execute("select cgi.finalize();", &[]) {
        Err(e) => show_error(
            &format!("ERROR -> process_request_db -> cgi.finalize: {}", e),
            true,
        ),
        Ok(_) => (),
    }
}

/************************************************************************************************/

fn insert_env_variables(conn: &Connection) {
    match conn.prepare("insert into cgi_param(type, name, index, value) values('env', $1, 0, $2)") {
        Err(e) => show_error(
            &format!(
                "ERROR -> insert_env_variables -> prepare insert into: {}",
                e
            ),
            true,
        ),
        Ok(stmt) => {
            for (key, value) in env::vars() {
                match stmt.execute(&[&key, &value]) {
                    Err(e) => show_error(
                        &format!(
                            "ERROR -> insert_env_variables -> executing insert into: {}",
                            e
                        ),
                        true,
                    ),
                    Ok(_) => (),
                }
            }
        }
    }
}

/************************************************************************************************/

fn get_cgi_param(conn: &Connection, ptype: &str, name: &str) -> Option<String> {
    match conn.query(
        "select value from cgi_param where type = $1 and name = $2 and index = 0",
        &[&ptype, &name],
    ) {
        Err(e) => {
            show_error(
                &format!("ERROR -> get_cgi_param -> select from cgi_param: {}", e),
                true,
            );
            None
        }
        Ok(rows) => {
            if rows.is_empty() {
                None
            } else {
                let value: String = rows.get(0).get("value");
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
                println!("");

                output_response_text(&conn);
            } else {
                show_error("Only text response output is supported!", true);
            }
        }
        None => show_error("Could not determine response output type!", true),
    }
}

/************************************************************************************************/

fn output_response_headers(conn: &Connection) {
    match conn.query(
        "select name, value from cgi_param where type = 'response.header'",
        &[],
    ) {
        Err(e) => show_error(
            &format!(
                "ERROR -> output_response_headers -> select from cgi_param: {}",
                e
            ),
            true,
        ),
        Ok(rows) => {
            for row in rows.iter() {
                let header: String = row.get("name");
                let value: String = row.get("value");
                println!("{}: {}", header, value);
            }
        }
    }
}

/************************************************************************************************/

fn output_response_text(conn: &Connection) {
    match conn.query(
        "select content, new_line from cgi_response_text order by index",
        &[],
    ) {
        Err(e) => show_error(
            &format!(
                "ERROR -> output_response_text -> select from cgi_response_text: {}",
                e
            ),
            true,
        ),
        Ok(rows) => {
            for row in rows.iter() {
                let content: String = match row.get_opt("content") {
                    Some(res) => match res {
                        Err(_) => String::new(), // content is null (most likely)
                        Ok(var) => var,
                    },
                    None => String::new(),
                };
                let new_line: bool = row.get("new_line");
                print!("{}", content);
                if new_line {
                    println!("");
                }
            }
        }
    }
}
/************************************************************************************************/

fn show_error(message: &str, terminate: bool) {
    println!("Status: 500 Internal Server Error");
    println!("Content-type: text/plain");
    println!("");
    println!(
        "pgCGI could not process your request due to the following problem:\n\t{}",
        message
    );

    eprintln!("ERROR: {}", message);

    if terminate {
        exit(0);
    }
}

/************************************************************************************************/

fn show_hello_world() {
    println!("Status: 200 OK");
    println!("Content-type: text/plain");
    println!("");
    println!("pgCGI says: Hello, world!");
}

/************************************************************************************************/

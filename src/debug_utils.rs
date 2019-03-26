/************************************************************************************************/

use std::{env, io, process::exit};

/************************************************************************************************/

pub fn handle_debug_utils() {
    match env::var("PATH_INFO") {
        Ok(val) => {
            if val == "/debug_show_all" {
                debug_show_all();
                exit(0);
            }
        }
        Err(_) => () // do nothing,
    }
}

/************************************************************************************************/

fn debug_show_all() {
    println!("Status: 200 OK");
    println!("Content-type: text/plain");
    println!("");

    println!("args");
    println!("----");
    for argument in env::args() {
        println!("{}", argument);
    }

    println!("");
    println!("");

    println!("env");
    println!("---");
    for (key, value) in env::vars() {
        println!("{}: {}", key, value);
    }

    println!("");
    println!("");

    println!("stdin");
    println!("-----");
    let mut line = String::new();
    let stdin = io::stdin();

    loop {
        let nb = stdin.read_line(&mut line).unwrap();
        if nb == 0 {
            break;
        } else {
            println!("{}", line);
            line.clear();
        }
    }
}

/************************************************************************************************/

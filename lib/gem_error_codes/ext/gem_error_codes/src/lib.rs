use crate_error_codes::UserError::{InvalidCredentials, UserNotFound};
use magnus::{function, prelude::*, Error, Ruby};

fn user_not_found() -> i32 {
    UserNotFound as i32
}
fn user_not_found_message() -> String {
    UserNotFound.error_message().to_string()
}

fn invalid_credentials() -> i32 {
    InvalidCredentials as i32
}

fn invalid_credentials_message() -> String {
    InvalidCredentials.error_message().to_string()
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("GemErrorCodes")?;
    module.define_singleton_method("user_not_found", function!(user_not_found, 0))?;
    module.define_singleton_method("user_not_found_message", function!(user_not_found_message, 0))?;
    module.define_singleton_method("invalid_credentials", function!(invalid_credentials, 0))?;
    module.define_singleton_method("invalid_credentials_message", function!(invalid_credentials_message, 0))?;
    Ok(())
}

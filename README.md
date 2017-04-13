[![Build Status](https://travis-ci.org/LaunchPadLab/token-master.svg?branch=master)](https://travis-ci.org/LaunchPadLab/token-master)

# token-master
User management logic using tokens

## Usage
```
class User < ApplicationRecord
  include TokenMaster::Core

  token_master :confirm, :foobar
end
```

```
## For confirm

user = User.confirm_by_token!(token, **kwargs)

token = user.set_confirm_token!

user.send_confirm_instructions!

user.confirm_status


## Same for foobar

User.foobar_by_token!(token)

...

```

## Setup

```
bundle exec rails generate token_master:model User confirm foobar
```

This creates the following columns:
```
    add_column :users, :confirm_token, :string, default: nil
    add_column :users, :confirm_created_at, :timestamp, default: nil
    add_column :users, :confirm_completed_at, :timestamp, default: nil
    add_column :users, :confirm_sent_at, :timestamp, default: nil

    add_index :users, :confirm_token

    add_column :users, :foobar_token, :string, default: nil
    add_column :users, :foobar_created_at, :timestamp, default: nil
    add_column :users, :foobar_completed_at, :timestamp, default: nil
    add_column :users, :foobar_sent_at, :timestamp, default: nil

    add_index :users, :foobar_token
```

```
bundle exec rails generate token_master:install
```
This creates a config file for TokenMaster. The config file will include methods to add configurations for each tokenable, set to the default configurations. Configurations you can set include:

- Token Lifetime (`:token_lifetime`, takes an integer
- Reuired Params (`:token_lifetime`), takes an array
- Token Length(`:token_length`), takes an integer

```
config.add_tokenable_options :confirm, TokenMaster::Config::DEFAULT_VALUES'

## OR

config.add_tokenable_options :reset, token_lifetime: 1, required_params: [:password, :password_confirmation], token_length: 15
```

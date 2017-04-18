[![GitHub](http://img.shields.io/badge/github-launchpadlab/token_master-blue.svg)](http://github.com/launchpadlab/token_master)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/token_master)

[![Gem Version](https://badge.fury.io/rb/token_master.svg)](https://badge.fury.io/rb/token_master)
[![Build Status](https://travis-ci.org/LaunchPadLab/token-master.svg?branch=master)](https://travis-ci.org/LaunchPadLab/token-master)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

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
bundle exec rails generate token_master User confirm foobar
```

This creates a migration file for the following columns:
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

This command also creates or updates the TokenMaster initializer file. The initializer will include methods to add configurations for each tokenable, set to the default configurations. Configurations you can set include:

- Token Lifetime (`:token_lifetime`, takes an integer
- Reuired Params (`:token_lifetime`), takes an array
- Token Length(`:token_length`), takes an integer

```
config.add_tokenable_options :confirm, TokenMaster::Config::DEFAULT_VALUES

## OR

config.add_tokenable_options :reset, token_lifetime: 1, required_params: [:password, :password_confirmation], token_length: 15
```

## Api Documentation
[Rdoc](http://www.rubydoc.info/gems/token_master)
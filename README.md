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

user = TokenMaster.confirm_by_token!(User, token, **kwargs)
# or
user = User.confirm_by_token!(token, **kwargs)

user = User.new
token = TokenMaster.set_confirm_token!(user)
# or
token = user.set_confirm_token!

TokenMaster.send_confirm_instructions!(user)
# or
user.send_confirm_instructions!

TokenMaster.confirm_succeeded?(user)
# or
user.confirm_succeeded?

TokenMaster.confirm_pending?(user)
# or
user.confirm_pending?


## Same for foobar

TokenMaster.foobar_by_token!(User, token)
# or
User.foobar_by_token!(token)

...

```

## Setup

```
bundle exec rails generate token-master:model User confirm foobar
```

This creates the following columns:
```
    add_column :users, :confirm_token, :string, default: nil
    add_column :users, :confirm_created_at, :timestamp, default: nil
    add_column :users, :confirm_sent_at, :timestamp, default: nil

    add_index :users, :confirm_token

    add_column :users, :foobar_token, :string, default: nil
    add_column :users, :foobar_created_at, :timestamp, default: nil
    add_column :users, :foobar_sent_at, :timestamp, default: nil

    add_index :users, :foobar_token
```
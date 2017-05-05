<img src="badge.png" alt="Token Master Logo" width="150"/>
<h1>Token Master</h1>

[![GitHub](http://img.shields.io/badge/github-launchpadlab/token_master-blue.svg)](http://github.com/launchpadlab/token_master)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/token_master)
[![Inline docs](http://inch-ci.org/github/LaunchPadLab/token-master.svg?branch=master)](http://inch-ci.org/github/LaunchPadLab/token-master)
[![Gem Version](https://badge.fury.io/rb/token_master.svg)](https://badge.fury.io/rb/token_master)
[![Build Status](https://travis-ci.org/LaunchPadLab/token-master.svg?branch=master)](https://travis-ci.org/LaunchPadLab/token-master)
[![Test Coverage](https://codeclimate.com/github/LaunchPadLab/token-master/badges/coverage.svg)](https://codeclimate.com/github/LaunchPadLab/token-master/coverage)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

**Minimal** and **Simple** user management for Ruby and Rails applications.

* [Motivation](#motivation)
* [Token Master](#enter-the-token-master)
* [Quick Start](#quick-start)
* [Details](#details)
* [FAQ](#faq)

## Motivation
Whenever your application manages users, you will inevitably need to handle email confirmation, password reset, user invitations, and other authentication flows. While not too complicated, they are sort of annoying to implement and some great libraries have our backs. [Devise][devise] and [Sorcery][sorcery] are great options that we have used in the past, but we found ourselves wanting both a little less and a little more.

### Devise
[Devise][devise] is an amazing gem! It is perfect when you want an all-in-one solution that handles user authentication and associated flows for your Rails/ERB app. Everything is in the box, including the routes, controllers, views, and even mailers to handle user auth. But we often use Rails as an API and/or wanted more control over all those pieces and it became difficult to peel back all the layers to just to confirm a user's email.

### Sorcery
[Sorcery][sorcery] is great and we highly recommend it. It is closer to what we wanted but still was a bit more than we needed and even the < 20 methods seemed like more than necessary.

### User Authentication Flows
Email confirmation, password reset, user invitations are all variations of the same process:

1. Create a unique token that allows the user temporary and limited access to your application
2. Notify the user with a link to redeem the token
3. Redeem or reject the token based on certain conditions (ex. validity, expiration, etc)
4. Update the user with any new information
5. Revoke the token

They are all *tokenable* activities, and all you need to do them is a **Token Master**!

## Enter the Token Master

### Front-end agnostic
No routing, views, controllers, or mailers, just logic that you can use wherever and whenever you want.

### Authentication strategy agnostic
Token Master does not handle user authentication, it assumes you have this covered with `has_secure_password`, Devise, Sorcery, or other solutions

### Unobtrusive
Does not take over your app, minimal magic, and only if you want it. Token Master works with your existing authentication solution.

### Flexible
Works for APIs, ERB apps and everything in between.

### Simple
Only 5 methods and you may not even use them all!

### Helpful errors
We take the approach of raising an error whenever anything unexpected happens and provide a specific error with a helpful message to aid your debugging and testing experience.

## Quick Start

### Installation
Add this line to your application's Gemfile:

`gem 'token_master'`

And then execute:

`$ bundle`

Or install it yourself as:

`$ gem install token_master`

### Add a *tokenable*

##### These examples assume Rails 5, but anything >= 4 will work.

Let's say you want to add email confirmation flow to your User.

1. Create and run a migration to add the necessary columns to the `users` table
```
bundle exec rails generate token_master User confirm
bundle exec rails db:migrate
```

2. Add Token Master to the User class

```
class User < ApplicationRecord
  token_master :confirm
end
```

3. Somewhere during the signup flow, generate and send the token

```
class UsersController < ApplicationController

  ...

  def create

    # Creating the user is up to you, here is an example
    user = User.create!(
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    # Generate and save a unique token
    token = user.set_confirm_token!

    # Mark the token as sent
    user.send_confirm_instructions! do
      # Sending the email is up to you
      UserMailer.send_confirm(user) # or some other logic
    end
  end

  ...

end
```

4. Somewhere during the confirmation flow, find and confirm the User

```
class UsersController < ApplicationController

  ...

  def confirm

    # find the user by the token and mark the token as completed
    user = User.confirm_by_token!(params[:token])

    ...

  end

  ...

end
```

## Details

Let's revisit the Quick Start and fill in the details.

### The Generator
When you ran the generator
```
bundle exec rails generate token_master User confirm
```
you provided 2 variables:
  * `User` - The class name of the model to which you are adding the *tokenable*
  * `confirm` - The name of the *tokenable*

Both of these could be anything, as long as you use the same class and name later on. If you like, you can create multiple *tokenables* at the same time, just add more space-separated *tokenable* names when calling the generator:
```
bundle exec rails generate token_master User confirm invite reset ...
```

Running the generator does 2 things:
1. Creates a migration file in `#{Rails.root}/db/migrate` that looks like:

```
class AddConfirmTokenableToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :confirm_token,        :string,    default: nil
    add_column :users, :confirm_created_at,   :timestamp, default: nil
    add_column :users, :confirm_completed_at, :timestamp, default: nil
    add_column :users, :confirm_sent_at,      :timestamp, default: nil

    add_index :users, :confirm_token
  end
end
```

where the `:users` table is determined from the `User` argument and `:confirm_*` is determined from the `confirm` argument.

2. Creates an initializer `#{Rails.root}/config/initializers/token_master.rb` that looks like:

```
TokenMaster.config do |config|
  # Set up your configurations for each *tokenable* using the methods at the bottom of this file.
  # Example: For `confirm` logic:
  #
  # config.add_tokenable_options :confirm,
  #   token_lifetime:  15, # days
  #   required_params: [:email],
  #   token_length:    30 # characters
  #
  # Default values:
  #   token_lifetime  = 15 # days
  #   required_params = []
  #   token_length    = 20 # characters
  #
end
```
The default values will be used unless you configure them otherwise. These options can be set for each *tokenable*.

### The Model
When you added the *tokenable* to your model
```
class User < ApplicationRecord
  token_master :confirm
end
```
just make sure the class `User` and *tokenable(s)* `:confirm` (this can be multiple tokenables) match what you used in your generator.

Ex.
```
token_master :confirm, :invite, :reset, ...
```

There are 2 tiny bits of magic here:

1. In Rails apps by default, the Token Master module is included in your `ApplicationRecord` base class. However, if necessary, you can add this yourself by including the following in your class:
```
include TokenMaster::Model
```
This adds the `token_master` class method we used above.

2. When you call the `token_master` class method, for each *tokenable* you provide, 5 methods are added to the class (assuming the *tokenable* below is `confirm`):

Instance methods
* `set_confirm_token!`
* `send_confirm_instructions!`
* `confirm_status`
* `force_confirm!`

Class methods
* `confirm_by_token!`

In addition to the 3 you have already seen in action, there is also:

`confirm_status` - returns the current status of the *tokenable*. This is one of:
* 'no token'
* 'created'
* 'sent'
* 'completed'
* 'expired'

`force_confirm!` - forcibly completes the given *tokenable*

See the [Api Docs][docs] for more details.

## Advanced
Sometimes in order to redeem a token, we want to make sure some additional information is present and possibly save that to our model. For example, when implementing a password reset flow, we want to update the User with the new password and make sure that its valid.

Assuming we are using `has_secure_password` or something similar all we need to do is:
1. Configure the *tokenable* to require these fields when redeeming the token
```
# in ../initializers/token_master.rb

TokenMaster.config do |config|

  ...

  config.add_tokenable_options :reset_password, required_params: [:password, :password_confirmation]

  ...

end
```

2. Include those parameters when redeeming the token (If you don't you will get an error!)
```
User.reset_password_by_token!(
  token,
  password: password,
  password_confirmation: password_confirmation
)
```

Under the hood, Token Master calls `update!` on the model, so if the model is not valid, it won't be saved and the token will not be redeemed.

## FAQ

### Can I use this without Rails?
Yes! However, there is a small dependency on ActiveRecord, see below.

### Can I use this without ActiveRecord?
Almost! There is only a slight dependence on a few ActiveRecord methods and its on our radar to refactor this a bit. In the meantime, a workaround is to make sure the class you are using implements `update`, `update!`, `save`, and `find_by`. In addition, you have to either add Token Master to your class with `include TokenMaster::Model` or use the Token Master core module explicitly:

`user.set_confirm_token!(token)` == `TokenMaster::Core.set_token!(User, :confirm)`

See the [Api Docs][docs] for more details.

### Who is Launchpad Lab?
We are product builders, check us out at [Launchpad Lab][lpl]

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/LaunchpadLab/token-master.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

<!-- Links -->
[devise]: https://github.com/plataformatec/devise
[sorcery]: https://github.com/Sorcery/sorcery
[docs]: http://www.rubydoc.info/gems/token_master
[lpl]: https://launchpadlab.com/

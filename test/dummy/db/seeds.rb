## CREATE USERS
puts 'creating users...'
num_users = 10
users = []
num_users.times do
  users << {
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: 'password',
    password_confirmation: 'password'
  }
end
User.create!(users)
puts "#{num_users} users created"

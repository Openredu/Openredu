
def create_users(qtd, course)
  users = []
  qtd.times do |i|
    users << create_user("rafael#{i}", "rafael#{i}","ra123456","rafael#{i}","rafael#{i}@rafael.com")
  end
  User.import users, validate: false
  users.each do |user|
    user_saved = User.find_by_login(user.login)
    user_saved.create_settings!
    course.join! user_saved
  end
end

def create_user(first_name, last_name, password, login, email)
  user = User.new(
    login: login,
    email: email,
    password: password,
    password_confirmation: password,
    birthday: 21.years.ago,
    first_name: first_name,
    last_name: 'User',
    activated_at: Time.now,
    last_login_at: Time.now
  )
  user
end

namespace :admin do
  desc "Create an administrator account using private terminal prompts"
  task create: :environment do
    require "io/console"
    abort "Run this task in an interactive terminal." unless $stdin.tty?

    print "Name: "
    name = $stdin.gets.to_s.strip
    print "Email: "
    email = $stdin.gets.to_s.strip.downcase
    abort "An account with that email already exists; no account was changed." if User.exists?(email: email)

    print "Password (at least 12 characters): "
    password = $stdin.noecho(&:gets).to_s.chomp
    puts
    print "Confirm password: "
    confirmation = $stdin.noecho(&:gets).to_s.chomp
    puts

    user = User.new(name: name, email: email, password: password,
      password_confirmation: confirmation, role: "admin")
    if user.save
      puts "Administrator created. Sign in at /admin/login."
    else
      abort user.errors.full_messages.join("\n")
    end
  end
end

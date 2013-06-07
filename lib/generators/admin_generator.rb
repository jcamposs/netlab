class AdminGenerator < Rails::Generators::Base
  desc "This generator inserts a new admin user if there is no other in the Admin table"
  def create_base_admin
    if Admin.all.empty?
      p 'Generating root admin'
      email = ask("Admin email: ")
      passwd = ask("Admin password: ")
      conf_passwd = ask("Re-type password: ")
      if (email != "") and (passwd == conf_passwd)
        Admin.new({:email => email, :password => passwd, :password_confirmation => passwd}).save(:validate => false)
        p 'Done'
      else
        p 'Wrong data'
      end
    else
      p 'There is already an admin user'
    end
  end
end

module NetlabConf
  # Set the user to manage shellinabox demons, the user selected must be able
  # to launh shellinabox command.
  mattr_accessor :user
  @@user = "netlab"

  # Shellinabox installationm directory
  mattr_accessor :shellinabox_dir
  @@shellinabox_dir = "/etc/shellinabox/"

  def self.setup
    yield self
  end
end

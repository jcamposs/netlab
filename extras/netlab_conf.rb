module NetlabConf
  # Set the user to manage shellinabox demons, the user selected must be able
  # to launh shellinabox command.
  mattr_accessor :user
  @@user = "netlab"

  def self.setup
    yield self
  end
end

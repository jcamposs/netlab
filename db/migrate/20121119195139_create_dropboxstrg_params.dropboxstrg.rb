# This migration comes from dropboxstrg (originally 20121107102730)
require 'dropboxstrg/version'

class CreateDropboxstrgParams < ActiveRecord::Migration
  def change
    create_table :dropboxstrg_params do |t|
      t.integer "#{Dropboxstrg.user_class.downcase}_id".to_sym
      t.string :akey
      t.string :asecret

      t.timestamps
    end

    plugin = Cloudstrg::Cloudstrgplugin.find_by_plugin_name("dropbox")
    if not plugin
      puts "Inserting Dropbox plugin"
      Cloudstrg::Cloudstrgplugin.create :plugin_name => "dropbox", :version => Dropboxstrg::VERSION
    else
      if Dropboxstrg::VERSION > plugin.version
        puts "Updating Dropbox plugin version: #{Dropboxstrg::VERSION}"
        plugin.version = Dropboxstrg::VERSION
        plugin.save
      else
        puts "Dropbox plugin is up to date"
      end
    end
  end
end

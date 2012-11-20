# This migration comes from gdrivestrg (originally 20121107140721)
require 'gdrivestrg/version'

class CreateGdrivestrgParams < ActiveRecord::Migration
  def change
    create_table :gdrivestrg_params do |t|
      t.string :refresh_token
      t.integer :expires_in
      t.date :issued_at

      t.timestamps
    end

    plugin = Cloudstrg::Cloudstrgplugin.find_by_plugin_name("gdrive")
    if not plugin
      puts "Inserting Google Drive plugin"
      Cloudstrg::Cloudstrgplugin.create :plugin_name => "gdrive", :version => Gdrivestrg::VERSION
    else
      if Gdrivestrg::VERSION > plugin.version
        puts "Updating Google Drive plugin version: #{Gdrivestrg::VERSION}"
        plugin.version = Gdrivestrg::VERSION
        plugin.save
      else
        puts "Google Drive plugin is up to date"
      end
    end
  end
end

require 'json'

class Netlabsession < ActiveRecord::Base
  attr_accessible :params, :session_id, :user_id

  attr_accessor :h_params

  before_save :convert_hash

  private
  def convert_hash
    if not h_params
      raise Exception, 'you must specify the params hash'
    end
    self.params = h_params.to_json
  end
end

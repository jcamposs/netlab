class ShellinaboxObserver < ActiveRecord::Observer
  def before_destroy shellinabox
    puts "Kill shellinabox demon pid #{shellinabox.pid}"
  end
end

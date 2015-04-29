# Possibly already created by a migration.
unless Spree::Store.where(code: 'spree').exists?
  Spree::Store.skip_callback(:save, :before, :set_url)
  Spree::Store.new do |s|
    s.code              = 'spree'
    s.name              = 'Spree Demo Site'
    s.url               = 'demo.spreecommerce.com'
    s.subdomain         = 'demo'
    s.currency          = Spree::Config[:currency]
    s.mail_from_address = 'spree@example.com'
  end.save!
  Spree::Store.set_callback(:save, :before, :set_url)
end

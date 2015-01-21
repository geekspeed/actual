SubdomainFu.configure do |config|
  config.tld_sizes = {:development => 0, :test => 0, :production => 1, :staging => 1} # set all at once (also the defaults)
end
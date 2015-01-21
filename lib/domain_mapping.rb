class DomainMapping

  def self.domain(objekt)
    obj = ""
    static_domain = ""
    if (objekt.is_a?(Program))
      obj = objekt.domain_map.present? ? objekt : objekt.organisation
    elsif(objekt.is_a?(Organisation))
      obj = objekt.domain_map.present? ? objekt : ""
    end
    case Rails.env
      when "staging"
        static_domain = "droicon.fr"
      when "development"
        static_domain = "localhost:3000"
      when "production"
        static_domain = "apptual.com"
    end
    domain_host = (obj.present? and obj.domain_map.present?) ? obj.domain_map.domain : static_domain
    SubdomainFu.configure{|f| f.tld_sizes[Rails.env.to_sym] = domain_host.count(".")}
    domain_host
  end

  def self.sub_domain?(static_domain)
    ["droicon.fr", "localhost:3000", "apptual.com"].include? static_domain
  end
end
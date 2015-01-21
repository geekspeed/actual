module App
  module Rolefy
    module Kontrollers

      RoleType.all.each do |role|
        code = role.code

        define_method :"authorize_#{code}" do
          d("#{code}") 
          if code == "super_admin"
            if !current_user["_super_admin"]
              raise App::Rolefy::NotAuthorized, "Need a Super Admin"
            end
          elsif code == "company_admin"
            if !current_user.company_admin?(current_organisation)
              raise App::Rolefy::NotAuthorized, "Need a Company Admin"
            end
          else
            authorize(code)
          end
        end
      end

      def authorize(role_code)
        if !(current_user && current_user.send(:"#{role_code}?", params[:program_id] || params[:id]))
          raise App::Rolefy::NotAuthorized, "Need a #{role_code.humanize}"
        end
      end

      # def need?(roles, on)
      #   return false if !defined? current_user || !current_user
      #   authorized = roles.collect{|r| current_user.send("#{r}?", on) }
      #   authorized.any?
      # end

    end
  end
end
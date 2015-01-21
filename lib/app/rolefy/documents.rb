module App
  module Rolefy

    module Documents
      RoleType.all.each do |role|
        code = role.code

        define_method :"#{code}?" do |authorized_on = nil|
          return !!self["_super_admin"] if code == "super_admin"
          role?(code, authorized_on)
        end
      end

      def update_role(role_code, values)
        values = [values] if !values.is_a? Array
        update_attribute(:"_#{role_code}", values) if respond_to? :update_attribute
      end

      def add_role(role_code, values)
        values = [values] if !values.is_a? Array
        values = [self[:"_#{role_code}"], values].flatten.compact.uniq
        update_role(role_code, values)
      end

      def remove_role(role_code, value)
        values = self[:"_#{role_code}"] - [value]
        update_role(role_code, values)
      end

      def role?(role_code, authorized_on)
        return false if authorized_on.nil?
        authorized_on = authorized_on.respond_to?(:id) ? authorized_on.id : authorized_on
        self[:"_#{role_code}"] && self[:"_#{role_code}"].include?(authorized_on.to_s)
      end

      def invite_role(role_code, values)
        add_role("invited_#{role_code}", values)
      end

      def remove_invite_role(role_code, value)
        remove_role("invited_#{role_code}", value)
      end

      def invited_for?(role_code, resource)
        role?("invited_#{role_code}", resource)
      end

      def awaiting_for_approval role, values
        values = [values] if !values.is_a? Array
        values = [self[:"_awaiting_#{role}"], values].flatten.compact.uniq
        update_role("awaiting_#{role}", values)
      end

    end

    module Scopes

      RoleType.all.each do |role|
        code = role.code

        define_method :"#{code.pluralize}" do |authorized_on = nil|
          return User.where("_super_admin" => true) if code == "super_admin"
          User.in("_#{code}" => [authorized_on])
        end

        define_method :"invited_#{code.pluralize}" do |authorized_on = nil|
          return User.where("_super_admin" => true) if code == "super_admin"
          User.in("_invited_#{code}" => [authorized_on])
        end
      end

    end
  end
end
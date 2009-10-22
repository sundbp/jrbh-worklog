class User < ActiveRecord::Base
  has_many :work_periods

  acts_as_authentic do |config|
    config.validate_password_field false
  end

  LDAP_HOST = '192.168.1.2'
  LDAP_DOMAIN = 'JRBH'

  protected
    def valid_ldap_credentials?(password_plaintext)
      # try to authenticate against the LDAP server
      ldap = Net::LDAP.new
      ldap.host = LDAP_HOST
      # first create the username/password strings to send to the LDAP server
      # in our case we need to add the domain so it looks like COMPANY\firstname.lastname
      ldap.auth "#{LDAP_DOMAIN}\\" + self.login, password_plaintext
      ldap.bind # will return false if authentication is NOT successful
    end
end

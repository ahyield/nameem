class MagicLink
  module Code
    ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ".freeze # Base32 without O, I, L, U

    def self.generate
      Array.new(6) { ALPHABET[SecureRandom.random_number(ALPHABET.length)] }.join
    end

    def self.sanitize(code)
      code.upcase.tr("OIL", "011")
    end
  end
end

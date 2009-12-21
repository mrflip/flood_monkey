require 'oauth/signature/base'

module OAuth::Signature
  class PLAINTEXT < Base
    implements 'plaintext'

    def signature
      signature_base_string
    end

    def ==(cmp_signature)
      secure_equals(signature , escape(cmp_signature))
    end

    def signature_base_string
      secret
    end

    def secret
      super
    end
  end
end

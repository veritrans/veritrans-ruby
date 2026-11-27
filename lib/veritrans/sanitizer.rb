# frozen_string_literal: true

class Veritrans
  class Sanitizer
    REDACTED = '[FILTERED]'

    # Default sensitive keys based on Midtrans API parameters
    # https://docs.midtrans.com/reference/request-body-json-parameter
    DEFAULT_SENSITIVE_KEYS = %w[
      card_number
      card_cvv
      email
      first_name
      last_name
      phone
      token_id
      saved_token_id
      server_key
      client_key
    ].freeze

    class << self
      def sensitive_keys
        @sensitive_keys ||= DEFAULT_SENSITIVE_KEYS.dup
      end

      def sensitive_keys=(keys)
        @sensitive_keys = keys
      end

      def add_sensitive_keys(*keys)
        sensitive_keys.concat(keys.flatten).uniq!
      end

      def sanitize(data)
        case data
        when Hash
          sanitize_hash(data)
        when Array
          data.map { |v| sanitize(v) }
        else
          data
        end
      end

      private

      def sanitize_hash(hash)
        hash.each_with_object({}) do |(key, value), result|
          result[key] = if sensitive_key?(key)
                          REDACTED
                        else
                          sanitize(value)
                        end
        end
      end

      def sensitive_key?(key)
        normalized = key.to_s.downcase.gsub('_', '')
        sensitive_keys.any? { |s| normalized.include?(s.downcase.gsub('_', '')) }
      end
    end
  end
end

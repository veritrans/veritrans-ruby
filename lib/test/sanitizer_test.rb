require 'veritrans'
require 'minitest/autorun'

class TestSanitizer < Minitest::Test
  def setup
    # Reset to default keys before each test
    Veritrans::Sanitizer.sensitive_keys = Veritrans::Sanitizer::DEFAULT_SENSITIVE_KEYS.dup
  end

  def test_sanitize_flat_hash
    data = {
      order_id: "order-123",
      email: "customer@example.com",
      phone: "+628123456789",
      amount: 10000
    }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "order-123", result[:order_id]
    assert_equal "[FILTERED]", result[:email]
    assert_equal "[FILTERED]", result[:phone]
    assert_equal 10000, result[:amount]
  end

  def test_sanitize_nested_hash
    data = {
      transaction_details: { order_id: "order-123", gross_amount: 10000 },
      customer_details: {
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        phone: "+628123456789"
      }
    }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "order-123", result[:transaction_details][:order_id]
    assert_equal "[FILTERED]", result[:customer_details][:first_name]
    assert_equal "[FILTERED]", result[:customer_details][:last_name]
    assert_equal "[FILTERED]", result[:customer_details][:email]
    assert_equal "[FILTERED]", result[:customer_details][:phone]
  end

  def test_sanitize_credit_card_data
    data = {
      credit_card: {
        token_id: "token-abc-123",
        saved_token_id: "saved-token-xyz"
      }
    }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "[FILTERED]", result[:credit_card][:token_id]
    assert_equal "[FILTERED]", result[:credit_card][:saved_token_id]
  end

  def test_sanitize_array
    data = [
      { email: "a@example.com", id: 1 },
      { email: "b@example.com", id: 2 }
    ]
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "[FILTERED]", result[0][:email]
    assert_equal 1, result[0][:id]
    assert_equal "[FILTERED]", result[1][:email]
    assert_equal 2, result[1][:id]
  end

  def test_sanitize_with_string_keys
    data = {
      "email" => "test@example.com",
      "order_id" => "order-123"
    }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "[FILTERED]", result["email"]
    assert_equal "order-123", result["order_id"]
  end

  def test_add_sensitive_keys
    Veritrans::Sanitizer.add_sensitive_keys("custom_field", "another_field")

    data = { custom_field: "secret", another_field: "also_secret", safe_field: "visible" }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "[FILTERED]", result[:custom_field]
    assert_equal "[FILTERED]", result[:another_field]
    assert_equal "visible", result[:safe_field]
  end

  def test_key_matching_ignores_underscores
    data = {
      first_name: "John",
      firstName: "John",
      "first-name" => "John"
    }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "[FILTERED]", result[:first_name]
    assert_equal "[FILTERED]", result[:firstName]
    # Note: first-name won't match because we only strip underscores, not hyphens
  end

  def test_preserves_non_sensitive_data
    data = {
      status_code: "200",
      transaction_status: "capture",
      gross_amount: "10000.00",
      currency: "IDR",
      payment_type: "credit_card"
    }
    result = Veritrans::Sanitizer.sanitize(data)

    assert_equal "200", result[:status_code]
    assert_equal "capture", result[:transaction_status]
    assert_equal "10000.00", result[:gross_amount]
    assert_equal "IDR", result[:currency]
    assert_equal "credit_card", result[:payment_type]
  end

  def test_handles_nil_and_empty
    assert_nil Veritrans::Sanitizer.sanitize(nil)
    assert_equal({}, Veritrans::Sanitizer.sanitize({}))
    assert_equal([], Veritrans::Sanitizer.sanitize([]))
  end
end

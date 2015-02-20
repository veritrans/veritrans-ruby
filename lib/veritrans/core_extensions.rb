# This is replacement for Hash#deep_merge in acive_support
# when acive_support not loaded

class Hash #:nodoc:

  unless method_defined?(:deep_merge)
    def deep_merge(second)
      merger = proc { |key, v1, v2|
        if Hash === v1 && Hash === v2
          v1.merge(v2, &merger)
        else
          [:undefined, nil, :nil].include?(v2) ? v1 : v2
        end
      }
      self.merge(second, &merger)
    end
  end

  unless method_defined?(:except!)
    def except!(*keys)
      keys.each { |key| delete(key) }
      self
    end
  end

  unless method_defined?(:except)
    def except(*keys)
      dup.except!(*keys)
    end
  end

end
